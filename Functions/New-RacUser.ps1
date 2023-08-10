<#
.Synopsis
   Cmdlet used to create Idrac user using REDFISH API.

.DESCRIPTION
   Cmdlet used to create Idrac user using REDFISH API.

.PARAMETER Ip_Idrac

    Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

    Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

    Specifies the password for Idrac connection.

.PARAMETER NewUser

    Specifies the Username for the new account.

.PARAMETER NewPwd

    Specifies the password for the new account.

.PARAMETER Privilege

    Specifies the permission for the new account.
    Default is None

.PARAMETER Enabled

    Specifies wether the account have to be enabled.
    Default is true

.PARAMETER ExtendRights

    Specifies wether the account Privilege have to be extended to
    IpmiSerialPrivilege and IpmiLanPrivilege or not.
    Default is true

.PARAMETER IpmiSerialPrivilege

    Specifies the IpmiSerialPrivilege permission if not extended from usual
    Privilege.

.PARAMETER IpmiLanPrivilege

    Specifies the IpmiLanPrivilege permission if not extended from usual
    Privilege.

.PARAMETER SolEnable

    Specifies wether SerialOnLan have to be enabled.
    Default is true

.EXAMPLE
    New-RacUser -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -NewUser 'Admin' -NewPwd '[StrongPass]' -Privilege Administrator

    This example created a priviledged account

.LINK
    Set-RacUserPassword
    Remove-RacUser
    Get-RacUser

#>
Function New-RacUser {
    [CmdletBinding(DefaultParameterSetName='Host')]
	param(
		[Parameter(ParameterSetName = "Creds")]
        [Parameter(Mandatory=$true, ParameterSetName='Ip')]
        [Alias("idrac_ip")]
        [IpAddress]$Ip_Idrac,
		[Parameter(ParameterSetName = "Creds")]
        [Parameter(Mandatory=$true, ParameterSetName='Host')]
        [Alias("Server")]
        [string]$Hostname,

        [Parameter(Mandatory=$true, ParameterSetName = "Creds")]
        [pscredential]$Credential,

        [Parameter(Mandatory=$true, ParameterSetName = "Session")]
        [PSCustomObject]$Session,

        [Parameter(Mandatory=$true)]
        [string]$NewUser,

        [Parameter(Mandatory=$true)]
        [string]$NewPwd,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Administrator', 'Operator', 'ReadOnly','None')]
        [string]$Privilege = 'None', 

        [Parameter(Mandatory=$false)]
        [Switch]$Enabled = $true,

        [Parameter(Mandatory=$false)]
        [Switch]$ExtendRights = $true,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Administrator', 'Operator', 'ReadOnly','None')]
        [String]$IpmiSerialPrivilege,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Administrator', 'Operator', 'ReadOnly','None')]
        [String]$IpmiLanPrivilege,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Enabled', 'Disabled')]
        [String]$SolEnable = 'Enabled', 

        [Switch]$NoProxy
	)

    If ($PSBoundParameters['Hostname']) {
        $Ip_Idrac = [system.net.dns]::Resolve($Hostname).AddressList.IPAddressToString
    }

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

    If (! $NoProxy) { Set-myProxyAsDefault -Uri "Https://$Ip_Idrac" | Out-null }
    Else {
        Write-Verbose "No proxy requested"
        $Proxy = [System.Net.WebProxy]::new()
        $WebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $WebSession.Proxy = $Proxy
        $WebRequestParameter.WebSession = $WebSession
        If ($PSVersionTable.PSVersion.Major -gt 5) { $WebRequestParameter.SkipCertificateCheck = $true }
    }

# Built User list to get user's Id
    $GetUri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Accounts"
    $WebRequestParameter.Uri = $GetUri
    Try {
        $GetResult = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Throw $_
    }

# Looking for a free slot.
    $Members = $GetResult.Members
    $I = 1
    While (($null -eq $FreeSlot) -and ("$($GetResult.'@odata.id')/$I" -ne $Members.'@odata.id'[-1]) ) {
        
        $GetUri2 = "https://$Ip_Idrac$($GetResult.'@odata.id')/$I"
        $WebRequestParameter.Uri = $GetUri2
        $Account = Invoke-RestMethod @WebRequestParameter
        If (([String]::IsNullOrEmpty($Account.UserName)) -and ($Account.Id -ne 1)) {
            $FreeSlot = $Account.Id
        }

        $I++
    }

    Write-Verbose -Message $([String]::Format("User ID for {0} is {1}",$NewUser,$FreeSlot ))

# Invoke user insertion in free slot
    $JsonBody = @{
        'UserName' = $NewUser
        'Password' = $NewPwd
        'RoleId' = $Privilege
        'Enabled' = $Enabled.IsPresent
    } | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

    $PatchUri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Accounts/$FreeSlot"
    $WebRequestParameter.Uri = $PatchUri

    $WebRequestParameter.Method = 'Patch'

    Try {
        $PatchResult = Invoke-WebRequest @WebRequestParameter
    } Catch {
        Throw $_
    }


    If ($PatchResult.StatusCode -eq 200) {
        Write-Verbose -Message $([String]::Format("Statuscode {0} returned successfully for Patch command, iDRAC user created`n",$PatchResult.StatusCode))
    } Else {
        Throw $([String]::Format("FAIL, statuscode {0} returned, user not created",$PatchResult.StatusCode))
    }

# Grant privileges to the new user.

    If ( $ExtendRights.IsPresent ) {
        If ( [String]::IsNullOrEmpty($IpmiSerialPrivilege) ) { $IpmiSerialPrivilege = $Privilege }
        If ( [String]::IsNullOrEmpty($IpmiLanPrivilege) ) { $IpmiLanPrivilege = $Privilege }
    }
     
    $JsonBody = @{
        'Attributes' = @{
            "Users.$FreeSlot.IpmiSerialPrivilege" = $IpmiSerialPrivilege
            "Users.$FreeSlot.IpmiLanPrivilege" = $IpmiLanPrivilege
            "Users.$FreeSlot.SolEnable" = $SolEnable
        }
    } | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

    $PatchUri2 = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Attributes"
    $WebRequestParameter.Uri = $PatchUri2

    $PatchResult2 =  Invoke-WebRequest @WebRequestParameter

# Return result according to api status code

    If ($PatchResult2.StatusCode -eq 200) {
        Write-Verbose -Message $([String]::Format("Statuscode {0} returned successfully for Patch command, iDRAC user rights changed`n",$PatchResult2.StatusCode))
    } Else {
        Throw $([String]::Format("FAIL, statuscode {0} returned, iDRAC user rights not changed",$PatchResult2.StatusCode))
    }


    $GetUri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Accounts/$FreeSlot"
    $WebRequestParameter.Uri = $GetUri
    $WebRequestParameter.Method = 'Get'
    $WebRequestParameter.Remove('Body')
    Try {
        $CheckResult = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Throw $_
    }


    $O_IdracNewUser = [PSCustomObject]@{
        'Id' = $CheckResult.Id
        'UserName' = $CheckResult.UserName
        'Enabled' = $CheckResult.Enabled
    }

	Return $O_IdracNewUser 

}

Export-ModuleMember New-RacUser