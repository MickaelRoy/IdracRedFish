Function Import-RacTemplate {
    [CmdletBinding(DefaultParameterSetName = 'Host')]
    param(
        [Parameter(ParameterSetName = "Creds")]
        [Parameter(Mandatory = $true, ParameterSetName = 'Ip')]
        [Alias("idrac_ip")]
        [IpAddress]$Ip_Idrac,

        [Parameter(ParameterSetName = "Creds")]
        [Parameter(Mandatory = $true, ParameterSetName = 'Host')]
        [Alias("Server")]
        [string]$Hostname,

        [Parameter(Mandatory = $true, ParameterSetName = "Creds")]
        [pscredential]$Credential,

        [Parameter(Mandatory = $true, ParameterSetName = "Session")]
        [PSCustomObject]$Session,

        [Parameter(mandatory=$true, HelpMessage="Path to template." )]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist" 
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
                return $true
        })]
        [Alias("TP")]
        [string]$TemplatePath,

        [Parameter(Mandatory=$False)]
        [ValidateSet("ALL", "IDRAC", "BIOS")]
        [string]$Target = 'ALL',

        [Parameter(Mandatory=$False)]
        [ValidateSet("Graceful", "Forced", "NoReboot")]
        [string]$ShutdownType,

        [Parameter(Mandatory=$False)]
        [ValidateSet("On", "Off")]
        [string]$HostPowerState
    )

    If ($PSBoundParameters['Hostname']) {
        $Ip_Idrac = [system.net.dns]::Resolve($Hostname).AddressList.IPAddressToString
    }

    Switch ($PsCmdlet.ParameterSetName) {
        Creds {
            $WebRequestParameter = @{
                Headers     = @{"Accept" = "application/json" }
                Credential  = $Credential
                Method      = 'Post'
                ContentType = 'application/json'
            }
        }

        Session {
            $WebRequestParameter = @{
                Headers = $Session.Headers
                Method  = 'Post'
            }
            $Ip_Idrac = $Session.IPAddress
        }
    }

  #region Proxy
    If (! $NoProxy) { Set-myProxyAsDefault -Uri "Https://$Ip_Idrac" | Out-null }
    Else {
        Write-Verbose "No proxy requested"
        $Proxy = [System.Net.WebProxy]::new()
        $WebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $WebSession.Proxy = $Proxy
        $WebRequestParameter.WebSession = $WebSession
        If ($PSVersionTable.PSVersion.Major -gt 5) { $WebRequestParameter.SkipCertificateCheck = $true }
    }
  #endregion Proxy



    $SCP_file = Get-Content $TemplatePath
    $share_info = @{"ImportBuffer"=[string]$SCP_file;"ShareParameters"=@{"Target"=$Target}}

    Switch ($PSBoundParameters.Keys) {
        'ShutdownType' { $share_info["ShutdownType"] = $ShutdownType }
        'HostPowerState' { $share_info["HostPowerState"] = $HostPowerState }
    }

    $JsonBody = $share_info | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

    $full_method_name="EID_674_Manager.ImportSystemConfiguration"
    $PostUri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Actions/Oem/$full_method_name"
    $WebRequestParameter.Uri = $PostUri
    
    Try {
        $PostResult = Invoke-WebRequest @WebRequestParameter
        $get_job_id_location = $PostResult.Headers.Location
        $JobId = $get_job_id_location.Split('/')[-1]
    }
    Catch {
        Throw $_
    }


    $GetUri = "https://$Ip_Idrac$get_job_id_location"
    $WebRequestParameter.Uri = $GetUri
    $WebRequestParameter.Method = 'Get'
    $WebRequestParameter.Remove('Body')

    Try {
        $GetResult = Invoke-RestMethod @WebRequestParameter
        If ($GetResult.TaskStatus -eq 'OK') {
            If ($ShutdownType -eq 'NoReboot') {
                Write-Host "You have choosen to prevent the reboot, please reboot the server to apply the configuration."
                Write-Host "You can trigger a restart with command `n`tSet-RacPowerState Ip_Idrac $Ip_Idrac -Credential `$Credential -Action GracefulShutdown"
                Write-Host "As well, you can follow the Job progress with the command `n`tGet-RacJobStatus -Ip_Idrac $Ip_Idrac -Credential `$Credential -JobId $JobId"
            } Else {
                Write-Host "You have choosen to trigger the reboot. Please wait a while."
                Write-Host "You can follow the Job progress with the command `n`tGet-RacJobStatus -Ip_Idrac $Ip_Idrac -Credential `$Credential -JobId $JobId"
            }
        } Else {
            Write-Error -Message "En error occured during the import, please check LifeCycle log for more details"
        }
    }
    Catch {
        Throw $_
    }

}

Export-ModuleMember Import-RacTemplate