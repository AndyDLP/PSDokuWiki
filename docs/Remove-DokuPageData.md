---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Set-DokuPageData.md
schema: 2.0.0
---

# Set-DokuPageData

## SYNOPSIS
Removes a page

## SYNTAX

```
Remove-DokuPageData [-FullName] <String[]> [-SummaryText] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes a page

## EXAMPLES

### EXAMPLE 1
```powershell
Remove-DokuPageData -FullName 'namespace:pagename'
```


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


### -SummaryText
A short summary of the change, visible in the revisions list

```yaml
Type: String
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

