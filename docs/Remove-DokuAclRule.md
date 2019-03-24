---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Remove-DokuAclRule

## SYNOPSIS
Remove a principal from an ACL

## SYNTAX

```
Remove-DokuAclRule [-FullName] <String[]> [-Principal] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Allows you to remove a principal from an ACL.
Use @groupname instead of user to remove an ACL rule for a group.

## EXAMPLES

### EXAMPLE 1
```
Remove-DokuAclRule -FullName 'study' -Principal 'testuser'
```

## PARAMETERS

### -FullName
The full name of the page or namespace to remove the ACL from

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

### -Principal
The username or groupname to remove

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Nothing
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS
