---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Search-DokuWiki

## SYNOPSIS
Search DokuWiki instance for matching pages

## SYNTAX

```
Search-DokuWiki [-SearchString] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Returns an array of matching pages similar to what is returned by Get-DokuPageList, snippets are provided for the first 15 results

## EXAMPLES

### EXAMPLE 1
```powershell
$MatchingPages = Search-DokuWiki -SearchString "VSS Admin"
```

Search all pages for mentions of the words "VSS" and "Admin".

## PARAMETERS

### -SearchString
The search string to match pages against, see 'https://www.dokuwiki.org/search' for syntax details

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject[]
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS

[https://github.com/AndyDLP/PSDokuWiki](https://github.com/AndyDLP/PSDokuWiki)

