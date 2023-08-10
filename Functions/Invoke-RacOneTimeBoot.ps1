<#
.Synopsis
    Cmdlet used to restart the remote system and boot to the device specied using REDFISH API.

.DESCRIPTION
    Cmdlet used to restart the remote system and boot to the device specied using REDFISH API.
    Available boot device are "Normal", "PXE", "HDD", "vFDD", "VCD-DVD".

.PARAMETER Ip_Idrac

    Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

    Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

    Specifies the password for Idrac connection.

.PARAMETER BootDevice

    Specifies the targer device to boot at next startup.

.EXAMPLE
    Invoke-RacOneTimeBoot -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -BootDevice PXE

    This example set PXE as boot override and restart the system behind 192.168.0.120 IpAddress

#>
Function Invoke-RacOneTimeBoot {
    [CmdletBinding(DefaultParameterSetName='Host')]
	param(
		[Parameter(ParameterSetName = "Creds")]
        [Parameter(Mandatory=$true, ParameterSetName='Ip')]
        [Alias("idrac_ip")]
        [IpAddress]$Ip_Idrac,
		[Parameter(ParameterSetName = "Creds")]
        [Parameter(Mandatory=$true, ParameterSetName='Host')]
        [Alias("Server")]
        [string]$Hostname,
        [Parameter(Mandatory=$true, ParameterSetName = "Creds")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true, ParameterSetName = "Session")]
        [PSCustomObject]$Session,
        [Parameter(Mandatory=$false)]
        [ValidateSet("Normal", "PXE", "HDD", "vFDD", "VCD-DVD")]
        [string]$BootDevice = 'Normal', 
        [Switch]$NoProxy
	)

    If ($PSBoundParameters['Hostname']) {
        $Ip_Idrac = [system.net.dns]::Resolve($Hostname).AddressList.IPAddressToString
    }

    Switch ($PsCmdlet.ParameterSetName) {
        Creds {
            $WebRequestParameter = @{
                Headers = @{"Accept"="application/json"}
                Credential = $Credential
                Method = 'Post'
                ContentType = 'application/json'
            }
        }

        Session {
            $WebRequestParameter = @{
                Headers = $Session.Headers
                Method = 'Post'
            }
            $Ip_Idrac = $Session.IPAddress
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

    $JsonBody = @{
        "ShareParameters" = @{
            "Target"="ALL"
        }
        "ImportBuffer" = "<SystemConfiguration><Component FQDD='iDRAC.Embedded.1'>
        <Attribute Name='ServerBoot.1#BootOnce'>Enabled</Attribute>
        <Attribute Name='ServerBoot.1#FirstBootDevice'>$BootDevice</Attribute>
        </Component></SystemConfiguration>"} | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

    $Uri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Actions/Oem/EID_674_Manager.ImportSystemConfiguration"
    $WebRequestParameter.Uri = $Uri


# POST command to import or export server configuration profile file

    Try {
        $PostResult = Invoke-WebRequest @WebRequestParameter
    } Catch {
        Throw $_
    }

    $LocationLine = $PostResult.RawContent.split([Environment]::NewLine) -match 'Location'
    $Location = $LocationLine.Split(": ")[2]
    $u3 = "https://$Ip_Idrac$location"
    $WebRequestParameter.Uri = $u3
    $WebRequestParameter.Method = 'Get'
    $WebRequestParameter.Remove('Body')
    $Task_Id = [uri]::new($u3).Segments[-1]

    If ($PostResult.StatusCode -eq 202) {
        Write-Verbose -Message $([String]::Format("Statuscode {0} returned to successfully create Server Configuration Profile(SCP) import job: {1}",$post_result.StatusCode,$Task_Id))
    } Else {
        Throw $([String]::Format("Statuscode {0} returned",$PostResult.StatusCode))
    }

    $start_time = [datetime]::Now
    $end_time = $start_time.AddMinutes(5)
    Remove-Variable overall_job_output -ea 0

    While ( $overall_job_output.TaskState -ne 'Completed' ) {
        $loop_time = [datetime]::Now
        $GetResult = Invoke-WebRequest @WebRequestParameter

        If ($GetResult.StatusCode -eq 200) {
            $overall_job_output = $GetResult.RawContent.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)[-1] | ConvertFrom-Json
            
            If ($overall_job_output.Messages.MessageID -contains 'SYS067') {
                $O_IdracOTB = [PSCustomObject]@{
                'State' = $overall_job_output.TaskState
                'Message' = $overall_job_output.Name
                'Information' = $overall_job_output.Messages.Message
            }

	        Return $O_IdracOTB

            }
        }
        If ($loop_time -gt $end_time) {
            Throw $([String]::Format("{0} job ID failed, timeout has been reached, current job status is {1}",$Task_Id, $overall_job_output.TaskState))
        }
        Start-Sleep 5

    }

# Manage reboot forced
    # Get current power status
        $u4 = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/"
        $WebRequestParameter.Uri = $u4
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

        $u6 = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/Actions/ComputerSystem.Reset"
        $WebRequestParameter.Uri = $u6

        $PostResult3 = Invoke-WebRequest @WebRequestParameter

        If ($PostResult3.StatusCode -eq 204) {
            Write-Verbose -Message $([String]::Format("Statuscode {0} returned successfully to power ON the server",$PostResult3.StatusCode))
            Start-Sleep 10
        } Else {
            Throw $([String]::Format("- FAIL, statuscode {0} returned",$PostResult3.StatusCode))
        }

    $O_IdracOTB = [PSCustomObject]@{
        'State' = $overall_job_output.TaskState
        'Message' = $overall_job_output.Name
        'Information' = $overall_job_output.Messages.Message
    }

	Return $O_IdracOTB

}


Export-ModuleMember Invoke-RacOneTimeBoot