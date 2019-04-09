---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version:
schema: 2.0.0
---

# Get-DokuPageData

## SYNOPSIS
Get the unrendered data from a page

## SYNTAX

```
Get-DokuPageData [-FullName] <String[]> [-Raw] [<CommonParameters>]
```

## DESCRIPTION
Get the unrendered data from a given page.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-DokuPageData -FullName 'rootns:ns:pagename'
```

Return a page object with the unrendered page data as a property

### Example 2
```powershell
PS C:\> Get-DokuPageData -FullName 'rootns:ns:pagename' -Raw
```

Returns the raw page data as a string

## PARAMETERS

### -FullName
The full page name for which to return the page data

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
Return only the raw wiki text, intead of an object

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
