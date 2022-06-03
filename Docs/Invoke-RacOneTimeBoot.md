---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Invoke-RacOneTimeBoot

## SYNOPSIS
Cmdlet used to restart the remote system and boot to the device specied using REDFISH API.

## SYNTAX

### Creds
```
Invoke-RacOneTimeBoot -Ip_Idrac <String> -Credential <PSCredential> -BootDevice <String> [<CommonParameters>]
```

### Session
```
Invoke-RacOneTimeBoot -Session <PSObject> -BootDevice <String> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to restart the remote system and boot to the device specied using REDFISH API.
Available boot device are "Normal", "PXE", "HDD", "vFDD", "VCD-DVD".

## EXAMPLES

### EXAMPLE 1
```
Invoke-RacOneTimeBoot -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -BootDevice PXE
```

This example set PXE as boot override and restart the system behind 192.168.0.120 IpAddress

## PARAMETERS

### -BootDevice
Specifies the targer device to boot at next startup.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: Normal
Accept pipeline input: False
Accept wildcard characters: False
```

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

## RELATED LINKS
