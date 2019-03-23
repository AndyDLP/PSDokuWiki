---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuPageData

## SYNOPSIS
Returns the editor Wiki text for a page

## SYNTAX

```
Get-DokuPageData [-FullName] <String[]> [-Raw] [<CommonParameters>]
```

## DESCRIPTION
Returns the editor Wiki text for a page

## EXAMPLES

### EXAMPLE 1
```
$PageData = Get-DokuPageData -FullName "namespace:namespace:page"
```

### EXAMPLE 2
```
$PageData = Get-DokuPageData -FullName "namespace:namespace:page" -Raw
```

## PARAMETERS

### -FullName
The full page name for which to return the data, including any namespaces

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Raw
Return only the raw wiki text, intead of an object

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
