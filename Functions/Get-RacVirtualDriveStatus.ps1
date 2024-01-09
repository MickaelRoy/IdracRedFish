<#
.Synopsis
   Cmdlet used to get virtual drive attachement status using REDFISH API.

.DESCRIPTION
   Cmdlet used to get virtual drive attachement status using REDFISH API.
   Usualy this cmdlet is used to check wether Iso is attached to RFS.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

Specifies the password for Idrac connection.

.OUTPUTS
System.String

.EXAMPLE
    Get-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin

    This example returns attachment status.

.LINK
    Invoke-RacBootToNetworkISO
    Dismount-RacVirtualDrive

.NOTES
   Cmdlet used to get remote file system attachement. 
   To connect, attach and boot on Iso image, you have to use 
   Invoke-RacBootToNetworkISO cmdlet
#>
Function Get-RacVirtualDriveStatus {
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

# Send the request to Idrac
    Write-Verbose -Message "Getting network ISO attach information for iDRAC $Ip_Idrac"
    $WebRequestParameter.Uri = "https://$Ip_Idrac/redfish/v1/Dell/Systems/System.Embedded.1/DellOSDeploymentService/Actions/DellOSDeploymentService.GetAttachStatus"
    $JsonBody = @{} | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

    Try {
        $PostResult = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Throw $_
    }

    Return $PostResult.ISOAttachStatus

}

Export-ModuleMember Get-RacVirtualDriveStatus