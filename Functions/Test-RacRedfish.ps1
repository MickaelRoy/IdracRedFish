Function Test-RacRedfish {
    [CmdletBinding(DefaultParameterSetName='Host')]
	param(
        [Parameter(Mandatory=$true, ParameterSetName='Ip')]
        [Alias("idrac_ip")]
        [IpAddress]$Ip_Idrac,

        [Parameter(Mandatory=$true, ParameterSetName='Host')]
        [Alias("Server")]
        [string]$Hostname,

        [Switch]$NoProxy

	)
    If ($PSBoundParameters['Hostname']) {
        $Ip_Idrac = [system.net.dns]::Resolve($Hostname).AddressList.IPAddressToString
    }

    $WebRequestParameter = @{
        Headers = @{"Accept"="application/json"}
        Method = 'Get'
        ContentType = 'application/json'
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

    Try {
        $WebRequestParameter.Uri = "https://$Ip_Idrac/redfish/v1"
        $GetResult = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Return $False
    }
    Return $True
} 

Export-ModuleMember Test-RacRedfish
