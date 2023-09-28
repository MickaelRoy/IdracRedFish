Function Set-CertPolicy() {
    ## Trust all certs - for sample usage only
    Try {
        Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }
    Catch {
        Write-Error "Unable to add type for cert policy"
    }
}

Function Set-myProxyAsDefault {
    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
        [Uri]$Uri
	)

    If (! [System.Net.WebRequest]::GetSystemWebProxy().IsBypassed($Uri) ) {
        [Uri]$ProxyUri = [System.Net.WebRequest]::GetSystemWebProxy().GetProxy($Uri)
        [System.Net.WebRequest]::DefaultWebProxy = [System.Net.WebProxy]($ProxyUri.Authority)
        [System.Net.WebRequest]::DefaultWebProxy.BypassProxyOnLocal = $false
        [System.Net.WebRequest]::DefaultWebProxy.UseDefaultCredentials = $true
    }
    Return [System.Net.WebRequest]::DefaultWebProxy
}
