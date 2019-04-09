---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Lock-DokuPage

## SYNOPSIS
Locks a DokuWiki page for 15 min

## SYNTAX

```
Lock-DokuPage [-FullName] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Locks the page so it cannot be modified by users for 15 min.
Also works for non-existent pages (block create name)

## EXAMPLES

### EXAMPLE 1
```powershell
Lock-DokuPage -FullName 'namespace:page'
```

## PARAMETERS

### -FullName
The full name of the to-be-locked page, including parent namespace(s)

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

### Nothing
## NOTES
AndyDLP - 2019-01-27

## RELATED LINKS

[https://github.com/AndyDLP/PSDokuWiki](https://github.com/AndyDLP/PSDokuWiki)

