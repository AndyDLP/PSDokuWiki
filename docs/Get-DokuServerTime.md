---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Get-DokuServerTime.md
schema: 2.0.0
---

# Get-DokuServerTime

## SYNOPSIS
Returns the current time from the remote wiki server as Unix timestamp

## SYNTAX

```
Get-DokuServerTime [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Returns the current time from the remote wiki server as Unix timestamp

## EXAMPLES

### EXAMPLE 1
```
$serverTime = Get-DokuServerTime
```

### EXAMPLE 2
```powershell
$UnixserverTime = Get-DokuServerTime -Raw
```

## PARAMETERS

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.DateTime, System.Int32
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS

[https://github.com/AndyDLP/PSDokuWiki](https://github.com/AndyDLP/PSDokuWiki)

