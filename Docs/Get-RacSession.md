---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Get-RacSession

## SYNOPSIS
Cmdlet used to diconnect virtual drive using REDFISH API.

## SYNTAX

### null (Default)
```
Get-RacSession [<CommonParameters>]
```

### InstanceId
```
Get-RacSession -InstanceId <String> [<CommonParameters>]
```

### SessionUri
```
Get-RacSession -SessionUri <String> [<CommonParameters>]
```

### Id
```
Get-RacSession -Id <Int32> [<CommonParameters>]
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

### -Id
{{ Fill Id Description }}

```yaml
Type: Int32
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InstanceId
{{ Fill InstanceId Description }}

```yaml
Type: String
Parameter Sets: InstanceId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -SessionUri
{{ Fill SessionUri Description }}

```yaml
Type: String
Parameter Sets: SessionUri
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

