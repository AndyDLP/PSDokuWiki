---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://www.github.com/AndyDLP/PSDokuWiki/docs/Add-DokuAclRule.md
schema: 2.0.0
---

# Add-DokuAclRule

## SYNOPSIS
Add an ACL rule to a page or namespace

## SYNTAX

```
Add-DokuAclRule [-FullName] <String[]> [-Principal] <String[]> [-Acl] <Int32> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Add an ACL rule to a page or namespace. 1,2,4,8,16

## EXAMPLES

### Example 1
```powershell
PS C:\> AddDokuAclRule -FullName 'ns:pagename' -Principal 'User1' -Acl 8
```

Give User1 delete permissions on the page: 'pagename' in the namespace 'ns'

## PARAMETERS

### -Acl
The permission level to apply to the ACL as an integer

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullName
The full name of the scope to apply to ACL to

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
The username or @groupname to add to the ACL

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
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
Default value: None
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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
