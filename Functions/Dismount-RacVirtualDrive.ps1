<#
.Synopsis
   Cmdlet used to diconnect virtual drive using REDFISH API.

.DESCRIPTION
   Cmdlet used to diconnect virtual drive using REDFISH API.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

Specifies the password for Idrac connection.

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
    Dismount-RacVirtualDrive -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin

    This example disconnect ISO from the virtual drive.

.LINK
    Invoke-RacBootToNetworkISO
    Get-RacVirtualDriveStatus

.NOTES
   Cmdlet used to get remote file system attachement. 
   To connect, attach and boot on Iso image, you have to use 
   Invoke-RacBootToNetworkISO cmdlet
#>
Function Dismount-RacVirtualDrive {
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
                    ErrorVariable = 'RespErr'
                }
            }

            Session {
                $WebRequestParameter = @{
                    Headers = $Session.Headers
                    Method = 'Post'
                    ErrorVariable = 'RespErr'
                }
                $Ip_Idrac = $Session.IPAddress
            }
            
        }

    $CheckUri = "https://$Ip_Idrac/redfish/v1/Dell/Systems/System.Embedded.1/DellOSDeploymentService/Actions/DellOSDeploymentService.GetAttachStatus"
    $DettachUri = "https://$Ip_Idrac/redfish/v1/Dell/Systems/System.Embedded.1/DellOSDeploymentService/Actions/DellOSDeploymentService.DetachISOImage"

# First Check
    
    Switch ($PsCmdlet.ParameterSetName) {
        Creds { $CheckResult = Get-RacVirtualDriveStatus -Credential $Credential -Ip_Idrac $Ip_Idrac }
        Session { $CheckResult = Get-RacVirtualDriveStatus -Session $Session }
    }

    Write-Verbose -Message "Current Status is: $CheckResult"

    If ($CheckResult -eq "NotAttached") {
        Return "Iso Attach Status is $($CheckResult), Nothing to do"
    } 

# Send the request to Idrac
    Write-Verbose -Message "Detaching network ISO for iDRAC $Ip_Idrac"
    $WebRequestParameter.Uri = $DettachUri
    $JsonBody = @{} | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

    Try {
        $DetachResult = Invoke-RestMethod @WebRequestParameter
    } Catch  {
        Throw $_
    }

# Loop to receive the result from Idrac

    Write-Verbose -Message $([String]::Format("POST command passed to detach network ISO, verifying attach status"))

    $WebRequestParameter.Uri = $CheckUri
    Try {
        $CheckResult = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Throw $_
    }

    If ($CheckResult.ISOAttachStatus -eq "NotAttached") {
        Return $CheckResult.'@Message.ExtendedInfo'.Message
    } Else {
        Write-Error -Message $([String]::Format("`FAIL, network ISO is not detached, current status is: {0}", $CheckResult.ISOAttachStatus))
    }

}

Export-ModuleMember Dismount-RacVirtualDrive