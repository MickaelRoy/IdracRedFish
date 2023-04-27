if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
    $certCallback = @"
                using System;
                using System.Net;
                using System.Net.Security;
                using System.Security.Cryptography.X509Certificates;
                public class ServerCertificateValidationCallback
                {
                    public static void Ignore()
                    {
                        if(ServicePointManager.ServerCertificateValidationCallback ==null)
                        {
                            ServicePointManager.ServerCertificateValidationCallback += 
                                delegate
                                (
                                    Object obj, 
                                    X509Certificate certificate, 
                                    X509Chain chain, 
                                    SslPolicyErrors errors
                                )
                                {
                                    return true;
                                };
                        }
                    }
                }
"@
Add-Type $certCallback
}
[ServerCertificateValidationCallback]::Ignore()

#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

[System.IO.Directory]::EnumerateFiles("$PSScriptRoot\Functions") | ForEach-Object {
    
    . $_

}
