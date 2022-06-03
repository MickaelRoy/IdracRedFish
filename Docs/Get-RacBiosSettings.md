---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Get-RacBiosSettings

## SYNOPSIS
Cmdlet used to get BIOS attributes using REDFISH API.

## SYNTAX

### Creds
```
Get-RacBiosSettings -Ip_Idrac <String> -Credential <PSCredential> [<CommonParameters>]
```

### Session
```
Get-RacBiosSettings -Session <PSObject> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to get BIOS attributes using REDFISH API.

The remote system will be either restarted if restart switch is specified,
then the script will wait until the job is done, or return job id.

## EXAMPLES

### EXAMPLE 1
```
Get-RacBiosSettings -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin
```

This example displays all BIOS attributes.

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
Cmdlet used to get all BIOS attributes.
to register one or more attributes,
you have to use Register-RacBiosSettings cmdlet

## RELATED LINKS

[Get-RacPendingBiosSettings
Register-RacBiosSettings
Submit-RacPendingBiosSettings]()

