---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version:
schema: 2.0.0
---

# ConvertTo-XmlRpcType

## SYNOPSIS
Convert Data into XML declared datatype string

## SYNTAX

```
ConvertTo-XmlRpcType [-InputObject] <Object> [-CustomTypes <Array>] [<CommonParameters>]
```

## DESCRIPTION
Convert Data into XML declared datatype string

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-XmlRpcType "Hello World"
--------
Returns
<value><string>Hello World</string></value>
```

### EXAMPLE 2
```
ConvertTo-XmlRpcType 42
--------
Returns
<value><int32>42</int32></value>
```

## PARAMETERS

### -CustomTypes
Array of custom Object Types to be considered when converting

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Object to be converted to XML string

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### string
## NOTES
Author   : Oliver Lipkau \<oliver@lipkau.net\>
2014-06-05 Initial release

Sourced from Oliver Lipkau's XmlRpc module on powershellgallery
Modified to use DokuWiki compatible type names (case sensitive etc)

## RELATED LINKS
