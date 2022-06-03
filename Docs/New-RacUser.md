---
external help file: IdracRedfish-help.xml
Module Name: IdracRedfish
online version:
schema: 2.0.0
---

# New-RacUser

## SYNOPSIS
Cmdlet used to create Idrac user using REDFISH API.

## SYNTAX

### AutoExtend (Default)
```
New-RacUser -NewUser <String> -NewPwd <String> [-Privilege <String>] [-Enabled] [-ExtendRights]
 [-IpmiSerialPrivilege <String>] [-IpmiLanPrivilege <String>] [-SolEnable <String>] [<CommonParameters>]
```

### Creds
```
New-RacUser -Ip_Idrac <String> -Credential <PSCredential> -NewUser <String> -NewPwd <String>
 [-Privilege <String>] [-Enabled] [-ExtendRights] [-IpmiSerialPrivilege <String>] [-IpmiLanPrivilege <String>]
 [-SolEnable <String>] [<CommonParameters>]
```

### Session
```
New-RacUser -Session <PSObject> -NewUser <String> -NewPwd <String> [-Privilege <String>] [-Enabled]
 [-ExtendRights] [-IpmiSerialPrivilege <String>] [-IpmiLanPrivilege <String>] [-SolEnable <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Cmdlet used to create Idrac user using REDFISH API.

## EXAMPLES

### EXAMPLE 1
```
New-RacUser -Ip_Idrac 192.168.0.120 -RacUser root -RacPwd calvin -NewUser 'Admin' -NewPwd '[StrongPass]' -Privilege Administrator
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

### -Enabled
Specifies wether the account have to be enabled.
Default is true

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendRights
Specifies wether the account Privilege have to be extended to
IpmiSerialPrivilege and IpmiLanPrivilege or not.
Default is true

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
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

### -IpmiLanPrivilege
Specifies the IpmiLanPrivilege permission if not extended from usual
Privilege.

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

### -IpmiSerialPrivilege
Specifies the IpmiSerialPrivilege permission if not extended from usual
Privilege.

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

### -NewUser
Specifies the Username for the new account.

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

### -Privilege
Specifies the permission for the new account.
Default is None

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

### -SolEnable
Specifies wether SerialOnLan have to be enabled.
Default is true

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Enabled
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
Get-RacUser]()

