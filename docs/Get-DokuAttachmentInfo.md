---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://www.github.com/AndyDLP/PSDokuWiki/docs/Get-DokuAttachmentInfo.md
schema: 2.0.0
---

# Get-DokuAttachmentInfo

## SYNOPSIS
Get information about an attached file

## SYNTAX

```
Get-DokuAttachmentInfo [-FullName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Get information about an attached file such as size, author and date modified

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-DokuAttachmentInfo -FullName 'ns:file.jpg'
```

Gets information about the attachment called 'file.jpg' in the namespace 'ns'

## PARAMETERS

### -FullName
The full name of the file to get information from

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
