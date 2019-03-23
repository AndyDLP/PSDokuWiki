---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Save-DokuAttachment

## SYNOPSIS
Returns the binary data of a media file

## SYNTAX

```
Save-DokuAttachment [-FullName] <String[]> [[-Path] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Returns the binary data of a media file

## EXAMPLES

### EXAMPLE 1
```
Save-DokuAttachment -FullName 'value2' -Path 'value3'
```

## PARAMETERS

### -Force
Force creation of output file, overwriting any existing files with the same name

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullName
The full name of the file to get

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

### -Path
The path to save the attachment to, including filename & extension

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.IO.FileInfo
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
