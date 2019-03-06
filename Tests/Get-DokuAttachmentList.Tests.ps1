Describe 'Get-DokuAttachmentList' {
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
            Get-DokuAttachmentList -Namespace 'rootns:ns' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Get-DokuAttachmentList -Namespace 'rootns:ns' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When an attachment is returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><value><struct><member><name>FullName</name><value><string>rootns:ns:attachment.txt</string></value></member><member><name>Name</name><value><string>attachment.txt</string></value></member><member><name>Size</name><value><int>2048</int></value></member><member><name>VersionTimestamp</name><value><int>11112019</int></value></member><member><name>IsWritable</name><value><int>1</int></value></member><member><name>IsImage</name><value><int>1</int></value></member><member><name>Acl</name><value><int>255</int></value></member><member><name>LastModified</name><value><string>11-11-2019</string></value></member></struct></value></methodResponse>'
                }
            )
        }
        $ResponseObject = Get-DokuAttachmentList -Namespace 'rootns:ns'

        It 'Should return an object with all properties defined' {
            @('FullName','Name','Size','LastModified','RootNamespace','ParentNamespace','VersionTimestamp','IsWritable','IsImage','Acl') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:attachment.txt'
        }
        It 'Should return an object with the correct value for Name' {
            $ResponseObject.Name | Should -Be 'attachment.txt'
        }
        It 'Should return an object with the correct value for Size' {
            $ResponseObject.Size | Should -Be 2048
        }
        It 'Should return an object with the correct value for IsWritable' {
            $ResponseObject.IsWritable | Should -Be $true
        }
        It 'Should return an object with the correct value for IsImage' {
            $ResponseObject.IsImage | Should -Be $true
        }
        It 'Should return an object with the correct value for LastModified' {
            $ResponseObject.LastModified | Should -Be (Get-Date '11-11-2019')
        }
        It 'Should return an object with the correct value for VersionTimestamp' {
            $ResponseObject.VersionTimestamp | Should -Be 11112019
        }
        It 'Should return an object with the correct value for ParentNamespace' {
            $ResponseObject.ParentNamespace | Should -Be 'ns'
        }
        It 'Should return an object with the correct value for RootNamespace' {
            $ResponseObject.RootNamespace | Should -Be 'rootns'
        }
    }
    Context 'When two attachments are returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><value><array><data><value><struct><member><name>FullName</name><value><string>rootns:ns:attachment.txt</string></value></member><member><name>Name</name><value><string>attachment.txt</string></value></member><member><name>Size</name><value><int>2048</int></value></member><member><name>VersionTimestamp</name><value><int>11112019</int></value></member><member><name>IsWritable</name><value><int>1</int></value></member><member><name>IsImage</name><value><int>1</int></value></member><member><name>Acl</name><value><int>255</int></value></member><member><name>LastModified</name><value><string>11-11-2019</string></value></member></struct></value><value><struct><member><name>FullName</name><value><string>rootns:ns:attachment.txt</string></value></member><member><name>Name</name><value><string>attachment.txt</string></value></member><member><name>Size</name><value><int>2048</int></value></member><member><name>VersionTimestamp</name><value><int>11112019</int></value></member><member><name>IsWritable</name><value><int>1</int></value></member><member><name>IsImage</name><value><int>1</int></value></member><member><name>Acl</name><value><int>255</int></value></member><member><name>LastModified</name><value><string>11-11-2019</string></value></member></struct></value></data></array></value></methodResponse>'
                }
            )
        }
        $ResponseObject = (Get-DokuAttachmentList -Namespace 'rootns:ns')[1]

        It 'Should return objects with all properties defined' {
            @('FullName','Name','Size','LastModified','RootNamespace','ParentNamespace','VersionTimestamp','IsWritable','IsImage','Acl') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:attachment.txt'
        }
        It 'Should return an object with the correct value for Name' {
            $ResponseObject.Name | Should -Be 'attachment.txt'
        }
        It 'Should return an object with the correct value for Size' {
            $ResponseObject.Size | Should -Be 2048
        }
        It 'Should return an object with the correct value for IsWritable' {
            $ResponseObject.IsWritable | Should -Be $true
        }
        It 'Should return an object with the correct value for IsImage' {
            $ResponseObject.IsImage | Should -Be $true
        }
        It 'Should return an object with the correct value for LastModified' {
            $ResponseObject.LastModified | Should -Be (Get-Date '11-11-2019')
        }
        It 'Should return an object with the correct value for VersionTimestamp' {
            $ResponseObject.VersionTimestamp | Should -Be 11112019
        }
        It 'Should return an object with the correct value for ParentNamespace' {
            $ResponseObject.ParentNamespace | Should -Be 'ns'
        }
        It 'Should return an object with the correct value for RootNamespace' {
            $ResponseObject.RootNamespace | Should -Be 'rootns'
        }
    }
}





