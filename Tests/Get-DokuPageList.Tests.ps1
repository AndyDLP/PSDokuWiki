Describe 'Get-DokuPageList' {
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
            Get-DokuPageList -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Get-DokuPageList -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When a page is returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><value><struct><member><name>FullName</name><value><string>rootns:ns:pagename</string></value></member><member><name>Revision</name><value><int>11112019</int></value></member><member><name>LastModified</name><value><int>11112019</int></value></member><member><name>Size</name><value><int>2048</int></value></member></struct></value></methodResponse>'
                }
            )
        }
        $ResponseObject = Get-DokuPageList

        It 'Should return an object with all properties defined' {
            @('FullName','Revision','Size','LastModified','Pagename','RootNamespace','ParentNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:pagename'
        }
        It 'Should return an object with the correct value for Revision' {
            $ResponseObject.Revision | Should -Be 11112019
        }
        It 'Should return an object with the correct value for Size' {
            $ResponseObject.Size | Should -Be 2048
        }
        #It 'Should return an object with the correct value for LastModified' {
        #    $ResponseObject.LastModified | Should -Be (Get-Date '01-01-2019')
        #}
        It 'Should return an object with the correct value for ParentNamespace' {
            $ResponseObject.ParentNamespace | Should -Be 'ns'
        }
        It 'Should return an object with the correct value for RootNamespace' {
            $ResponseObject.RootNamespace | Should -Be 'rootns'
        }
        It 'Should return an object with the correct value for Pagename' {
            $ResponseObject.Pagename | Should -Be 'pagename'
        }
    }
}