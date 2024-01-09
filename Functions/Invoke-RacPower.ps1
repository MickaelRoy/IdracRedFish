<#
.Synopsis
   Cmdlet used to change power state using REDFISH API.

.DESCRIPTION
   Cmdlet used to change power state of a remote system using REDFISH API.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

Specifies the password for Idrac connection.

.EXAMPLE
    Set-RacPowerState -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Action On

    This example returns power On the remote system behind 192.168.0.120

.LINK
    Invoke-RacPower

#>

Function Set-RacPowerState {
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
        [ValidateSet("On", "ForceOff", "ForceRestart", "GracefulShutdown")]
        [string]$Action = 'On',

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

# Payload creation for Idrac request
    $JsonBody = @{ 
        "ResetType" = $Action
    } | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

# Send the request to Idrac
    Write-Verbose -Message "Invoke power command on $Ip_Idrac"
    $Uri = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/Actions/ComputerSystem.Reset"
    $WebRequestParameter.Uri = $Uri


    Try {
        $PostResult = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Throw $_
    }
}


Export-ModuleMember Set-RacPowerState