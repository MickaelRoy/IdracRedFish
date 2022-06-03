---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# Get-RacUser

## SYNOPSIS
Cmdlet used to Get Idrac user(s) using REDFISH API.

## SYNTAX

### AutoExtend (Default)
```
Get-RacUser [-Name <String>] [<CommonParameters>]
```

### Creds
```
Get-RacUser -Ip_Idrac <String> -Credential <PSCredential> [-Name <String>] [<CommonParameters>]
```

### Session
```
Get-RacUser -Session <PSObject> [-Name <String>] [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to Get Idrac user(s) using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
Get-RacUser -Ip_Idrac 192.168.0.120 -Session $Session -Name 'Admin'
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

Required: False
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
Remove-RacUser
New-RacUser]()

