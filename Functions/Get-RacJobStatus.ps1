Function Get-RacJobStatus {
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
        [Parameter(Mandatory=$true)]
        [String]$JobId,
        [Parameter(Mandatory=$true, ParameterSetName = "Creds")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true, ParameterSetName = "Session")]
        [PSCustomObject]$Session, 
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
                Method = 'Get'
                ContentType = 'application/json'
            }
        }

        Session {
            $WebRequestParameter = @{
                Headers = $Session.Headers
                Method = 'Get'
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

    $WebRequestParameter.uri = "https://$Ip_Idrac/redfish/v1/TaskService/Tasks/$JobId"
    $WebRequestParameter.Method = 'Get'

    $GetJobResult = Invoke-WebRequest @WebRequestParameter -ErrorAction Stop

    $overall_job_output = $GetJobResult.Content | ConvertFrom-Json


    Return $overall_job_output
}

Export-ModuleMember Get-RacJobStatus
