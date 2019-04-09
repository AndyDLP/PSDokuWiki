---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Get-DokuPageVersion.md
schema: 2.0.0
---

# Get-DokuPageVersion

## SYNOPSIS
Returns the available versions of a Wiki page.

## SYNTAX

```
Get-DokuPageVersion [-FullName] <String[]> [[-Offset] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Returns the available versions of a Wiki page.
The number of pages in the result is controlled via the recent configuration setting.
The offset can be used to list earlier versions in the history

## EXAMPLES

### EXAMPLE 1
```powershell
$PageVersions = Get-DokuPageVersion -FullName "namespace:namespace:page"
```

## PARAMETERS

### -FullName
The full page name for which to return the data

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Offset
used to list earlier versions in the history

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject[]
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
