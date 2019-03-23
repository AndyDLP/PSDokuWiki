---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuServer

## SYNOPSIS
Gets any current connection to a DokuWiki API

## SYNTAX

```
Get-DokuServer [-IsConnected] [<CommonParameters>]
```

## DESCRIPTION
Gets any current connection to a DokuWiki API

## EXAMPLES

### EXAMPLE 1
```
Get-DokuServer | Format-List -Property *
```

## PARAMETERS

### -IsConnected
Only return TRUE if currently connected and FALSE if not

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### DokuWiki.Session.Detail,Boolean
## NOTES
AndyDLP - 2019

## RELATED LINKS

[https://github.com/AndyDLP/PSDokuWiki](https://github.com/AndyDLP/PSDokuWiki)

