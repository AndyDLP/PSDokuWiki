---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Set-DokuPageData.md
schema: 2.0.0
---

# Set-DokuPageData

## SYNOPSIS
Sets the raw wiki text of a page, will overwrite any existing page

## SYNTAX

```
Set-DokuPageData [-FullName] <String[]> [-RawWikiText] <String> [-MinorChange] [[-SummaryText] <String>]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets the raw wiki text of a page, will overwrite any existing page

## EXAMPLES

### EXAMPLE 1
```powershell
Set-DokuPageData -FullName 'namespace:pagename' -RawWikiText 'This will be the only text on the page'
```

Sets the page to contain only the given text for the given page

### EXAMPLE 2
```powershell
$Page = Set-DokuPageData -FullName 'namespace:pagename' -RawWikiText 'This will be the only text on the page' -MinorChange -SummaryText 'Overwritten page' -PassThru
```

Sets the page to contain only the given text for the given page, marks the change as minor, setting the summary text and passing the page object back out

## PARAMETERS

### -FullName
The fullname of the target page

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

### -MinorChange
State if the change was minor or not

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

### -PassThru
Pass the new page object back through

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RawWikiText
The raw wiki text to apply to the target page

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SummaryText
A short summary of the change, visible in the revisions list

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
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

## OUTPUTS

### System.Boolean, System.Management.Automation.PSObject
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS

[https://github.com/AndyDLP/PSDokuWiki](https://github.com/AndyDLP/PSDokuWiki)

