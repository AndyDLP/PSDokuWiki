---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki
schema: 2.0.0
---

# Add-DokuAclRule

## SYNOPSIS
Add an ACL to a namespace or page

## SYNTAX

```
Add-DokuAclRule [-FullName] <String[]> [-Principal] <String[]> [-Acl] <Int32> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Add an ACL to a namespace or page.
Use @groupname instead of user to add an ACL rule for a group.

## EXAMPLES

### EXAMPLE 1
```
Add-DokuAclRule -FullName 'study:home' -Principal 'testuser' -Acl 2
```

Add the Edit permission to testuser to the page home in the namespace study

### EXAMPLE 2
```
"User1","User2","@group1" | Add-DokuAclRule -FullName "namespace:page1","namespace:page2","namespace2:page1" -Acl 2
```

Add edit permissions for User1, User2 & group1 to the three pages; namespace:page1, namespace:page2 & namespace2:page1

### EXAMPLE 3
```
Add-DokuAclRule -FullName "namespace:page1","namespace:page2","namespace2:page1" -Acl 8 -Debug -Principal "User1","User2","@group1"
```

Same as above, but with an array of usernames (strings) for the parameter 'Principal'

## PARAMETERS

### -Acl
The permission level to apply to the user or @group
Pages / Namespaces: 0 = None, 1 = Read, 2 = Edit
Namespaces only:    4 = Create, 8 = Upload, 16 = Delete

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullName
The full name of the scope to apply to ACL to, can be one or more namespaces or a pages.

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

### -Principal
The username or @groupname to add to the ACL

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None
## NOTES
AndyDLP - 2018-05-26

## RELATED LINKS

[https://github.com/AndyDLP/PSDokuWiki](https://github.com/AndyDLP/PSDokuWiki)

