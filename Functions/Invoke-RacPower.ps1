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
    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, ParameterSetName = "Creds")]
        [string]$Ip_Idrac,
        [Parameter(Mandatory=$true, ParameterSetName = "Creds")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true, ParameterSetName = "Session")]
        [PSCustomObject]$Session,
        [Parameter(Mandatory=$false)]
        [ValidateSet("On", "ForceOff", "ForceRestart", "GracefulShutdown")]
        [string]$Action = 'On'
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
    <#
        $JsonError = ($_.ErrorDetails.Message | ConvertFrom-Json).error
        If ( [String]::IsNullOrEmpty($JsonError.'@Message.ExtendedInfo') ) {
            Throw $([String]::Format("{0} - $($JsonError.'@Message.ExtendedInfo'.Message)",$_.Exception.Response.StatusCode.value__))

        }
    #>
        Throw $_
    }
}


Export-ModuleMember Set-RacPowerState