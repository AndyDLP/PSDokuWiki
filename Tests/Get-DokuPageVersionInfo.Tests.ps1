Describe 'Get-DokuPageVersionInfo' {
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
            Get-DokuPageVersionInfo -FullName 'rootns:ns:pagename' -VersionTimestamp 1573430400 -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Get-DokuPageVersionInfo -FullName 'rootns:ns:pagename' -VersionTimestamp 1573430400 -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When information for one page is returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><value><struct><member><name>FullName</name><value><string>rootns:ns:pagename</string></value></member><member><name>LastModified</name><value><string>11-11-2019</string></value></member><member><name>Author</name><value><string>User1</string></value></member><member><name>VersionTimestamp</name><value><int>1573430400</int></value></member></struct></value></methodResponse>'
                }
            )
        }
        $ResponseObject = Get-DokuPageVersionInfo -FullName 'rootns:ns:pagename' -VersionTimestamp 1573430400

        It 'Should return an object with all properties defined' {
            @('FullName','PageName','Author','VersionTimestamp','LastModified','RootNamespace','ParentNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:pagename'
        }
        It 'Should return an object with the correct value for PageName' {
            $ResponseObject.PageName | Should -Be 'pagename'
        }
        It 'Should return an object with the correct value for Author' {
            $ResponseObject.Author | Should -Be 'User1'
        }
        It 'Should return an object with the correct value for LastModified' {
            $ResponseObject.LastModified | Should -Be (Get-Date '11-11-2019')
        }
        It 'Should return an object with the correct value for VersionTimestamp' {
            $ResponseObject.VersionTimestamp | Should -Be 1573430400
        }
        It 'Should return an object with the correct value for ParentNamespace' {
            $ResponseObject.ParentNamespace | Should -Be 'ns'
        }
        It 'Should return an object with the correct value for RootNamespace' {
            $ResponseObject.RootNamespace | Should -Be 'rootns'
        }
        It 'Should call Invoke-DokuApiCall once' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1
        }
    }
    Context 'When information for two pages is returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><value><struct><member><name>FullName</name><value><string>rootns2:ns2:pagename2</string></value></member><member><name>LastModified</name><value><string>11-11-2019</string></value></member><member><name>Author</name><value><string>User1</string></value></member><member><name>VersionTimestamp</name><value><int>1573430400</int></value></member></struct></value></methodResponse>'
                }
            )
        }
        $ResponseObject = (Get-DokuPageVersionInfo -FullName 'rootns:ns:pagename','rootns2:ns2:pagename2' -VersionTimestamp 1573430400)[1]

        It 'Should return an object with all properties defined' {
            @('FullName','PageName','Author','VersionTimestamp','LastModified','RootNamespace','ParentNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns2:ns2:pagename2'
        }
        It 'Should return an object with the correct value for PageName' {
            $ResponseObject.PageName | Should -Be 'pagename2'
        }
        It 'Should return an object with the correct value for Author' {
            $ResponseObject.Author | Should -Be 'User1'
        }
        It 'Should return an object with the correct value for LastModified' {
            $ResponseObject.LastModified | Should -Be (Get-Date '11-11-2019')
        }
        It 'Should return an object with the correct value for VersionTimestamp' {
            $ResponseObject.VersionTimestamp | Should -Be 1573430400
        }
        It 'Should return an object with the correct value for ParentNamespace' {
            $ResponseObject.ParentNamespace | Should -Be 'ns2'
        }
        It 'Should return an object with the correct value for RootNamespace' {
            $ResponseObject.RootNamespace | Should -Be 'rootns2'
        }
        It 'Should call Invoke-DokuApiCall twice' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2
        }
    }
}