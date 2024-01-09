<#
.Synopsis
   Cmdlet used to set one BIOS attribute of BIOS attributes using REDFISH API.

.DESCRIPTION
   Cmdlet used to set one BIOS attribute of BIOS attributes using REDFISH API.

.PARAMETER Ip_Idrac

Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

Specifies the password for Idrac connection.

.PARAMETER Name

Specifies the bios attribute name

.PARAMETER Value

Specifies the bios attribute value

.EXAMPLE
    Register-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Name SysProfile -Value PerfOptimized

    This example set setting BIOS attribute "System Profile" to Performance

.EXAMPLE
    Register-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Name WorkloadProfile -Value VtOptimizedProfile

    This example set setting BIOS attribute "Workload Profile" to "Virtualization Optimized Performance Profile"

.EXAMPLE
    Register-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Name BootMode -Value Uefi

    This example set setting BIOS attribute "BootMode" to "Uefi"

.EXAMPLE
    Register-RacBiosSettings -RacUser root -RacPwd 'calvin'-Name 'Slot1' -Value 'Disabled' -Ip_Idrac 192.168.0.120
    
.LINK
    Get-RacPendingBiosSettings
    Submit-RacPendingBiosSettings
    Get-RacBiosSettings

.NOTES
   Cmdlet used to either set one BIOS attribute..
   To register one or more attributes, you have to use Register-RacBiosSettings cmdlet
   When registering a BIOS attribute, make sure you pass in exact name of the attribute 
   and value since these are case sensitive.
   Example: For attribute MemTest, you must pass in "MemTest". Passing in "memtest" will fail.

   To apply one or more attributes, you have to use Submit-RacBiosSettings cmdlet.

#>
Function Register-RacBiosSettings {
    [CmdletBinding(DefaultParameterSetName = 'Host')]
    param(
        [Parameter(ParameterSetName = 'Ip', Mandatory = $true, Position = 0)]
        [Alias("idrac_ip")]
        [ValidateNotNullOrEmpty()]
        [IpAddress]$Ip_Idrac,

        [Parameter(ParameterSetName = 'Host', Mandatory = $true, Position = 0)]
        [Alias("Server")]
        [ValidateNotNullOrEmpty()]
        [string]$Hostname,

        [Parameter(ParameterSetName = 'Ip', Mandatory = $true, Position = 1)]
        [Parameter(ParameterSetName = 'Host', Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = 'Session', Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$Session,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$Value, 

        [Switch]$NoProxy
	)

    If ($PSBoundParameters['Hostname']) {
        $Ip_Idrac = [system.net.dns]::Resolve($Hostname).AddressList.IPAddressToString
    }

    Switch ($PsCmdlet.ParameterSetName) {
        Session {
            Write-Verbose -Message "Entering Session ParameterSet"
            $WebRequestParameter = @{
                Headers = $Session.Headers
                Method  = 'Get'
            }
            $Ip_Idrac = $Session.IPAddress
        }
        Default {
            Write-Verbose -Message "Entering Credentials ParameterSet"
            $WebRequestParameter = @{
                Headers     = @{"Accept" = "application/json" }
                Credential  = $Credential
                Method      = 'Get'
                ContentType = 'application/json'
            }
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
    $u1 = "https://$Ip_Idrac/redfish/v1/Systems/System.Embedded.1/Bios/Settings"
    $WebRequestParameter.Uri = $u1
    If ($Value -match "^[\d\.]+$") {
        $value = $Value -as [int]
    }

    $JsonBody = @{ 
        Attributes = @{
            "$Name" = $Value
        }
    } | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

# PATCH command to set attribute pending value
    Try {
        $PatchResult = Invoke-WebRequest @WebRequestParameter
    } Catch {
        Throw $_
    }

    If ($PatchResult.StatusCode -eq 200) {
        Write-Verbose -Message $([String]::Format("Statuscode {0} returned to successfully set attribute pending value",$PatchResult.StatusCode))
    } Else {
        Throw $([String]::Format("Statuscode {0} returned",$PatchResult.StatusCode))
    }

}

Export-ModuleMember Register-RacBiosSettings