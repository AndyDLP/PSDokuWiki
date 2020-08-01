---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Connect-DokuServer.md
schema: 2.0.0
---

# Connect-DokuServer

## SYNOPSIS
Connect to the API of a DokuWiki server

## SYNTAX

```
Connect-DokuServer [-ComputerName] <String> [-Credential] <PSCredential> [-Unencrypted] [[-APIPath] <String>]
 [-Force] [-UseBasicParsing] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Connect to the API of a DokuWiki server and allow authentication of subsequent API requests

## EXAMPLES

### Example 1
```powershell
PS C:\> Connect-DokuServer -ComputerName 'wiki.example.com' -Credential (Get-Credential)
```

Prompt for user credentials then connect to the default API endpoint: https://wiki.example.com/lib/exe/xmlrpc.php

### Example 2
```powershell
PS C:\> Connect-DokuServer -ComputerName 'wiki.example.com' -Credential (Get-Credential) -APIPath '/dokuwiki/lib/exe/xmlrpc.php' -Force
```

Prompt for user credentials then forcibly connects (cancels any open session if necessary) to the custom API endpoint: https://wiki.example.com/dokuwiki/lib/exe/xmlrpc.php 

## PARAMETERS

### -APIPath
The path to the api endpoint

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName
The server to connect to

```yaml
Type: String
Parameter Sets: (All)
Aliases: Server

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The credentials to use to connect

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

### -Force
Force a re-connection

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unencrypted
Connect to an unencrypted endpoint

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseBasicParsing
Use Basic parsing instead of IE DOM parsing

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
