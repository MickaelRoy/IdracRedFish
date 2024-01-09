<#
.Synopsis
   Cmdlet using Redfish API with OEM extension to boot to network ISO.

.DESCRIPTION
   Cmdlet using Redfish API with OEM extension to connect/attach a network ISO,
   restart the remote system and boot on virtual drive

.PARAMETER Ip_Idrac

    Specifies the IpAddress of Remote system's Idrac.

.PARAMETER PathIso

    Specifies the network Path to ISO.

.PARAMETER RacUser

    Specifies the User for Idrac connection, root by default.

.PARAMETER RacPwd

    Specifies the password for Idrac connection.

.PARAMETER SharePwd

    Specifies the password for EURO\SVCFRPARISODRACPRD account allowed to mount Iso network share.
    By default "\\Serverfs\winloader"

.EXAMPLE
    Invoke-RacBootToNetworkISO -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -PathIso \\Serverfs\winloader\ws9200pcc00001.iso

    This example connects virtual drive to the iso path specified and restart the system to boot on.

.LINK
    Dismount-RacVirtualDrive
    Get-RacVirtualDriveStatus

.NOTES
#>
Function Invoke-RacBootToNetworkISO {
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
        [string]$PathIso,

        [Parameter(Mandatory=$true)]
        [string]$ShareUsr,

		[Parameter(Mandatory=$true)]
        [string]$SharePwd,

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


# Payload creation for Idrac request
    $Uri = [uri]::new($PathIso)
    $IpAddress = [System.Net.Dns]::GetHostAddresses($Uri.Host).IPAddressToString
    $Sharetype = 'CIFS'
    $ShareName = ($Uri.Segments[0] + $Uri.Segments[1]).TrimEnd('/')
    $ImageName = $Uri.Segments[-1]
    $UserName = $ShareUsr
    $Password = $SharePwd

    $JsonBody = @{
        'ImageName' = $ImageName
        'IPAddress' = $IpAddress
        'ShareType' = $Sharetype
        'ShareName' = $ShareName
        'UserName' = $UserName
        'Password'= $Password
    } | ConvertTo-Json -Compress
    $WebRequestParameter.Body = $JsonBody

# Send the request to Idrac
    Write-Verbose -Message "Attaching network ISO for iDRAC $Ip_Idrac"
    $PostUri = "https://$Ip_Idrac/redfish/v1/Dell/Systems/System.Embedded.1/DellOSDeploymentService/Actions/DellOSDeploymentService.BootToNetworkISO"
    $WebRequestParameter.Uri = $PostUri

    Try {
        $PostResult = Invoke-WebRequest @WebRequestParameter
    } Catch {
        Throw $_
    }

# Loop to receive the reseult from Idrac
    If ($PostResult.StatusCode -eq 202) {
        Write-Verbose -Message "POST command passed to connect network ISO, cmdlet will now loop checking concrete job status"
        $concrete_job_uri = $PostResult.Headers.Location
    }
    While ($GetResult.TaskState -ne "Completed") {
        $GetUri = "https://$ip_idrac$concrete_job_uri"
        $WebRequestParameter.Uri = $GetUri
        $WebRequestParameter.Method = 'Get'
        $WebRequestParameter.Remove('Body')

        Try {
            $GetResult = Invoke-WebRequest @WebRequestParameter
        } Catch {
            Throw $_
        }

        $GetResult = $GetResult.Content | ConvertFrom-Json
        If ($GetResult.TaskState -eq "Exception") {
            Write-Warning -Message $([String]::Format("Concrete job has hit an exception, current job message: '{0}'", $GetResult.Messages.Message))
            Write-Verbose -Message "If needed, check iDRAC Lifecycle Logs or Job Queue for more details on the exception.`n"
        } else {
            $job_status = $GetResult.TaskState
            Write-Verbose -Message "Current concrete job status not marked completed, current status: $job_status"
            Start-Sleep 5
        }
    }

    $O_IdracMapIso = [PSCustomObject]@{
        'State' = $GetResult.TaskState
        'Message' = $GetResult.Name
        'Information' = $GetResult.Messages.Message
    }

	Return $O_IdracMapIso
}

Export-ModuleMember Invoke-RacBootToNetworkISO