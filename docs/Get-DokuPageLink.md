---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuPageLink

## SYNOPSIS
Returns all links on a page

## SYNTAX

```
Get-DokuPageLink [-FullName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Returns all links on a given page

## EXAMPLES

### EXAMPLE 1
```powershell
$PageLinks = Get-DokuPageLink -FullName "namespace:namespace:page"
```

## PARAMETERS

### -FullName
The full page name for which to return the links

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject[]
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
