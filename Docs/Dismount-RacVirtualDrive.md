---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Dismount-RacVirtualDrive

## SYNOPSIS
Cmdlet used to diconnect virtual drive using REDFISH API.

## SYNTAX

### Creds
```
Dismount-RacVirtualDrive -Ip_Idrac <String> -Credential <PSCredential> [<CommonParameters>]
```

### Session
```
Dismount-RacVirtualDrive -Session <PSObject> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to diconnect virtual drive using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
Dismount-RacVirtualDrive -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin
```

This example disconnect ISO from the virtual drive.

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

### System.Management.Automation.PSCustomObject
## NOTES
Cmdlet used to get remote file system attachement. 
To connect, attach and boot on Iso image, you have to use 
Invoke-RacBootToNetworkISO cmdlet

## RELATED LINKS

[Invoke-RacBootToNetworkISO
Get-RacVirtualDriveStatus]()

