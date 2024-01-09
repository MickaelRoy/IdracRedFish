<#
.Synopsis
   Cmdlet used to remove Idrac user using REDFISH API.

.DESCRIPTION
   Cmdlet used to remove Idrac user using REDFISH API.

.PARAMETER Ip_Idrac

    Specifies the IpAddress of Remote system's Idrac.

.PARAMETER Credential

    Specifies the Credential for Idrac connection.

.PARAMETER Session
    Specifies an Idrac session in which this cmdlet runs the command.
    Enter a variable that contains PSCustomObjects or a command that 
    creates or gets the Idrac Session Objects, such as a New-RacUser.

.EXAMPLE
    Remove-RacUser -Ip_Idrac 192.168.0.120 -Session $Session -Name 'Admin'

    This example remove Admin account, and make linux team frustrated.

.LINK
    Set-RacUserPassword
    New-RacUser
    Get-RacUser

#>
Function Remove-RacUser {
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

        [Switch]$NoProxy
	)

    If ($PSBoundParameters['Hostname']) {
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

    Try {
    # Disable the account
        $JsonBody = @{Enabled = $false; RoleId = "None"} | ConvertTo-Json
        $WebRequestParameter.Body = $JsonBody

        $PatchUri1 = "https://$Ip_Idrac$($Account.'@odata.id')"
        $WebRequestParameter.Uri = $PatchUri1

        $WebRequestParameter.Method = 'Patch'

        $PatchResult1 = Invoke-WebRequest @WebRequestParameter

        $JsonBody = @{UserName = ""} | ConvertTo-Json -Compress
        $WebRequestParameter.Body = $JsonBody

    # Delete the account
        $PatchResult2 = Invoke-WebRequest @WebRequestParameter
    } Catch {
        Throw $_
    }

    $overall_job_output = ($PatchResult2.Content | ConvertFrom-Json).'@Message.ExtendedInfo'

    If ($PatchResult2.StatusCode -eq 200 ) {
    # Return last action status
        $overall_job_output = ($PatchResult2.Content | ConvertFrom-Json).'@Message.ExtendedInfo'

        Return [PsCustomObject] @{
            'State' = $PatchResult2.StatusDescription
            'Message' = $overall_job_output[0].Message
            'Information' = $overall_job_output[0].Resolution
        }
    }
}

Export-ModuleMember Remove-RacUser