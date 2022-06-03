---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Submit-RacPendingBiosSettings

## SYNOPSIS
Cmdlet used to apply BIOS attributes using REDFISH API.

## SYNTAX

### Default (Default)
```
Submit-RacPendingBiosSettings [-Restart] [-Wait] [<CommonParameters>]
```

### Creds
```
Submit-RacPendingBiosSettings -Ip_Idrac <String> -Credential <PSCredential> [-Restart] [-Wait]
 [<CommonParameters>]
```

### Session
```
Submit-RacPendingBiosSettings -Session <PSObject> [-Restart] [-Wait] [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to apply BIOS attributes previously set with 
Register-RacBiosSettings cmdlet.
The remote system will be restarted wether restart switch is specified,
then the script will wait until the job is done, or return job id.

## EXAMPLES

### EXAMPLE 1
```
Submit-RacPendingBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Restart
```

This example applies BIOS attributes and restart the system behind 192.168.0.120 IpAddress

### EXAMPLE 2
```
Submit-RacPendingBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin
```

This example raise a job id pending for reboot and returns the Job Id

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

### -Restart
Specifies wether the system has to restart to apply immediately

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### -Wait
{{ Fill Wait Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Cmdlet used to apply all registered BIOS attributes.
To register one or more attributes, you have to use Register-RacBiosSettings cmdlet

## RELATED LINKS

[Get-RacPendingBiosSettings
Register-RacBiosSettings
Get-RacBiosSettings]()

