Function Repair-RacBadGateway {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern("idrac-\w+\.idrac.boursorama.fr")]
        [string]$Hostname,
        [Parameter(Mandatory=$true)]
        [pscredential]$Credential,
        [Switch]$NoProxy
    )

    $WebRequestParameter = @{
        Headers = @{"Accept"="application/json"}
        Method = 'Get'
        ContentType = 'application/json'
        Uri = "Https://$Hostname"
    }

    If (! $NoProxy) { Set-myProxyAsDefault -Uri "Https://$Hostname" | Out-null }
    Else {
        Write-Verbose "No proxy requested"
        $Proxy = [System.Net.WebProxy]::new()
        $WebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $WebSession.Proxy = $Proxy
        $WebRequestParameter.WebSession = $WebSession
        If ($PSVersionTable.PSVersion.Major -gt 5) { $WebRequestParameter.SkipCertificateCheck = $true }
    }

    Try {

        Invoke-RestMethod @WebRequestParameter | Out-Null
        Write-Host "I dono whad do do."

    } Catch {
        If ($_.Exception.Message -match "400") {
            $IP = [System.Net.Dns]::Resolve($Hostname).AddressList.IPAddressToString

            Set-RacManagerAttribute -Ip_Idrac $IP -Credential $Credential -Attribute 'WebServer.1.ManualDNSEntry' -Value "$IP,$Hostname" -Verbose
        } Else {
            throw $_
        }
    }
}
 
 Export-ModuleMember Repair-RacBadGateway