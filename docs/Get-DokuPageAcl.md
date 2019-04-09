---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Get-DokuPageAcl.md
schema: 2.0.0
---

# Get-DokuPageAcl

## SYNOPSIS
Gets the ACL for a given page

## SYNTAX

```
Get-DokuPageAcl [-FullName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Gets the ACL as an integer for a given page for the currently connected user

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-DokuPageAcl -Fullname 'rootns:ns:pagename'
```

Will return the page object with ACL attribute

## PARAMETERS

### -FullName
The full page name for which to return the ACL

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
