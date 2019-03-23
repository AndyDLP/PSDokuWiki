---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuAllPage

## SYNOPSIS
Returns a list of all Wiki pages

## SYNTAX

```
Get-DokuAllPage [<CommonParameters>]
```

## DESCRIPTION
Returns a list of all Wiki pages from the DokuWiki API.
Includes the current user's ACL status of each page

## EXAMPLES

### EXAMPLE 1
```
$AllPages = Get-DokuAllPage
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject[]
## NOTES
AndyDLP - 2018-05-26 Updated - 2019-02-20

## RELATED LINKS
