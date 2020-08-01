---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version:
schema: 2.0.0
---

# ConvertTo-XmlRpcMethodCall

## SYNOPSIS
Create a XML RPC Method Call string

## SYNTAX

```
ConvertTo-XmlRpcMethodCall [-Name] <String> [[-Params] <Array>] [[-CustomTypes] <Array>] [<CommonParameters>]
```

## DESCRIPTION
Create a XML RPC Method Call string

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-XmlRpcMethodCall -Name updateName -Params @('oldName', 'newName')
----------
Returns (line split and indentation just for conveniance)
<?xml version=""1.0""?>
<methodCall>
  <methodName>updateName</methodName>
  <params>
    <param><value><string>oldName</string></value></param>
    <param><value><string>newName</string></value></param>
  </params>
</methodCall>
```

## PARAMETERS

### -CustomTypes
Array of custom Object Types to be considered when converting

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the Method to be called

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Params
Parameters to be passed to the Method

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### string
### array
## OUTPUTS

### string
## NOTES
Author   : Oliver Lipkau \<oliver@lipkau.net\>
2014-06-05 Initial release

Sourced from Oliver Lipkau's XmlRpc module on powershellgallery
Modified to use DokuWiki compatible type names (case sensitive etc)

## RELATED LINKS
