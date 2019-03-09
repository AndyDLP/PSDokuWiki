Describe 'Save-DokuAttachment' {
    Set-StrictMode -Version latest

    # Create test file
    Set-Content -Path 'TestDrive:\test.doc' -Value "TestFileContents"
    $ReferenceItem = Get-Item -Path 'TestDrive:\test.doc'
    $SaveToPath = Join-Path -Path $ReferenceItem.Directory -ChildPath 'test2.doc'
    
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
            Save-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $SaveToPath -Force -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Save-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $SaveToPath -Force -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When an attachment is downloaded successfully' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><base64>VGVzdEZpbGVDb250ZW50cw0K</base64></value></param></params></methodResponse>'
                }
            )
        }
        $ResponseObject = Save-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $SaveToPath -Force

        It 'Should return an object of type System.IO.FileInfo' {
            $ResponseObject | Should -BeOfType [System.IO.FileInfo]
        }
        It 'Should return the exact object requested' {
            (Get-FileHash -Path $ResponseObject).Hash | Should -Be (Get-FileHash -Path $ReferenceItem).Hash
        }
        It 'Should call Invoke-DokuApiCall once' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1
        }
    }
    Context 'When an attachment already exists and Force is not used' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><base64>VGVzdEZpbGVDb250ZW50cw0K</base64></value></param></params></methodResponse>'
                }
            )
        }
        Set-Content -Path $SaveToPath -Value "TestFileContents" -Force

        It 'Should throw an error' {
            { Save-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $SaveToPath } | Should -Throw
        }
    }
}