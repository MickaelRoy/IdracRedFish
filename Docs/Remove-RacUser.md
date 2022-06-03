---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Remove-RacUser

## SYNOPSIS
Cmdlet used to remove Idrac user using REDFISH API.

## SYNTAX

### AutoExtend (Default)
```
Remove-RacUser -Name <String> [<CommonParameters>]
```

### Creds
```
Remove-RacUser -Ip_Idrac <String> -Credential <PSCredential> -Name <String> [<CommonParameters>]
```

### Session
```
Remove-RacUser -Session <PSObject> -Name <String> [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to remove Idrac user using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
Remove-RacUser -Ip_Idrac 192.168.0.120 -Session $Session -Name 'Admin'
```

This example remove Admin account, and make linux team frustrated.

## PARAMETERS

### -Credential
Specifies the Credential for Idrac connection.

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
{{ Fill Name Description }}

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
Specifies an Idrac session in which this cmdlet runs the command.
Enter a variable that contains PSCustomObjects or a command that 
creates or gets the Idrac Session Objects, such as a New-RacUser.

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

[Set-RacUserPassword
New-RacUser
Get-RacUser]()

