---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuAttachmentInfo

## SYNOPSIS
Returns information about a media file

## SYNTAX

```
Get-DokuAttachmentInfo [-FullName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Returns information about an attached file

## EXAMPLES

### EXAMPLE 1
```
Get-DokuAttachmentInfo -FullName 'namespace:filename.ext'
```

## PARAMETERS

### -FullName
The full name of the file to get information from

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
