Function Get-RacModel {
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

        [Switch]$NoProxy
    )

    If ($PSBoundParameters['Hostname']) {
        $Ip_Idrac = [system.net.dns]::Resolve($Hostname).AddressList.IPAddressToString
    }

    Switch ($PsCmdlet.ParameterSetName) {
        Creds {
            $WebRequestParameter = @{
                Headers     = @{"Accept" = "application/json" }
                Credential  = $Credential
                Method      = 'Get'
                ContentType = 'application/json'
            }
        }

        Session {
            $WebRequestParameter = @{
                Headers = $Session.Headers
                Method  = 'Get'
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

    Try {
        $WebRequestParameter.uri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1"
        $GetResult = Invoke-RestMethod @WebRequestParameter
        $Model = $GetResult.Model.Substring(0,2)
        If ( $Model -match "\d" ) { Return "$Model" + "G" }
        Else {
            Throw "Unable to parse system model"
        }
    } Catch {

        Throw $_

    }
}

Export-ModuleMember Get-RacModel