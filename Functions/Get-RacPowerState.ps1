<#
.Synopsis
   Cmdlet used to get power state using REDFISH API.

.DESCRIPTION
   Cmdlet used to get power state of a remote system using REDFISH API.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

Specifies the password for Idrac connection.

.EXAMPLE
    Get-RacPowerState -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin

    This example returns current power state of remote system behind 192.168.0.120

.LINK
    Set-RacPowerState

#>
Function Get-RacPowerState {
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
   
   # Send the request to Idrac

    $u = "https://$ip_idrac/redfish/v1/Systems/System.Embedded.1/"
    $WebRequestParameter.Uri = $u

    Try {
        $GetResult = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Throw $_
    }

# Return result
    Return $GetResult.PowerState

}


Export-ModuleMember Get-RacPowerState