---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Get-DokuPageHtml.md
schema: 2.0.0
---

# Get-DokuPageHtml

## SYNOPSIS
Get the rendered HTML for a given page

## SYNTAX

```
Get-DokuPageHtml [-FullName] <String[]> [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Get the rendered HTML for a given page or pages

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-DokuPageHtml -FullName 'rootns:ns:pagename'
```

Returns a page object with the rendered HTML as a property

### Example 2
```powershell
PS C:\> Get-DokuPageHtml -FullName 'rootns:ns:pagename' -Raw
```

Returns the rendered HTML as a string

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

### -Raw
Return just the raw HTML instead of an object

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### System.String[]

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
