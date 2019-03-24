---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Invoke-DokuApiCall

## SYNOPSIS
Invokes a DokuWiki API method

## SYNTAX

```
Invoke-DokuApiCall [-MethodName] <String> [[-MethodParameters] <Array>] [<CommonParameters>]
```

## DESCRIPTION
Invokes a DokuWiki API method using the currently connected (By Connect-DokuServer) API endpoint.

## EXAMPLES

### EXAMPLE 1
```
$Response = Invoke-DokuApiCall -MethodName wiki.getAllPages
```

### EXAMPLE 2
```
$Response = Invoke-DokuApiCall -MethodName wiki.getPagaData -MethodParameters @('namespace:pagename')
```

## PARAMETERS

### -MethodName
The method name to invoke

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -MethodParameters
The parameters for the specified method

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSObject
## NOTES
AndyDLP - 2019

## RELATED LINKS
