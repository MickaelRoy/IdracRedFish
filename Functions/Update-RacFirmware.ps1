Function Update-RacFirmware {
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


        $BaseWBP = $WebRequestParameter

    Try {
        $WebRequestParameter.uri = "https://$Ip_Idrac/redfish/v1/Managers/iDRAC.Embedded.1"
        $GetResult = Invoke-RestMethod @WebRequestParameter
    } Catch {

        Throw $_

    }
    If ( $GetResult.Model.Substring(0,2) -le 13 ) { 
        Write-Host "Idrac8 and below cannot be update like that for the moment"
    } Else {
        
        $WebRequestParameter.uri = "https://$Ip_Idrac/redfish/v1/UpdateService/FirmwareInventory"
        $GetResult = Invoke-WebRequest @WebRequestParameter
        $ETag = $GetResult.Headers.ETag
        $headers = @{"If-Match" = $ETag; "Accept"="application/json"}


        # Code to read the image file for download to the iDRAC

        $CODEPAGE = "ISO-8859-1"
        $fileBin = [System.IO.File]::ReadAllBytes($FilePath)
        $fileEnc = [System.Text.Encoding]::GetEncoding($CODEPAGE).GetString($fileBin)
        $boundary = [System.Guid]::NewGuid().ToString()

        $LF = [System.Environment]::NewLine

        $FileName = [System.IO.Path]::GetFileName($FilePath)

        $body = (
                "--$boundary",
                "Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`"",
		        "Content-Type: application/octet-stream$LF",
                $fileEnc,
                "--$boundary--$LF"
        ) -join $LF


        $WebRequestParameter.Method = 'POST'
        $WebRequestParameter.Headers = @{"If-Match" = $ETag; "Accept"="application/json"}
        $WebRequestParameter.ContentType = "multipart/form-data; boundary=`"$boundary`""
        $WebRequestParameter.Body = $body

        Try {
            Write-Verbose -Message 'Uploading the fimware image, please be patient.'
            $PostRequest = Invoke-WebRequest @WebRequestParameter -ErrorAction Stop
            Write-Verbose -Message 'File uploaded with sucess.'
            
            $PostContent = $PostRequest.Content
            $image_uri = $PostRequest.Headers['Location']
        
        } Catch {
            Throw $_
        }


        $JsonBody = @{'ImageURI'= $image_uri} | ConvertTo-Json -Compress

        $WebRequestParameter.uri = "https://$Ip_Idrac/redfish/v1/UpdateService/Actions/UpdateService.SimpleUpdate"
        $WebRequestParameter.Headers = $BaseWBP.Headers
        $WebRequestParameter.Method = 'Post'
        $WebRequestParameter.Body = $JsonBody
    
    }

        Try {
            $PostResult2 = Invoke-WebRequest @WebRequestParameter -ErrorAction Stop

            $job_id_search = $PostResult2.Headers['Location']
            $job_id = $job_id_search.Split("/")[-1]

            Write-Verbose -Message "JobId $job_id sucessfully created."
        } Catch {
            Write-Error $_
        }

        $WebRequestParameter.uri = "https://$Ip_Idrac/redfish/v1/TaskService/Tasks/$job_id"
        $WebRequestParameter.Method = 'Get'
        $WebRequestParameter.Remove('Body')

        $GetJobResult = Invoke-WebRequest @WebRequestParameter -ErrorAction Stop

        $overall_job_output = $GetJobResult.Content | ConvertFrom-Json

        Return $overall_job_output

}

Export-ModuleMember Update-RacFirmware


#Update-RacFirmware -Ip_Idrac 10.2.160.170 -Credential $Credential -FilePath C:\temp\Idrac\iDRAC-with-Lifecycle-Controller_Firmware_G79DW_WN64_2.84.84.84_A00.EXE -Verbose

