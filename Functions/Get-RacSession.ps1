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
Function Get-RacSession {
    [CmdletBinding(DefaultParametersetname="null")]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "InstanceId")]
        [SupportsWildCards()]
        [String] $InstanceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SessionUri")]
        [String] $SessionUri,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Id")]
        [int] $Id
    )

    Begin {

    } Process {

        If (( $null -eq $Global:RacSessionCollection ) -or ( $Global:RacSessionCollection.Count -eq 0 )) { Return }

        Switch ($PsCmdlet.ParameterSetName) {

            InstanceId { Write-Verbose -Message "InstanceId Lookup" ; $Objects = $Global:RacSessionCollection.Where({ $_.InstanceId -like $InstanceId }) }

            SessionUri { Write-Verbose -Message "SessionUri Lookup" ; $Objects = $Global:RacSessionCollection.Where({ $_.SessionUri -like $SessionUri }) }

            Id { Write-Verbose -Message "Id Lookup" ; $Objects = $Global:RacSessionCollection.Item($id) }

            null { Write-Verbose -Message "null Lookup" ; $Objects = $Global:RacSessionCollection }

        }
    } End {

        #$Objects | Foreach { $_.PsTypeNames.Insert(0,'racRedFish.racSession') }
       If ($Objects.Count -gt 0)  { Return $Objects }

    }
}

Export-ModuleMember Get-RacSession
