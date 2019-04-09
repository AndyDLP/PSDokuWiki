---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Get-DokuPageBackLink.md
schema: 2.0.0
---

# Get-DokuPageBackLink

## SYNOPSIS
Get all pages linking to this page

## SYNTAX

```
Get-DokuPageBackLink [-FullName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Get all pages linking to this page

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-DokuPageBackLink -FullName 'rootns:ns:pagename'
```

Get all backlinks for the given page

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Management.Automation.PSObject[]

## NOTES

## RELATED LINKS
