---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Get-DokuPageVersionData.md
schema: 2.0.0
---

# Get-DokuPageVersionData

## SYNOPSIS
Returns the raw Wiki text for a specific version of a page

## SYNTAX

```
Get-DokuPageVersionData [-FullName] <String[]> [-VersionTimestamp] <Int32> [-Raw] [<CommonParameters>]
```

## DESCRIPTION
Returns the raw Wiki text for a specific version of a page

## EXAMPLES

### EXAMPLE 1
```powershell
$PageData = Get-DokuPageVersionData -FullName "namespace:namespace:page" -VersionTimestamp 1497464418
```

## PARAMETERS

### -FullName
The full page name for which to return the data, including any namespaces

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
Return only the raw data, rather than an object

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

### -VersionTimestamp
The timestamp for which version to get the info from

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
