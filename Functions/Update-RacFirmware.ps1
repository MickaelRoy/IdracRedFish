Function Update-RacFirmware {
    [CmdletBinding(DefaultParameterSetName = 'Host')]
    param(
        [Parameter(ParameterSetName = "Creds")]
        [Parameter(Mandatory = $true, ParameterSetName = 'Ip')]
        [IpAddress]$Ip_Idrac,
        [Parameter(ParameterSetName = "Creds")]
        [Parameter(Mandatory = $true, ParameterSetName = 'Host')]
        [string]$Hostname,
        [Parameter(Mandatory = $true)]
        [String]$FilePath,
        [Parameter(Mandatory = $true, ParameterSetName = "Creds")]
        [pscredential]$Credential,
        [Parameter(Mandatory = $true, ParameterSetName = "Session")]
        [PSCustomObject]$Session, 
        [Switch]$NoProxy
    )


    Switch ($PsCmdlet.ParameterSetName) {
        Creds {
            $WebRequestParameter = @{
                Headers     = @{"Accept" = "application/json" }
                Credential  = $Credential
                Method      = 'Get'
                ContentType = 'application/json'
            }
        }

        Session {
            $WebRequestParameter = @{
                Headers = $Session.Headers
                Method  = 'Get'
            }
            $Ip_Idrac = $Session.IPAddress
        }
    }
    
    If ($PSBoundParameters['Hostname']) {
        Try {
            $Ip_Idrac = [System.Net.Dns]::Resolve($Hostname).AddressList.IPAddressToString
        }
        Catch { $_ }
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
    }
    Catch {

        Throw $_

    }
    If ( $GetResult.Model.Substring(0, 2) -le 13 ) { 
        Write-Host "Idrac8 and below cannot be update like that for the moment"
        Return
    }
    Else {
        
        $WebRequestParameter.uri = "https://$Ip_Idrac/redfish/v1/UpdateService/FirmwareInventory"
        $GetResult = Invoke-WebRequest @WebRequestParameter
        $ETag = $GetResult.Headers.ETag
        $headers = @{"If-Match" = $ETag; "Accept" = "application/json" }


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
        $WebRequestParameter.Headers = $headers
        $WebRequestParameter.ContentType = "multipart/form-data; boundary=`"$boundary`""
        $WebRequestParameter.Body = $body

        Try {
            Write-Verbose -Message 'Uploading the fimware image, please be patient.'
            $PostRequest = Invoke-WebRequest @WebRequestParameter -ErrorAction Stop
            Write-Verbose -Message 'File uploaded with sucess.'
            
            $PostContent = $PostRequest.Content
            $image_uri = $PostRequest.Headers['Location']
        
        }
        Catch {
            Throw $_
        }


        $JsonBody = @{'ImageURI' = $image_uri } | ConvertTo-Json -Compress

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
    }
    Catch {
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
