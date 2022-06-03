---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Set-RacPowerState

## SYNOPSIS
Cmdlet used to change power state using REDFISH API.

## SYNTAX

### Creds
```
Set-RacPowerState -Ip_Idrac <String> -Credential <PSCredential> -Action <String> [<CommonParameters>]
```

### Session
```
Set-RacPowerState -Session <PSObject> -Action <String> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to change power state of a remote system using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
Set-RacPowerState -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -Action On
```

This example returns power On the remote system behind 192.168.0.120

## PARAMETERS

### -Action
{{ Fill Action Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: On
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

[Invoke-RacPower]()

