
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

[System.IO.Directory]::EnumerateFiles("$PSScriptRoot\Functions") | Foreach {
    
    . $_

}
