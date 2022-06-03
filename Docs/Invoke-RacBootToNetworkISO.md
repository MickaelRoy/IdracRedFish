---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Invoke-RacBootToNetworkISO

## SYNOPSIS
Cmdlet using Redfish API with OEM extension to boot to network ISO.

## SYNTAX

### Creds
```
Invoke-RacBootToNetworkISO -Ip_Idrac <String> -PathIso <String> -Credential <PSCredential> -ShareUsr <String>
 -SharePwd <String> [<CommonParameters>]
```

### Session
```
Invoke-RacBootToNetworkISO -PathIso <String> -ShareUsr <String> -SharePwd <String> -Session <PSObject>
 [<CommonParameters>]
```

## DESCRIPTION
Cmdlet using Redfish API with OEM extension to connect/attach a network ISO,
restart the remote system and boot on virtual drive

## EXAMPLES

### EXAMPLE 1
```
Invoke-RacBootToNetworkISO -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -PathIso \\clhvcoc001fs\winloader\ws9200pcc00001.iso
```

This example connects virtual drive to the iso path specified and restart the system to boot on.

## PARAMETERS

### -Credential
{{ Fill Credential Description }}

```yaml
Type: PSCredential
Parameter Sets: Creds
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Ip_Idrac
Specifies the IpAddress of Remote system's Idrac.

```yaml
Type: String
Parameter Sets: Creds
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PathIso
Specifies the network Path to ISO.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Session
{{ Fill Session Description }}

```yaml
Type: PSObject
Parameter Sets: Session
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SharePwd
Specifies the password for EURO\SVCFRPARISODRACPRD account allowed to mount Iso network share.
By default "\\\\clhvcoc001fs\winloader"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShareUsr
{{ Fill ShareUsr Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: Euro\SVCFRPARISODRACPRD
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
The passord for SVCFRPARISODRACPRD account can be fount on cyberark
https://cyber-ark.cib.echonet/PasswordVault/ObjectDetails.aspx?Data=V0lOVEVMLVNSVl5AXlJvb3ReQF5XaXRob3V0LUNvbm5lY3Rpb24tQXBwbGljYXRpb24tR2VuZXJpYy1TVkNGUlBBUklTT0RSQUNQUkReQF4wXkBeRmFsc2VeQF5GYWxzZV5AXl5AXkJhY2tVUkw9TXNnRXJyPU1zZ0luZm89

## RELATED LINKS

[Dismount-RacVirtualDrive
Get-RacVirtualDriveStatus]()

