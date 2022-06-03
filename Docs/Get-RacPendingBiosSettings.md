---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Get-RacPendingBiosSettings

## SYNOPSIS
Cmdlet used to get BIOS pending changes using REDFISH API.

## SYNTAX

### Creds
```
Get-RacPendingBiosSettings -Ip_Idrac <String> -Credential <PSCredential> [<CommonParameters>]
```

### Session
```
Get-RacPendingBiosSettings -Session <PSObject> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to get BIOS pending changes using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
Get-RacPendingBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin
```

This example lists all registered bios pending changes.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
To register one or more attributes, you have to use Register-RacBiosSettings cmdlet
To apply one or more attributes, you have to use Submit-RacBiosSettings cmdlet.

## RELATED LINKS

[Register-RacBiosSettings
Submit-RacPendingBiosSettings
Get-RacBiosSettings]()

