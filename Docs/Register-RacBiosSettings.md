---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Register-RacBiosSettings

## SYNOPSIS
Cmdlet used to set one BIOS attribute of BIOS attributes using REDFISH API.

## SYNTAX

### Creds
```
Register-RacBiosSettings -Ip_Idrac <String> -Credential <PSCredential> -Name <String> -Value <String>
 [<CommonParameters>]
```

### Session
```
Register-RacBiosSettings -Session <PSObject> -Name <String> -Value <String> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to set one BIOS attribute of BIOS attributes using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
Register-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Name SysProfile -Value PerfOptimized
```

This example set setting BIOS attribute "System Profile" to Performance

### EXAMPLE 2
```
Register-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Name WorkloadProfile -Value VtOptimizedProfile
```

This example set setting BIOS attribute "Workload Profile" to "Virtualization Optimized Performance Profile"

### EXAMPLE 3
```
Register-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Name BootMode -Value Uefi
```

This example set setting BIOS attribute "BootMode" to "Uefi"

### EXAMPLE 4
```
Register-RacBiosSettings -RacUser root -RacPwd 'calvin'-Name 'Slot1' -Value 'Disabled' -Ip_Idrac 10.117.9.222
```

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

### -Name
Specifies the bios attribute name

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

### -Value
Specifies the bios attribute value

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Cmdlet used to either set one BIOS attribute..
To register one or more attributes, you have to use Register-RacBiosSettings cmdlet
When registering a BIOS attribute, make sure you pass in exact name of the attribute 
and value since these are case sensitive.
Example: For attribute MemTest, you must pass in "MemTest".
Passing in "memtest" will fail.

To apply one or more attributes, you have to use Submit-RacBiosSettings cmdlet.

## RELATED LINKS

[Get-RacPendingBiosSettings
Submit-RacPendingBiosSettings
Get-RacBiosSettings]()

