Describe 'Add-DokuPageData' {
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
            Add-DokuPageData -FullName "namespace:pagename" -RawWikiText 'TEST' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Add-DokuPageData -FullName "namespace:pagename" -RawWikiText 'TEST' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When PassThru is used' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                }
            )
        }
        $ResponseObject = Add-DokuPageData -FullName 'rootns:ns:pagename' -RawWikiText 'TEST' -MinorChange -SummaryText 'Sum' -PassThru

        It 'Should return an object with all properties defined' {
            @('FullName','AddedText','MinorChange','SummaryText','PageName','ParentNamespace','RootNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:pagename'
        }
        It 'Should return an object with the correct value for AddedText' {
            $ResponseObject.AddedText | Should -Be 'TEST'
        }
        It 'Should return an object with the correct value for MinorChange' {
            $ResponseObject.MinorChange | Should -Be $true
        }
        It 'Should return an object with the correct value for SummaryText' {
            $ResponseObject.SummaryText | Should -Be 'Sum'
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
    }
}