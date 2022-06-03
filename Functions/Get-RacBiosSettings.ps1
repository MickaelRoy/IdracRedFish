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

    $u = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/Bios"
    $WebRequestParameter.Uri = $u
    Write-Debug $WebRequestParameter
    Try {
        $GetResult = Invoke-RestMethod @WebRequestParameter
    } Catch  {
        Throw $_
    }

    Return $GetResult.Attributes

}

Export-ModuleMember Get-RacBiosSettings