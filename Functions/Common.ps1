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


Function Get-LastValidIp {
    param ( 
        [parameter(ValueFromPipeline)]
        [ValidatePattern('/\d')]
        [String] $InputObject
    )

    Function Convert-IPtoINT64 ($Ip) { 
        $octets = $ip.split(".") 
        [int64]([int64]$octets[0] * 16777216 + [int64]$octets[1] * 65536 + [int64]$octets[2] * 256 + [int64]$octets[3]) 
    } 
 
    Function Convert-INT64toIP ([int64]$Int) { 
        (([math]::truncate($int / 16777216)).tostring(), ([math]::truncate(($int % 16777216) / 65536)).tostring(),([math]::truncate(($int % 65536) / 256)).tostring(), ([math]::truncate($int % 256)).tostring() ) -join "."
    } 

    $IPandMask = $InputObject -Split '/'
    $IP = $IPandMask[0]
    $MaskBits = $IPandMask[1]

    $IPAddr = [Net.IPAddress]::Parse($IP)

    $MaskAddr = [System.Net.IPAddress]::Parse((Convert-INT64toIP -int ([convert]::ToInt64(("1" * $MaskBits + "0" * (32 - $MaskBits)), 2))))
        
    $NetworkAddr = [System.Net.IPAddress]::new($MaskAddr.address -band $IPAddr.address) 

    $BroadcastAddr = [System.Net.IPAddress]::new(([System.Net.IPAddress]::parse("255.255.255.255").Address -bxor $MaskAddr.Address -bor $NetworkAddr.Address))

    $HostEndAddr = (Convert-IPtoINT64 -ip $broadcastaddr.ipaddresstostring) - 1

    Return Convert-INT64toIP $HostEndAddr 

}

Function Test-IpSubnets {
    param (
        [parameter(Mandatory=$true)]
        [Net.IPAddress] $ip1,
 
        [parameter(Mandatory=$true)]
        [Net.IPAddress] $ip2,
 
        [parameter()]
        [alias("SubnetMask")]
        [Net.IPAddress] $mask ="255.255.255.0"
    )

    If (($ip1.Address -band $mask.Address) -eq ($ip2.Address -band $mask.Address)) { Return $true}
    Else { Return $false }
 
}
Function Start-CountDown {
    [CmdletBinding()]

param(
    $i = 30
)
    do {
        Write-Host $i -NoNewline
        Write-Host "`r" -NoNewline
        Sleep 1
        $i--
    } while ($i -gt 0)

}

Function Show-Menu {
    Param (        
        [Parameter(Mandatory=$true, ValueFromPipeline=$True)]
        [PsObject]$InputObject,
        [String] $Title,
        $KeySize = 25,
        $Width = 60 
    )
    Clear-Host
    $KeySize = $InputObject.psobject.Properties.Name.ForEach({ $_.Length }) | Sort-Object -Descending -Unique | Select-Object -First 1
    $ValueSize = ($InputObject.psobject.Properties.value.ForEach({ $_.Length }) | Sort-Object -Descending -Unique | Select-Object -First 1) + 1
    $Width = $KeySize + $ValueSize + 2
    $Width += ($Width.length % 2)

    If ($Title.Length -gt $Width) { $Width = $Title.Length}
 
    Write-Host "╒$([string]::new('═', $Width))╕"
    If ($Title) {
 
        $emptyspaces = $([string]::new(' ', (($Width + 1) - $Title.Length)/2))
        $Center = $Width / 2
        [int]$centerL = $Center + ($Title.Length/2)
        Write-Host $("│{0,$centerL}$emptyspaces│" -f $Title)
        Write-Host $("├$([string]::new('─', $Width))┤")
    
    }
    Foreach ($Property in $InputObject.psobject.Properties) {
        Write-Host $("│ {0,-$KeySize}: {1, -$ValueSize}│" -f "$($Property.Name)", "$($Property.value)")
    }
    Write-Host $("╘$([string]::new('═', $Width))╛")
    Write-Host `n
} 
