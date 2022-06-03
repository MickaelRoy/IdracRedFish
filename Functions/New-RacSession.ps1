<#
.Synopsis
   Creates a persistent connection to an Idrac using REDFISH API.

.DESCRIPTION
   Creates a persistent connection to an Idrac using REDFISH API.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER Credential

Specifies the credential for Idrac connection.

.PARAMETER Type

Specifies Content type for Invoke-Webrequest ("application/json" by default).

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
    $session = New-RacSession -Ip_Idrac 10.117.24.166 -Credential $Credential
    This example creates a session and stores detail in $session variable

.LINK
    Remove-RacSession

.NOTES
    Becarefull of session expiration on Idrac end.
    When session expires, you may get this erro "The underlying connection was closed..."
    Expired sessions are kept stuck in idrac.
#>
Function New-RacSession {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [String] $Ip_Idrac,

        [Parameter(Mandatory=$true)]
        [pscredential] $Credential,

        [Parameter()]
        [String] $Type = "application/json"
    )

    If ( -not [ipaddress]::TryParse($Ip_Idrac,[ref][ipaddress]::Loopback) ) { Throw 'Bad IP address format' }


    $UserName = $Credential.UserName
    $Password = $Credential.GetNetworkCredential().Password
    $UserDetails = @{ "UserName" = $UserName; "Password" = $Password } | ConvertTo-Json

    $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Headers.Add("Content-Type", "application/json")
    $Headers.Add("Accept", "application/json")
    
    Try {

        $SessionUrl = "https://$Ip_Idrac/redfish/v1/SessionService/Sessions/" 
        $SessResponse = Invoke-WebRequest $SessionUrl -Method 'POST' -Headers $Headers -Body $UserDetails -ContentType $Type

    } Catch {
        
        Try {

            $SessionUrl = "https://$Ip_Idrac/redfish/v1/Sessions/"
            $SessResponse = Invoke-WebRequest $SessionUrl -Method 'POST' -Headers $Headers -Body $UserDetails -ContentType $Type

        } Catch {

        Throw $_
        
        }
    }
    If ( $SessResponse.StatusCode -eq 201 ) {

        $Sessheaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $Sessheaders.Add("Content-Type", "application/json")
        $Sessheaders.Add("Accept", "application/json")
        $Sessheaders.Add("X-Auth-Token", $SessResponse.Headers['X-Auth-Token']  )
        $Sessheaders.Add("OData-Version", $SessResponse.Headers['OData-Version'] )

        $Script:Object = [PSCustomObject] @{
            IPAddress = $Ip_Idrac
            SessionUri = ([System.UriBuilder]::new('https', $Ip_Idrac, 443, "$($SessResponse.Headers.Location)" )).Uri
            Headers = $Sessheaders
        }
        $Script:Object.PsTypeNames.Insert(0,'racRedFish.racSession')

        If ( $null -eq $Global:RacSessionCollection ) {

            Write-Verbose -Message "Creating new object"

            $Global:RacSessionCollection = [System.Collections.ObjectModel.Collection[System.Object]]::new()

        }
        If (( $Global:RacSessionCollection.Count -eq 0 ) -or ($Global:RacSessionCollection.IndexOf($Script:Object) -eq -1)) {
            
            Write-Verbose -Message "Registering new Session"

            $Script:Object | Add-Member -NotePropertyName InstanceId -NotePropertyValue ([guid]::NewGuid().Guid)
            [Void]$Global:RacSessionCollection.Add($Script:Object)
            $I = $Global:RacSessionCollection.IndexOf($Script:Object)
            $Global:RacSessionCollection[$I] | Add-Member -NotePropertyName Index -NotePropertyValue $I

            Return $Global:RacSessionCollection[$I]

        } Else {

            Write-Verbose -Message "Alerting useless. for debuging"

        }

    } Else {

        Throw "Web Request fails with staut code $($SessResponse.StatusCode )"

    }
   
}

Export-ModuleMember New-RacSession
