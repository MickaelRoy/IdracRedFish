<#
.Synopsis
   Cmdlet used to get BIOS pending changes using REDFISH API.

.DESCRIPTION
   Cmdlet used to get BIOS pending changes using REDFISH API.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

Specifies the password for Idrac connection.

.EXAMPLE
    Get-RacPendingBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin

    This example lists all registered bios pending changes.

.LINK
    Register-RacBiosSettings
    Submit-RacPendingBiosSettings
    Get-RacBiosSettings

.NOTES
   To register one or more attributes, you have to use Register-RacBiosSettings cmdlet
   To apply one or more attributes, you have to use Submit-RacBiosSettings cmdlet.

#>
Function Get-RacPendingBiosSettings {
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
        [Switch]$NoProxy
	)

    If ($PSBoundParameters['Hostname']) {
        $Ip_Idrac = [System.Net.Dns]::Resolve($Hostname).AddressList.IPAddressToString
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

    $WebRequestParameter.Uri = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/Bios/Settings"

    Try {
        $Result = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Throw $_
    }
    
    Return $Result.Attributes
}

Export-ModuleMember Get-RacPendingBiosSettings