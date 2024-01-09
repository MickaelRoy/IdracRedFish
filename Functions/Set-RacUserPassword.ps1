<#
.Synopsis
   Cmdlet used to change Idrac password using REDFISH API.

.DESCRIPTION
   Cmdlet used to change Idrac password using REDFISH API.

.PARAMETER Ip_Idrac

    Specifies the IpAddress of Remote system's Idrac.

.PARAMETER RacUser

    Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

    Specifies the password for Idrac connection.

.PARAMETER TargetUser

    Specifies the User that you password has to be changed. If absent RacUser
    account take place.

.PARAMETER NewPwd

    Specifies the password for the new account.

.EXAMPLE
    Set-RacUserPassword -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -TargetUser 'Admin' -NewPwd '[StrongPass]'

    This example created a priviledged account

.LINK
    Get-RacUser
    New-RacUser
    Remove-RacUser

#>

Function Set-RacUserPassword {
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

        [Parameter(Mandatory=$false)]
        [string]$TargetUser = 'root',

        [Parameter(Mandatory=$true)]
        [string]$NewPwd,
         
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

    $Members = $GetResult.Members
    $Accounts = [System.Collections.ArrayList]::new()

    $Members.'@odata.id' | ForEach-Object {
        $GetUri2 = "https://$Ip_Idrac$_"
        $WebRequestParameter.Uri = $GetUri2
        $Account = Invoke-RestMethod @WebRequestParameter
        If (-not [String]::IsNullOrEmpty($Account.UserName)) {
            [Void]$Accounts.Add($Account)
        }
    }

    If ([String]::IsNullOrEmpty($TargetUser)) {
        Write-Verbose -Message $([String]::Format(" {0}({1}), You are about to change your own password", $UserAccount.UserName, $UserAccount.Id ))
        $TargetUser = $UserAccount.UserName
    }
    $UserAccount = $Accounts.Where({ $_.UserName -EQ $TargetUser })

    Write-Verbose -Message $([String]::Format("User ID for {0} is {1}",$UserAccount.UserName,$UserAccount.Id ))

# Change Password for User specified
    $JsonBody = @{'Password'= $NewPwd} | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody
    $WebRequestParameter.Method = 'Patch'

    $PatchUri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Accounts/$($UserAccount.Id)"
    $WebRequestParameter.Uri = $PatchUri
    Try {
        $PatchResult = Invoke-WebRequest @WebRequestParameter
    } Catch {
        Throw $_
    }

# Return result according to api status code

    If ($PatchResult.StatusCode -eq 200) {
        Write-Verbose -Message $([String]::Format("Statuscode {0} returned successfully for Patch command, iDRAC user password changed`n",$PatchResult.StatusCode))
    } Else {
        Throw $([String]::Format("FAIL, statuscode {0} returned, password not changed",$PatchResult.StatusCode))
    }

    $overall_job_output = ($PatchResult.Content | ConvertFrom-Json).'@Message.ExtendedInfo'

    Return [PsCustomObject] @{
        'State' = $PatchResult.StatusDescription
        'Message' = $overall_job_output[0].Message
        'Information' = $overall_job_output[0].Resolution
    }

}

Export-ModuleMember Set-RacUserPassword