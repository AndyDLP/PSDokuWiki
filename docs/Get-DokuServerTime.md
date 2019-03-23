---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Get-DokuServerTime

## SYNOPSIS
Returns the current time from the remote wiki server as Unix timestamp

## SYNTAX

```
Get-DokuServerTime [<CommonParameters>]
```

## DESCRIPTION
Returns the current time from the remote wiki server as Unix timestamp

## EXAMPLES

### EXAMPLE 1
```
$serverTime = Get-DokuServerTime
```

### EXAMPLE 2
```
$UnixserverTime = Get-DokuServerTime -Raw
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.DateTime, System.Int32
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
