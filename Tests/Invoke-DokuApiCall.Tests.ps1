Describe 'Invoke-DokuApiCall' {
    Context 'Strict Mode' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            $Script:DokuServer = $null 
            It "Should fail when DokuServer is NULL" {
                (Invoke-DokuApiCall -MethodName 'wiki.getAllPages').ExceptionMessage | Should -Be "The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
            }
            It "Should produce an object with the correct properties when DokuServer is NULL" {
                $ResponseObject = (Invoke-DokuApiCall -MethodName 'wiki.getAllPages').PSObject.Properties.Name
                @('Method','CompletedSuccessfully','TargetUri','SessionMethod','MethodParameters','XMLPayloadSent','ExceptionMessage') | Where-Object -FilterScript { $ResponseObject -notcontains $_ } | Should -BeNullOrEmpty
            }

            $Script:DokuServer = [PSCustomObject]@{
                Headers = @{ "Content-Type" = "text/xml"; }
                TargetUri = 'not a real target'
                SessionMethod = 'Cookie'
                UnencryptedEndPoint = $true
                WebSession = (New-Object Microsoft.PowerShell.Commands.WebRequestSession)
            }
            It "Should fail when target uri is unreachable" {
                (Invoke-DokuApiCall -MethodName 'wiki.getAllPages').ExceptionMessage | Should -Be 'Invalid URI: The hostname could not be parsed.'
            }
            It "Should produce an object with the correct properties when target uri is unreachable" {
                $ResponseObject = (Invoke-DokuApiCall -MethodName 'wiki.getAllPages').PSObject.Properties.Name
                @('Method','TargetUri','SessionMethod','MethodParameters','XMLPayloadSent','ExceptionMessage') | Where-Object -FilterScript { $ResponseObject -notcontains $_ } | Should -BeNullOrEmpty
            }
            
            $Script:DokuServer.TargetUri = 'www.google.com'
            It "Should fail when target uri is reachable but invalid" {
                (Invoke-DokuApiCall -MethodName 'wiki.getAllPages').CompletedSuccessfully | Should -Be $false
            }
            It "Should produce an object with the correct properties when target uri is reachable but invalid" {
                $ResponseObject = (Invoke-DokuApiCall -MethodName 'wiki.getAllPages').PSObject.Properties.Name
                @('Method','TargetUri','SessionMethod','MethodParameters','XMLPayloadSent','ExceptionMessage') | Where-Object -FilterScript { $ResponseObject -notcontains $_ } | Should -BeNullOrEmpty
            }

            It 'Should correctly identify the fault code' {
                Mock  Invoke-WebRequest { 
                    return ([PSCustomObject]@{
                        Content = '<?xml version="1.0"?><methodResponse><fault><value><struct><member><name>faultCode</name><value><int>1234</int></value></member><member><name>faultString</name><value><string>Test Fault</string></value></member></struct></value></fault></methodResponse>'
                    })
                }
                (Invoke-DokuApiCall -MethodName 'wiki.getAllPages').faultCode | Should -Be 1234
            }
            It 'Should correctly identify the fault string' {
                Mock  Invoke-WebRequest { 
                    return ([PSCustomObject]@{
                        Content = '<?xml version="1.0"?><methodResponse><fault><value><struct><member><name>faultCode</name><value><int>1234</int></value></member><member><name>faultString</name><value><string>Test Fault</string></value></member></struct></value></fault></methodResponse>'
                    })
                }
                (Invoke-DokuApiCall -MethodName 'wiki.getAllPages').faultString | Should -Be 'Test Fault'
            }
        }
    }
}