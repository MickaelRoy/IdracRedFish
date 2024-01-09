<#
.Synopsis
   Cmdlet used to Get Idrac user(s) using REDFISH API.

.DESCRIPTION
   Cmdlet used to Get Idrac user(s) using REDFISH API.

.PARAMETER Ip_Idrac

    Specifies the IpAddress of Remote system's Idrac.

.PARAMETER Credential

    Specifies the Credential for Idrac connection.

.PARAMETER Session
    Specifies an Idrac session in which this cmdlet runs the command.
    Enter a variable that contains PSCustomObjects or a command that 
    creates or gets the Idrac Session Objects, such as a New-RacUser.

.EXAMPLE
    Get-RacUser -Ip_Idrac 192.168.0.120 -Session $Session -Name 'Admin'

    This example remove Admin account, and make linux team frustrated.

.LINK
    Set-RacUserPassword
    Remove-RacUser
    New-RacUser

#>
Function Get-RacUser {
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

        [Parameter(Mandatory=$false)]
        [string]$Name,

        [Switch]$NoProxy
	)

    If ($null -ne $Hostname) {
        $Ip_Idrac = [System.Net.Dns]::Resolve($Hostname).AddressList.IPAddressToString
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

# Built Users list
    $GetUri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1/Accounts"
    $WebRequestParameter.Uri = $GetUri
    Try {
        $GetResult = Invoke-RestMethod @WebRequestParameter
    } Catch {
        Throw $_
    }

    If ([String]::IsNullOrEmpty($Name)) {
        $Accounts = [System.Collections.ArrayList]::new()

        $GetResult.Members.'@odata.id' | ForEach-Object {
            $GetUri2 = "https://$Ip_Idrac$_"
            $WebRequestParameter.Uri = $GetUri2
            $Account = Invoke-RestMethod @WebRequestParameter
            If (-not [String]::IsNullOrEmpty($Account.UserName)) {
                [Void]$Accounts.Add($Account)
            }
        }
        Return $Accounts

    } Else {

    # Search and find the good slot
        $Members = $GetResult.Members
        $I = 1
        While (($Name -ne $Account.UserName) -and ("$($GetResult.'@odata.id')/$I" -ne $Members.'@odata.id'[-1]) ) {
        
            $GetUri2 = "https://$Ip_Idrac$($GetResult.'@odata.id')/$I"
            $WebRequestParameter.Uri = $GetUri2
            $Account = Invoke-RestMethod @WebRequestParameter
            $I++
        }

        Write-Verbose -Message $([String]::Format("User ID for {0} is {1}",$UserAccount.UserName,$UserAccount.Id ))

        Return $Account
    }

}

Export-ModuleMember Get-RacUser