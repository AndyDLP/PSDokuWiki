---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuAttachmentList

## SYNOPSIS
Returns a list of media files in a given namespace

## SYNTAX

```
Get-DokuAttachmentList [-Namespace] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Returns a list of media files in a given namespace

## EXAMPLES

### EXAMPLE 1
```
Get-DokuAttachmentList -Namespace 'namespace'
```

## PARAMETERS

### -Namespace
The namespace to search for attachments

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

### System.Management.Automation.PSObject[]
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
