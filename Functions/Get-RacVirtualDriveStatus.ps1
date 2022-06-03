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
    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, ParameterSetName = "Creds")]
        [string]$Ip_Idrac,
        [Parameter(Mandatory=$true, ParameterSetName = "Creds")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true, ParameterSetName = "Session")]
        [PSCustomObject]$Session
	)

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
# Send the request to Idrac
    Write-Verbose -Message "Getting network ISO attach information for iDRAC $Ip_Idrac"
    $u = "https://$Ip_Idrac/redfish/v1/Dell/Systems/System.Embedded.1/DellOSDeploymentService/Actions/DellOSDeploymentService.GetAttachStatus"
    $WebRequestParameter.Uri = $u
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