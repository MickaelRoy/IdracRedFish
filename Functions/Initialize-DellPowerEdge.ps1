Function Initialize-DellPowerEdge {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'High',DefaultParameterSetName = 'DHCP')]
    Param(
        [Parameter(mandatory=$true, HelpMessage="Path to template." )]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist" 
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
                return $true
        })]
        [Alias("SP", "FilePath")]
        [string]$SourcePath,

        [Parameter(mandatory=$false, HelpMessage="Current Ip Address.")]
        [Alias("Ip")]
        [string]$IpAddress,

        [Parameter(mandatory=$false, HelpMessage="Idrac power user, default is root")]
        [string]$User = 'root',

        [Parameter(mandatory=$false, HelpMessage="current password, usually calvin.")]
        [AllowNull()]
        [SecureString]$Password = (Read-Host -AsSecureString -Prompt "If it's not 'calvin', enter the current password for $user"),

        [Parameter(mandatory=$false, HelpMessage="New password, get it in Securden.")]
        [AllowNull()]
        [SecureString]$NewPassword = (Read-Host -AsSecureString -Prompt "Enter the new password for the privileged account, leave blank to skip this step."),

        [Parameter(Mandatory=$false, HelpMessage="Idrac fqdn wether it's not declared in DNS yet.")]
        [string]$Hostname,

        [Parameter(mandatory=$true, ParameterSetName = 'StaticIp', HelpMessage="Static Ip Address pushed with the template.")]
        [string]$StaticIpAddress,

        [Parameter(mandatory=$false, ParameterSetName = 'StaticIp', HelpMessage="Gateway pushed with the template.")]
        [Alias("GW", "Gateway")]
        [string]$NextHop,
        
        [Parameter(mandatory=$false, ParameterSetName = 'StaticIp', HelpMessage="Prefix Length aka bit mask format.")]
        [Alias("PL")]
        [int]$PrefixLength = 24,
        
        [Parameter(mandatory=$false, ParameterSetName = 'StaticIp', HelpMessage="Primary DNS Address.")]
        [Alias("DNS1")]
        [string]$PrimaryDns = "10.4.2.2" ,
        
        [Parameter(mandatory=$false, ParameterSetName = 'StaticIp', HelpMessage="Secondary DNS Address.")]
        [Alias("DNS2")]
        [string]$SecondaryDns = "10.4.1.2",

        [Parameter(Mandatory=$False)]
        [ValidateSet("ALL", "IDRAC", "BIOS")]
        [string]$Target = 'IDRAC',

        [Parameter(Mandatory=$False)]
        [ValidateSet("Graceful", "Forced", "NoReboot")]
        [string]$ShutdownType = "NoReboot",

        [Switch]$NoProxy
    )

    If ($Password.Length -eq 0) {
        Write-Verbose -Message "I guess the current password is calvin."
        $Password = "calvin" | ConvertTo-SecureString -AsPlainText -Force
    }
    [pscredential]$Credential = [System.Management.Automation.PSCredential]::new($user, $Password)

    If ($NewPassword.Length -eq 0) { Write-Verbose -Message "User requested explicitly no password change." }
    Else {
        $NewPasswd = ConvertFrom-SecureString $NewPassword -ea Stop
        $PSBoundParameters.Add('NewPassword', $NewPassword)
    }


    If (-not $PSBoundParameters['SourcePath']) {
        # Check Idrac version
        $Generation = Get-RacModel -Ip_Idrac $IpAddress -Credential $Credential -NoProxy:$NoProxy
    }

    If ($PSBoundParameters['NoProxy']) {
        $PSBoundParameters.Remove('NoProxy')
        $NoProxyFlag = $true
    }

    # Configuration du template
    [void]$PSBoundParameters.Remove("Target")
    Write-Verbose -Message "New-RacTemplate execution."
    $FilePath = New-RacTemplate @PSBoundParameters

    If ($NoProxyFlag) { $PSBoundParameters.Add('NoProxy', $true) }

    If ($PSCmdlet.ShouldProcess("$IpAddress ($Target)", "Import the template")) {
        # Import du template
        Echo "Import-RacTemplate -TemplatePath $FilePath -Ip_Idrac $IpAddress -Credential $Credential -Target $Target -ShutdownType Graceful "
        Import-RacTemplate -TemplatePath $FilePath -Ip_Idrac $IpAddress -Credential $Credential -Target $Target -ShutdownType Graceful -NoProxy:$NoProxy -ShutdownType:$ShutdownType
    }
}

Export-ModuleMember Initialize-DellPowerEdge