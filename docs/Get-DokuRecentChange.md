---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuRecentChange

## SYNOPSIS
Returns a list of recent changes since given timestamp

## SYNTAX

```
Get-DokuRecentChange [-VersionTimestamp] <Int32> [<CommonParameters>]
```

## DESCRIPTION
Returns a list of recent changes since given timestamp.
As stated in recent_changes: Only the most recent change for each page is listed, regardless of how many times that page was changed

## EXAMPLES

### EXAMPLE 1
```
Get-DokuRecentChanges -VersionTimestamp $VersionTimestamp
```

## PARAMETERS

### -VersionTimestamp
Get all pages since this timestamp

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject[]
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
