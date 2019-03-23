---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Connect-DokuServer

## SYNOPSIS
Connect to a DokuWiki API endpoint

## SYNTAX

```
Connect-DokuServer [-ComputerName] <String> [-Credential] <PSCredential> [-Unencrypted] [[-APIPath] <String>]
 [-Force] [<CommonParameters>]
```

## DESCRIPTION
Connect to a DokuWiki API endpoint to enable subsequent DokuWiki commands from the same PowerShell session

## EXAMPLES

### EXAMPLE 1
```
Connect-DokuServer -ComputerName wiki.example.com -Credential (Get-Credential)
```

## PARAMETERS

### -APIPath
The web path that the api executable is at.
DokuWiki default is /lib/exe/xmlrpc.php

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: /lib/exe/xmlrpc.php
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName
The computer name (single label or FQDN) / IP to connect to

```yaml
Type: String
Parameter Sets: (All)
Aliases: Server

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The credentials used to authenticate to the API endpoint

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Force a connection even if one is already established to the same endpoint

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unencrypted
Specify that the APi endpoint is at a http rather than https address.
Recommended for development only!!

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Nothing
## NOTES
AndyDLP - 2019

## RELATED LINKS

[https://github.com/AndyDLP/PSDokuWiki](https://github.com/AndyDLP/PSDokuWiki)

