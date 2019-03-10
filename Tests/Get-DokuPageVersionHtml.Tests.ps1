Describe 'Get-DokuPageVersionHtml' {
    Set-StrictMode -Version latest
    Context 'When the Invoke-DokuApiCall command fails' {
        It 'Should display the exception message' {
            Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $false
                        ExceptionMessage = 'Test Exception'
                    }
                )
            }
            Get-DokuPageVersionHtml -FullName 'rootns:ns:pagename' -VersionTimestamp 123456 -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Exception: Test Exception'
        }
        It 'Should display the fault code & string' {
            Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $false
                        FaultCode = 12345
                        FaultString = 'Fault String'
                    }
                )
            }
            Get-DokuPageVersionHtml -FullName 'rootns:ns:pagename' -VersionTimestamp 123456 -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When data for one page is requested' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><string>&lt;h1 class="sectionedit1" id="title"&gt;Title&lt;/h1&gt;&lt;div class="level1"&gt;&lt;p&gt;Page text&lt;/p&gt;&lt;/div&gt;</string></value></param></params></methodResponse>'
                }
            )
        }
        $ResponseObject = Get-DokuPageVersionHtml -FullName 'rootns:ns:pagename' -VersionTimestamp 123456

        It 'Should return an object with all properties defined' {
            @('FullName','RenderedHtml','VersionTimestamp','PageName','RootNamespace','ParentNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for VersionTimestamp' {
            $ResponseObject.VersionTimestamp | Should -Be 123456
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:pagename'
        }
        It 'Should return an object with the correct value for RenderedHtml' {
            $ResponseObject.RenderedHtml | Should -Be '<h1 class="sectionedit1" id="title">Title</h1><div class="level1"><p>Page text</p></div>'
        }
        It 'Should return an object with the correct value for PageName' {
            $ResponseObject.PageName | Should -Be 'pagename'
        }
        It 'Should return an object with the correct value for ParentNamespace' {
            $ResponseObject.ParentNamespace | Should -Be 'ns'
        }
        It 'Should return an object with the correct value for RootNamespace' {
            $ResponseObject.RootNamespace | Should -Be 'rootns'
        }
        It 'Should call Invoke-DokuApiCall once' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWIki -Exactly -Times 1
        }
    }
    Context 'When data for two pages is requested' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><string>&lt;h1 class="sectionedit1" id="title"&gt;Title&lt;/h1&gt;&lt;div class="level1"&gt;&lt;p&gt;Page text&lt;/p&gt;&lt;/div&gt;</string></value></param></params></methodResponse>'
                }
            )
        }
        $ResponseObject = (Get-DokuPageVersionHtml -FullName 'rootns:ns:pagename','rootns2:ns2:pagename2' -VersionTimestamp 123456)[1]

        It 'Should return an object with all properties defined' {
            @('FullName','RenderedHtml','VersionTimestamp','PageName','RootNamespace','ParentNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for VersionTimestamp' {
            $ResponseObject.VersionTimestamp | Should -Be 123456
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns2:ns2:pagename2'
        }
        It 'Should return an object with the correct value for RenderedHtml' {
            $ResponseObject.RenderedHtml | Should -Be '<h1 class="sectionedit1" id="title">Title</h1><div class="level1"><p>Page text</p></div>'
        }
        It 'Should return an object with the correct value for PageName' {
            $ResponseObject.PageName | Should -Be 'pagename2'
        }
        It 'Should return an object with the correct value for ParentNamespace' {
            $ResponseObject.ParentNamespace | Should -Be 'ns2'
        }
        It 'Should return an object with the correct value for RootNamespace' {
            $ResponseObject.RootNamespace | Should -Be 'rootns2'
        }
        It 'Should call Invoke-DokuApiCall twice' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWIki -Exactly -Times 2
        }
    }
    Context 'When the Raw switch is used' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><string>&lt;h1 class="sectionedit1" id="title"&gt;Title&lt;/h1&gt;&lt;div class="level1"&gt;&lt;p&gt;Page text&lt;/p&gt;&lt;/div&gt;</string></value></param></params></methodResponse>'
                }
            )
        }
        $ResponseObject = Get-DokuPageVersionHtml -FullName 'rootns:ns:pagename' -VersionTimestamp 123456 -Raw

        It 'Should return a string' {
            $ResponseObject | Should -BeOfType [string]
        }
        It 'Should return the raw page data' {
            $ResponseObject | Should -Be '<h1 class="sectionedit1" id="title">Title</h1><div class="level1"><p>Page text</p></div>'
        }
    }
}