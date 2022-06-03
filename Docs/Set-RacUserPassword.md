---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Set-RacUserPassword

## SYNOPSIS
Cmdlet used to change Idrac password using REDFISH API.

## SYNTAX

### Creds
```
Set-RacUserPassword -Ip_Idrac <String> -Credential <PSCredential> [-TargetUser <String>] -NewPwd <String>
 [<CommonParameters>]
```

### Session
```
Set-RacUserPassword -Session <PSObject> [-TargetUser <String>] -NewPwd <String> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to change Idrac password using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
Set-RacUserPassword -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -TargetUser 'Admin' -NewPwd '[StrongPass]'
```

This example created a priviledged account

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

### -NewPwd
Specifies the password for the new account.

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

### -TargetUser
Specifies the User that you password has to be changed.
If absent RacUser
account take place.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Root
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Get-RacUser
New-RacUser
Remove-RacUser]()

