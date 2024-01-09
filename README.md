# Idrac RedFish Powershell Module
Based on an initial work of Texas Roemer (DELL)

Enhanced by Mickael Roy

## Load the module

```
PS C:\idrac-refdish-powershell-module> Ipmo .\IdracRedfish
```

## cmdlets inside

* Dismount-RacVirtualDrive
* Get-RacBiosSettings0
* Get-RacFirmwareVersion
* Get-RacJobStatus
* Get-RacManagerAttribute
* Get-RacPendingBiosSettings
* Get-RacPowerState
* Get-RacSession
* Get-RacUser
* Get-RacVirtualDriveStatus
* Invoke-RacBootToNetworkISO
* Invoke-RacOneTimeBoot
* New-RacSession
* New-RacUser
* Register-RacBiosSettings
* Remove-RacSession
* Remove-RacUser
* Repair-IdracBadGateway
* Reset-RacIdrac
* Set-RacManagerAttribute
* Set-RacPowerState
* Set-RacUserPassword
* Submit-RacPendingBiosSettings
* Test-RacRedfish
* Update-RacFirmware
* Get-RacManagerDellAttribute
* Set-RacManagerDellAttribute

## Use Case examples
```powershell
Register-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd *pass* -Name SysProfile -Value PerfOptimized
Submit-RacPendingBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd *pass* -Restart
```

```powershell
$Session = New-RacSession -Ip_Idrac 192.168.0.120 -Credential $Credential
Register-RacBiosSettings -Session $Session -Name SysProfile -Value PerfOptimized
Submit-RacPendingBiosSettings -Session $Session -Restart
```

## Change Log
### 2.3.0 Enhancement of ParameterSets

### 2.2.1 New cmdlets
Get-RacManagerDellAttribute
Set-RacManagerDellAttribute

### 2.1.0 Proxy Update and Hostname parameter
All cmdlets can detect and use the proxy user.
Also, hostname parameter has been added beside Ip_Idrac.

### 2.0.0 Massive update
All cmdlets have been updated to manage token authentication and avoid clear password usage.  
You can use Credential parameter to pass credentials during unique operation or,  
you can generate a token with New-Racsession cmdlet that you store in a variable.  

Remove-RacUser cmdlet added.  

### 1.0.0 Initial push.



