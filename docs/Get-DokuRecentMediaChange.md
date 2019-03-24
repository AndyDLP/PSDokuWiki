---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuRecentMediaChange

## SYNOPSIS
Returns a list of recently changed media since given timestamp

## SYNTAX

```
Get-DokuRecentMediaChange [-VersionTimestamp] <Int32> [<CommonParameters>]
```

## DESCRIPTION
Returns a list of recently changed media since given timestamp

## EXAMPLES

### EXAMPLE 1
```
Get-DokuRecentMediaChange -VersionTimestamp $VersionTimestamp
```

## PARAMETERS

### -VersionTimestamp
Get all media / attachment changes since this timestamp

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject[]
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
