<#
.Synopsis
   Cmdlet used to apply BIOS attributes using REDFISH API.

.DESCRIPTION
   Cmdlet used to apply BIOS attributes previously set with 
   Register-RacBiosSettings cmdlet.
   The remote system will be restarted wether restart switch is specified,
   then the script will wait until the job is done, or return job id.

.PARAMETER Ip_Idrac

    Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

    Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

    Specifies the password for Idrac connection.

.PARAMETER Restart

    Specifies wether the system has to restart to apply immediately

.EXAMPLE
    Submit-RacPendingBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Restart

    This example applies BIOS attributes and restart the system behind 192.168.0.120 IpAddress

.EXAMPLE
    Submit-RacPendingBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin

    This example raise a job id pending for reboot and returns the Job Id

.LINK
    Get-RacPendingBiosSettings
    Register-RacBiosSettings
    Get-RacBiosSettings

.NOTES
   Cmdlet used to apply all registered BIOS attributes.
   To register one or more attributes, you have to use Register-RacBiosSettings cmdlet
#>
Function Submit-RacPendingBiosSettings {
    [CmdletBinding(DefaultParameterSetName = 'Host')]
    param(
        [Parameter(ParameterSetName = 'Ip', Mandatory = $true, Position = 0)]
        [Alias("idrac_ip")]
        [ValidateNotNullOrEmpty()]
        [IpAddress]$Ip_Idrac,

        [Parameter(ParameterSetName = 'Host', Mandatory = $true, Position = 0)]
        [Alias("Server")]
        [ValidateNotNullOrEmpty()]
        [string]$Hostname,

        [Parameter(ParameterSetName = 'Ip', Mandatory = $true, Position = 1)]
        [Parameter(ParameterSetName = 'Host', Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = 'Session', Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$Session,

        [Parameter(Mandatory=$false)]
        [switch]$Restart,

        [Parameter(Mandatory=$false)]
        [switch]$Wait,

        [Switch]$NoProxy
	)

    If ($PSBoundParameters['Hostname']) {
        $Ip_Idrac = [system.net.dns]::Resolve($Hostname).AddressList.IPAddressToString
    }

    Switch ($PsCmdlet.ParameterSetName) {
        Session {
            Write-Verbose -Message "Entering Session ParameterSet"
            $WebRequestParameter = @{
                Headers = $Session.Headers
                Method  = 'Get'
            }
            $Ip_Idrac = $Session.IPAddress
        }
        Default {
            Write-Verbose -Message "Entering Credentials ParameterSet"
            $WebRequestParameter = @{
                Headers     = @{"Accept" = "application/json" }
                Credential  = $Credential
                Method      = 'Get'
                ContentType = 'application/json'
            }
        }
    }

    If (! $NoProxy) { Set-myProxyAsDefault -Uri "Https://$Ip_Idrac" | Out-null }
    Else {
        Write-Verbose "No proxy requested"
        $Proxy = [System.Net.WebProxy]::new()
        $WebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $WebSession.Proxy = $Proxy
        $WebRequestParameter.WebSession = $WebSession
        If ($PSVersionTable.PSVersion.Major -gt 5) { $WebRequestParameter.SkipCertificateCheck = $true }
    }


# POST command to create BIOS config job and schedule it
    $JsonBody = @{ 
        "TargetSettingsURI" = "/redfish/v1/Systems/System.Embedded.1/Bios/Settings"
    } | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

    $Uri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Jobs"
    $WebRequestParameter.Uri = $Uri

    Try {
        $PostResult = Invoke-WebRequest @WebRequestParameter
    } Catch {
        Throw $_
    }

    $LocationLine = $PostResult.RawContent.Split([Environment]::NewLine) -match 'Location'
    $Location = $LocationLine.Split(": ")[2]
    $u3 = "https://$Ip_Idrac$location"
    $job_id = [uri]::new($u3).Segments[-1]
    
    If ($PostResult.StatusCode -eq 200) {
        Write-Verbose $([String]::Format("Statuscode {0} returned to successfully create job: {1}",$PostResult.StatusCode,$job_id))
        Start-Sleep 5
    } Else {
        Throw $([String]::Format("Statuscode {0} returned",$PostResult.StatusCode))
    }

    $Object = [PsCustomObject] @{
        Uri = [Uri]::new($u3)
        Id = $job_id
    }
    If ($Restart) {
        $start_time = [datetime]::Now
        $end_time = $start_time.AddMinutes(30)

# Manage reboot forced
    # Get current power status
        $u4 = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/"
        $WebRequestParameter.Uri = $u4
        $WebRequestParameter.Method = 'Get'
        $WebRequestParameter.Remove('Body')
        Try {
            $GetResult2 = Invoke-RestMethod @WebRequestParameter
        } Catch {
            Throw $_
        }

        If ([String]::IsNullOrEmpty($GetResult2) ) {
            Throw "Get current power state failed, cannot continue."
        } Else {
            $power_state = $GetResult2.PowerState
        }


        If ($power_state -eq 'On') {
    # POST command to power OFF the server
            $JsonBody = @{ 
                "ResetType" = "ForceOff"
            } | ConvertTo-Json -Compress
            $WebRequestParameter.Body = $JsonBody

            $u5 = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/Actions/ComputerSystem.Reset"
            $WebRequestParameter.Uri = $u5

            $WebRequestParameter.Method = 'Post'
            $PostResult2 = Invoke-WebRequest @WebRequestParameter

            If ($PostResult2.StatusCode -eq 204) {
                Write-Verbose -Message $([String]::Format("Statuscode {0} returned successfully to power OFF the server",$PostResult2.StatusCode))
                Start-Sleep 20
            } Else {
                Throw $([String]::Format("- FAIL, statuscode {0} returned",$PostResult2.StatusCode))
            }
        } 

        # POST command to power ON the server
        $JsonBody = @{ 
                "ResetType" = "On"
        } | ConvertTo-Json -Compress
        $WebRequestParameter.Body = $JsonBody
        $WebRequestParameter.Method = 'Post'

        $u6 = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/Actions/ComputerSystem.Reset"
        $WebRequestParameter.Uri = $u6

        $PostResult3 = Invoke-WebRequest @WebRequestParameter

        If ($PostResult3.StatusCode -eq 204) {
            Write-Verbose -Message $([String]::Format("Statuscode {0} returned successfully to power ON the server",$PostResult3.StatusCode))
            Start-Sleep 10
        } Else {
            Throw $([String]::Format("- FAIL, statuscode {0} returned",$PostResult3.StatusCode))
        }

       If ($wait) {
            Write-Verbose -Message "Cmdlet will now poll job ID $job_id every 15 seconds until marked completed"
            Remove-Variable overall_job_output -ea 0
            While ($overall_job_output.JobState -ne "Completed") {
                $loop_time = [datetime]::Now

        # GET command to loop query the job until marked completed or failed
                $WebRequestParameter.Uri = $u3
                $WebRequestParameter.Method = 'Get'
                $WebRequestParameter.Remove('Body')

                $CheckResult = Invoke-WebRequest @WebRequestParameter
                $overall_job_output = $CheckResult.Content | ConvertFrom-Json

                If ($CheckResult.StatusCode -eq 200) {
                    If ($overall_job_output.JobState -eq "Completed") {
                        Write-Verbose -Message $([String]::Format("{0} job ID marked as completed!", $job_id))
                        Return [PsCustomObject] @{
                            'JobId' = $overall_job_output.Id
                            'State' = $overall_job_output.JobState
                            'Message' = $overall_job_output.Message
                            'Information' = $overall_job_output.JobType
                        }
                    } Elseif ($overall_job_output.JobState -eq "Failed") {
                        Throw $([String]::Format("FAIL, {0} job ID marked as failed, detailed error info: {1}", $job_id, $CheckResult))
                    } Elseif ($loop_time -gt $end_time) {
                        Throw $([String]::Format("{0} job ID failed, timeout has been reached, current job status is {1}", $job_id, $overall_job_output.JobState))
                    } Else {
                        Write-Verbose -Message $([String]::Format("{0} job ID current status is: {1}", $job_id, $overall_job_output.JobState))
                        Start-Sleep 15
                    }
                } Else {
                    Throw $([String]::Format("- FAIL, statuscode {0} returned", $CheckResult.StatusCode))
                }
            }
        }
    } Else {
        Return $Object
    }
}


Export-ModuleMember Submit-RacPendingBiosSettings