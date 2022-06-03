<#
.Synopsis
   Delete a persistent connection to an Idrac using REDFISH API.

.DESCRIPTION
   Delete a persistent connection to an Idrac using REDFISH API.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER Credential

Specifies the credential for Idrac connection.

.PARAMETER Type

Specifies Content type for Invoke-Webrequest ("application/json" by default).

.OUTPUTS
System.Management.Automation.PSCustomObject

.EXAMPLE
    $session = Remove-RacSession -session $session
    This example deletes a session from $session variable

.EXAMPLE
    $session = $session | Remove-RacSession
    This example deletes a session from $session variable

.LINK
    New-RacSession

.NOTES
    Becarefull of session expiration on Idrac end.
    When session expires, you may get this erro "The underlying connection was closed..."
    Expired sessions are kept stuck in idrac.
#>
Function Remove-RacSession {
    [CmdletBinding(DefaultParametersetname="null")]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = "Session")]
        [System.Object[]] $Session,
        
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "InstanceId")]
        [SupportsWildCards()]
        [String] $InstanceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SessionUri")]
        [String] $SessionUri,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Id")]
        [Alias('Index')]
        [int] $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "All")]
        [Switch] $All
    )

    Begin {
        Function Remove-SessionFromIdrac {
            [CmdletBinding()]
            Param (
                [Parameter(Mandatory = $true, ValueFromPipeline= $false, Position  = 0)]
                $Objects
            )

                Remove-Variable ValidObject, Item, Headers -ea 0
                $TestGet = 0

                Write-Verbose -Message 'looking for a valid token'
                
                Foreach ($Item in $Objects) {
                    $Uri = [Uri]::new($Item.SessionUri)
                    $SessionUrl = $Uri.AbsoluteUri.Remove($Uri.AbsoluteUri.Length - $Uri.Segments[-1].Length)
                    $Headers =  $Item.Headers

                    Try { 
                        Write-Verbose -Message "Trying with token $($Headers.'X-Auth-Token')"
                        $TestGet = Invoke-WebRequest -Method Get -UseBasicParsing -Headers $Headers -Uri $SessionUrl
                    } Catch { 
                        Write-Verbose -Message "$($_.Exception.Response.StatusCode.Value__) access denied with this token, unregistering..."
                        If ($Global:RacSessionCollection.Remove($Item[0])) { Write-Verbose "REMOVED" }
                    }

                    If ( $TestGet.StatusCode -eq 200 ) {

                        Write-Verbose -Message "$($TestGet.StatusCode) Valid Token found"
                        Write-Verbose -Message "$($Item.SessionUri) - $($Item.Headers.'X-Auth-Token')"
                        
                        $ValidObject = $Item[0]
                        Break
                    }
                }

                If ( $null -eq $ValidObject  ) { Throw "No valid Token found" }

                Try {

                    $ObjectstoRemove = $Objects.Where({ $_.SessionUri -ne $ValidObject.SessionUri })

                    $ObjectstoRemove.ForEach({
                        $CurrentObject = $PSItem
                        $DeleteUrl1 = $PSItem.SessionUri.AbsoluteUri

                        Write-Verbose -Message "Removing $DeleteUrl1"
                        Try {
                            $DelResult1 = Invoke-WebRequest -Method Delete -UseBasicParsing -Headers $Headers -Uri $DeleteUrl1 -ErrorVariable errRest
                            If ( $DelResult1.StatusCode -eq 200 ) { 
                                Write-Verbose -Message "$DeleteUrl1 successfuly removed, unregistering"
                                If ($Global:RacSessionCollection.Remove($CurrentObject[0])) { Write-Verbose "REMOVED" }
                            }
                        } Catch {
                            Switch ($_.Exception.Response.StatusCode.Value__) {
                                401 {

                                    Write-Verbose -Message "$($_.Exception.Response.StatusCode.Value__) This token no longer valid, unregistering"
                                    $CurrentObject[0]
                                    If ($Global:RacSessionCollection.Remove($CurrentObject[0])) { Write-Verbose "REMOVED" }
                                } 
                                
                                404 {

                                    Write-Verbose -Message "$($_.Exception.Response.StatusCode.Value__) This session no longer exist on remote, unregistering"
                                    If ($Global:RacSessionCollection.Remove($CurrentObject)) { Write-Verbose "REMOVED" }
                                }

                                Default {

                                    $($_.Exception.Response.StatusCode.Value__)
                                }
                            }

                        }

                    })

                    $LastObjecttoRemove = $ValidObject
                    $DeleteUrl2 = $LastObjecttoRemove.SessionUri.AbsoluteUri
                    Write-Verbose -Message "Removing last $DeleteUrl2"
                    Try {
                        $DelResult2 = Invoke-WebRequest -Method Delete -UseBasicParsing -Headers $Headers -Uri $DeleteUrl2 -ErrorVariable errRest
                        If ( $DelResult2.StatusCode -eq 200 ) {
                            Write-Verbose -Message "REMOVED - $DeleteUrl2"
                            [void]$Global:RacSessionCollection.Remove($LastObjecttoRemove)
                        }
                    } Catch {
                        ($_.Exception.Response.StatusCode.Value__)
                    }

                } Catch {
                      $_
                }

            }
        
        Remove-Variable Objects -ea 0
        $AllObjects = [System.Collections.ArrayList]::new()


    } Process {

        If (( $null -eq $Global:RacSessionCollection ) -or ( $Global:RacSessionCollection.Count -eq 0 )) { Return }

        Switch ($PsCmdlet.ParameterSetName) {

            All { Write-Verbose -Message "All Detected !" ; $Objects = $Global:RacSessionCollection }

            Session { Write-Verbose -Message "Session Lookup" ; $Objects = $Session }

            Id { Write-Verbose -Message "Id Lookup" ; $Objects = $Global:RacSessionCollection.Item($id) }

            InstanceId { Write-Verbose -Message "InstanceId Lookup: $InstanceId" ; $Objects = $Global:RacSessionCollection.Where({ $_.InstanceId -like $InstanceId }) }

            SessionUri { Write-Verbose -Message "SessionUri Lookup: $SessionUri" ; $Objects = $Global:RacSessionCollection.Where({ $_.SessionUri -like $SessionUri }) }

        }

        If ( $MyInvocation.ExpectingInput ) { [Void]$AllObjects.Add($Objects)  }
        Else { $AllObjects = $Objects }

    } End {
        If ($AllObjects.Count -gt 0) {
            Write-Verbose -Message "Removing $($AllObjects.Count) session(s) from idrac" 
            Remove-SessionFromIdrac $AllObjects
        } Else {
            Write-Verbose -Message 'No more session registered in $Global:RacSessionCollection variable'
        }
    }
}

Export-ModuleMember Remove-RacSession
