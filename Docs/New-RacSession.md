---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# New-RacSession

## SYNOPSIS
Creates a persistent connection to an Idrac using REDFISH API.

## SYNTAX

```
New-RacSession [-Ip_Idrac] <String> [-Credential] <PSCredential> [[-Type] <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates a persistent connection to an Idrac using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
$session = New-RacSession -Ip_Idrac 10.117.24.166 -Credential $Credential
```

This example creates a session and stores detail in $session variable

## PARAMETERS

### -Credential
Specifies the credential for Idrac connection.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Ip_Idrac
Specifies the IpAddress of Remote system's Idrac.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 10.117.24.213
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies Content type for Invoke-Webrequest ("application/json" by default).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Application/json
Accept pipeline input: False
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

[Remove-RacSession]()

