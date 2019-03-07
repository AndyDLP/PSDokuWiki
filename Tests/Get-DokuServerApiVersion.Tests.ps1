Describe 'Get-DokuServerApiVersion' {
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
            Get-DokuServerApiVersion -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Get-DokuServerApiVersion -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When the API version is returned' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall  {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><value><int>10</int></value></methodResponse>'
                    }
                )
            }
            $ResponseObject = Get-DokuServerApiVersion

            It 'Should return an object with all properties defined' {
                @('Server','XmlRpcVersion') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
            }
            It 'Should return an object with the correct value for Server' {
                $ResponseObject.Server | Should -Be 'wiki.example.com'
            }
            It 'Should return an object with the correct value for XmlRpcVersion' {
                $ResponseObject.XmlRpcVersion | Should -Be 10
            }
        }
    }
}