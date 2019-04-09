---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version:  https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Unlock-DokuPage.md
schema: 2.0.0
---

# Unlock-DokuPage

## SYNOPSIS
Unlocks a DokuWiki page

## SYNTAX

```
Unlock-DokuPage [-FullName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Unlocks the page so it can be modified by users again.

## EXAMPLES

### EXAMPLE 1
```powershell
Unlock-DokuPage -FullName 'namespace:page'
```

Unlocks the page for normal use again

## PARAMETERS

### -FullName
The full name of the to-be-unlocked page, including parent namespace(s)

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

### Nothing
## NOTES
AndyDLP - 2019-01-27

## RELATED LINKS

[https://github.com/AndyDLP/PSDokuWiki](https://github.com/AndyDLP/PSDokuWiki)

