---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Get-RacVirtualDriveStatus

## SYNOPSIS
Cmdlet used to get virtual drive attachement status using REDFISH API.

## SYNTAX

### Creds
```
Get-RacVirtualDriveStatus -Ip_Idrac <String> -Credential <PSCredential> [<CommonParameters>]
```

### Session
```
Get-RacVirtualDriveStatus -Session <PSObject> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to get virtual drive attachement status using REDFISH API.
Usualy this cmdlet is used to check wether Iso is attached to RFS.

## EXAMPLES

### EXAMPLE 1
```
Get-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin
```

This example returns attachment status.

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

### System.String
## NOTES
Cmdlet used to get remote file system attachement. 
To connect, attach and boot on Iso image, you have to use 
Invoke-RacBootToNetworkISO cmdlet

## RELATED LINKS

[Invoke-RacBootToNetworkISO
Dismount-RacVirtualDrive]()

