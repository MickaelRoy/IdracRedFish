Function Get-RacJobStatus {
<#
    .SYNOPSIS
    Gets the status of a job on an iDRAC (Integrated Dell Remote Access Controller) server.

    .DESCRIPTION
    The Get-RacJobStatus function queries a Dell server iDRAC to obtain the status of a specific job using various parameters to specify the iDRAC, authentication information, and other request options.

    .PARAMETER Ip_Idrac
    The IP address of the Dell iDRAC. Used with the `Hostname` parameter to resolve the IP address if only the hostname is provided.

    .PARAMETER Hostname
    The hostname of the Dell server. If specified, it is resolved to a corresponding IP address.

    .PARAMETER Credential
    The credentials required to access the iDRAC.

    .PARAMETER Session
    A custom session for web requests. This parameter can be supplied by another function named New-RacSession.

    .PARAMETER JobId
    The identifier of the job to retrieve the status for.

    .PARAMETER NoProxy
    Indicates whether the use of a proxy should be disabled for the web request.

    .EXAMPLE
    Get-RacJobStatus -Ip_Idrac "192.168.1.100" -Credential $Credential -JobId "123456789"
    Gets the status of the job with the specified identifier on the iDRAC with the IP address 192.168.1.100 using the provided credentials.

    .EXAMPLE
    Get-RacJobStatus -Hostname "server01.example.com" -Credential $Credential -NoProxy
    Gets the status of the job on the iDRAC of the server "server01.example.com" using the provided credentials and disabling the use of a proxy.

    .NOTES
    Author: Mickael ROY
    Date created: 08-10-2023
#>

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

        [String]$JobId,

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

    $Uri = "https://$Ip_Idrac/redfish/v1/TaskService/Tasks/"
    
    If ($JobId) { $Uri = [String]::Concat($Uri, $JobId) }

    $WebRequestParameter.uri = $Uri
    $WebRequestParameter.Method = 'Get'

    $GetJobResult = Invoke-WebRequest @WebRequestParameter -ErrorAction Stop

    $overall_job_output = $GetJobResult.Content | ConvertFrom-Json


    Return $overall_job_output
}

Export-ModuleMember Get-RacJobStatus
