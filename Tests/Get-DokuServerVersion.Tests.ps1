Describe 'Get-DokuServerVersion' {
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
            Get-DokuServerVersion -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Get-DokuServerVersion -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When the server time is returned' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall  {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><string>Release 2018-04-22b "Greebo"</string></value></param></params></methodResponse>'
                    }
                )
            }

            $ResponseObject = Get-DokuServerVersion

            It 'Should return an object with all properties defined' {
                @('Server','Type','ReleaseDate','ReleaseName','RawVersion') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
            }
            It 'Should return an object with the correct value for Server' {
                $ResponseObject.Server | Should -Be 'wiki.example.com'
            }
            It 'Should return an object with the correct value for Type' {
                $ResponseObject.Type | Should -Be 'Release'
            }
            It 'Should return an object with the correct value for ReleaseDate' {
                $ResponseObject.ReleaseDate | Should -Be '2018-04-22b'
            }
            It 'Should return an object with the correct value for ReleaseName' {
                $ResponseObject.ReleaseName | Should -Be 'Greebo'
            }
            It 'Should return an object with the correct value for RawVersion' {
                $ResponseObject.RawVersion | Should -Be 'Release 2018-04-22b "Greebo"'
            }
        }
    }
}