---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Remove-RacSession

## SYNOPSIS
Delete a persistent connection to an Idrac using REDFISH API.

## SYNTAX

### null (Default)
```
Remove-RacSession [<CommonParameters>]
```

### Session
```
Remove-RacSession [-Session] <Object[]> [<CommonParameters>]
```

### InstanceId
```
Remove-RacSession -InstanceId <String> [<CommonParameters>]
```

### SessionUri
```
Remove-RacSession -SessionUri <String> [<CommonParameters>]
```

### Id
```
Remove-RacSession -Id <Int32> [<CommonParameters>]
```

### All
```
Remove-RacSession [-All] [<CommonParameters>]
```

## DESCRIPTION
Delete a persistent connection to an Idrac using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
$session = Remove-RacSession -session $session
```

This example deletes a session from $session variable

### EXAMPLE 2
```
$session = $session | Remove-RacSession
```

This example deletes a session from $session variable

## PARAMETERS

### -All
{{ Fill All Description }}

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
{{ Fill Id Description }}

```yaml
Type: Int32
Parameter Sets: Id
Aliases: Index

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

### -Session
{{ Fill Session Description }}

```yaml
Type: Object[]
Parameter Sets: Session
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
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
Becarefull of session expiration on Idrac end.
When session expires, you may get this erro "The underlying connection was closed..."
Expired sessions are kept stuck in idrac.

## RELATED LINKS

[New-RacSession]()

