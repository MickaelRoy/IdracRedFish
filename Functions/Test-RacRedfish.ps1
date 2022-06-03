Function Test-RacRedfish {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true)]
        [string]$Ip_Idrac
	)

    Try {
        $u = "https://$Ip_Idrac/redfish/v1"
        $GetResult = Invoke-RestMethod -Uri $u -Method Get -ContentType 'application/json' -Headers @{"Accept"="application/json"}
    } Catch {
        Return $False
    }
    Return $True
} 

Export-ModuleMember Test-RacRedfish
