---
external help file: PSDokuWiki-help.xml
Module Name: PSDokuWiki
online version: https://github.com/AndyDLP/PSDokuWiki/blob/master/docs/Add-DokuPageData.md
schema: 2.0.0
---

# Add-DokuPageData

## SYNOPSIS
Append data (raw wiki text) to a page

## SYNTAX

```
Add-DokuPageData [-FullName] <String[]> [-RawWikiText] <String> [-MinorChange] [[-SummaryText] <String>]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Append data (raw wiki text) to a page, will create the page if it does not exist

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-DokuPageData -FullName 'ns:pagename' -RawWikiText 'Hello World'
```

Appends Hello World to the bottom of the page called pagename in the namespace called ns

### Example 2
```powershell
PS C:\> $Page = Add-DokuPageData -FullName 'ns:pagename' -RawWikiText 'Hello People' -MinorCHange -SummaryText 'HW' -PassThru
```

Appends Hello World to the bottom of the page called pagename in the namespace called ns. Marks the change as minor and adds the summary as 'HW'.
Also passes the page object back out which allows it to be captured into the variable $Page

## PARAMETERS

### -FullName
The full name of the to-be-edited page, including parent namespace(s)

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

### -MinorChange
State if the change was minor or not

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Pass the newly created object back out

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RawWikiText
The raw wiki text to append to the page

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SummaryText
A short summary of the change

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
