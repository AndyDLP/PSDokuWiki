---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Get-DokuAttachmentList.md
schema: 2.0.0
---

# Get-DokuAttachmentList

## SYNOPSIS
Get all attachments in a namespace

## SYNTAX

```
Get-DokuAttachmentList [-Namespace] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Get all attachments in a given namespace

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-DokuAttachmentList -Namespace 'rootns:ns'
```

Gets all attachments in the namespace 'rootns:ns'

## PARAMETERS

### -Namespace
The namespace to search for attachments

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
