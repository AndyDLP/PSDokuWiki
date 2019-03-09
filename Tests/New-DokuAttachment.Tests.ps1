Describe 'New-DokuAttachment' {
    Set-StrictMode -Version latest

    # Create test file
    Set-Content -Path 'TestDrive:\test.doc' -Value "TestFileContents"
    $TestItemPath = (Get-Item -Path 'TestDrive:\test.doc').Fullname
    
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
            New-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $TestItemPath -Force -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            New-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $TestItemPath -Force -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When an attachment is uploaded successfully with PassThru' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><string>rootns:ns:test.doc</string></value></param></params></methodResponse>'
                }
            )
        }
        $ResponseObject = New-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $TestItemPath -Force -PassThru

        It 'Should return an object with all properties defined' {
            @('FullName','SourceFilePath','Size','SourceFileLastModified','FileName','ParentNamespace','RootNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:test.doc'
        }
        It 'Should return an object with the correct value for SourceFilePath' {
            $ResponseObject.SourceFilePath | Should -Be (Get-Item -Path 'TestDrive:\test.doc').Fullname
        }
        It 'Should return an object with the correct value for Size' {
            $ResponseObject.Size | Should -Be (Get-Item -Path 'TestDrive:\test.doc').Length
        }
        It 'Should return an object with the correct value for SourceFileLastModified' {
            $ResponseObject.SourceFileLastModified | Should -Be (Get-Item -Path 'TestDrive:\test.doc').LastWriteTimeUtc
        }
        It 'Should return an object with the correct value for FileName' {
            $ResponseObject.FileName | Should -Be 'test.doc'
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
    Context 'When an attachment is uploaded successfully without PassThru' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><string>rootns:ns:test.doc</string></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should not return anything' {
            New-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $TestItemPath -Force | Should -BeNullOrEmpty
        }
        It 'Should call Invoke-DokuApiCall once' {
            New-DokuAttachment -Fullname 'rootns:ns:test.doc' -Path $TestItemPath -Force -PassThru
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1 -Scope It
        }
    }
}