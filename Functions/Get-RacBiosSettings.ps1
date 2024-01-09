<#
.Synopsis
   Cmdlet used to get BIOS attributes using REDFISH API.

.DESCRIPTION
   Cmdlet used to get BIOS attributes using REDFISH API.

   The remote system will be either restarted if restart switch is specified,
   then the script will wait until the job is done, or return job id.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

Specifies the password for Idrac connection.

.EXAMPLE
    Get-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin

    This example displays all BIOS attributes.


.LINK
    Get-RacPendingBiosSettings
    Register-RacBiosSettings
    Submit-RacPendingBiosSettings

.NOTES
   Cmdlet used to get all BIOS attributes. to register one or more attributes,
   you have to use Register-RacBiosSettings cmdlet


#>
Function Get-RacBiosSettings {
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

    $WebRequestParameter.Uri = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/Bios"

    Try {
        $GetResult = Invoke-RestMethod @WebRequestParameter
    } Catch  {
        Throw $_
    }

    Return $GetResult.Attributes

}

Export-ModuleMember Get-RacBiosSettings