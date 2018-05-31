function Add-DokuPageData {
<#
	.SYNOPSIS
		Appends wiki text to the end of a page.
	
	.DESCRIPTION
		Appends wiki text to the end of a page. Can create new page or namespace by referencing a (currnely non-existant) page / namespace
	
	.PARAMETER FullName
		The FullName of the to be edited page
	
	.PARAMETER DokuSession
		The DokuSession to add the page data to
	
	.PARAMETER RawWikiText
		The raw wiki text to append to the page
	
	.PARAMETER PassThru
		Pass the newly created object back out
	
	.PARAMETER MinorChange
		State if the change was minor or not
	
	.PARAMETER SummaryText
		A short summary of the change, visible in the revisions list
	
	.EXAMPLE
		PS C:\> Add-DokuPageData -DokuSession $DokuSession -FullName 'study:home' -RawWikiText 'TEST TEST TEST'
	
	.OUTPUTS
		System.Boolean, System.Management.Automation.PSObject
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([boolean], [psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession to add the page data to')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The FullName of the to-be-uploaded file, including namespace(s)')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The raw wiki text to append to the page')]
		[ValidateNotNullOrEmpty()]
		[string]$RawWikiText,
		[Parameter(Position = 4,
				   HelpMessage = 'State if the change was minor or not')]
		[switch]$MinorChange,
		[Parameter(Position = 5,
				   HelpMessage = 'A short summary of the change')]
		[string]$SummaryText,
		[Parameter(Position = 6,
				   HelpMessage = 'Pass the newly created object back out')]
		[switch]$PassThru
	)
	
	$payload = (ConvertTo-XmlRpcMethodCall -Name "dokuwiki.appendPage" -Params @($FullName, $RawWikiText, @{ sum = $SummaryText; minor = $MinorChange })) -replace "String", "string"
	$payload = $payload -replace "Boolean","boolean"
	$payload = $payload -replace "True","1"
	$payload = $payload -replace "False","0"
	if ($DokuSession.SessionMethod -eq "HttpBasic") {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
	} else {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
	}
	
	if ($PassThru) {
		$PageObject = New-Object PSObject -Property @{
			FullName = $FullName
			AddedText = $RawWikiText
			MinorChange = $MinorChange
			SummaryText = $SummaryText
			PageName = ($FullName -split ":")[-1]
			ParentNamespace = ($FullName -split ":")[-2]
			RootNamespace = ($FullName -split ":")[0]
		}
		return $PageObject
	} else {
		$ResultBoolean = [boolean]([xml]$httpResponse.Content | Select-Xml -XPath "//value/boolean").node.InnerText
		return $ResultBoolean
	}
}