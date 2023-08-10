﻿<#
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