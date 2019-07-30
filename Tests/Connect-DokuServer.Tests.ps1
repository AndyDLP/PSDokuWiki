Describe 'Connect-DokuServer' {
    Context 'Strict Mode' {
        $credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList ('username', (ConvertTo-SecureString 'password' -AsPlainText -Force))
        # This is bad :(
        $Server = 'Server.fake.domain.name.111'
        Set-StrictMode -Version latest
        
        It 'Should fail when specifying a non-existent server' {
            {Connect-DokuServer -ComputerName $Server -Unencrypted -Credential $credential} | Should -Throw
        }
        It 'Should fail when server is $null' {
            {Connect-DokuServer -ComputerName $null -Unencrypted -Credential $credential} | Should -Throw
        }
        It 'Should return an object with the correct primary type name' {
            Mock -ModuleName PSDokuWiki Invoke-WebRequest { return ([PSCustomObject]@{
                Content = '<?xml version="1.0"?><methodResponse><string>Hello World</string></methodResponse>'
            }) }
            Connect-DokuServer -Server $Server -Credential $credential -Unencrypted -APIPath 'dokuwiki/lib/exe/xmlrpc.php' -Force
            InModuleScope PSDokuWiki {
                $Script:DokuServer.PSTypeNames[0] | Should -Be 'DokuWiki.Session.Detail'
            }
        }
        It 'Should return an object with all the correct properties' {
            Mock -ModuleName PSDokuWiki  Invoke-WebRequest { return ([PSCustomObject]@{
                Content = '<?xml version="1.0"?><methodResponse><string>Hello World</string></methodResponse>'
            }) }
            Connect-DokuServer -Server $Server -Credential $credential -Force
            $SessionObjectProperties = (Get-DokuServer).PSObject.Properties.Name 
            @('Server','TargetUri','Headers','WebSession','TimeStamp','UnencryptedEndpoint','UseBasicParsing') | Where-Object -FilterScript { $SessionObjectProperties -notcontains $_ } | Should -BeNullOrEmpty
        }
        It 'Should detect if a non-XML response was received' {
            Mock -ModuleName PSDokuWiki Invoke-WebRequest { return ([PSCustomObject]@{
                Content = '<!doctype html>
                <html>
                <head>
                    <title>Example Domain</title>
                
                    <meta charset="utf-8" />
                    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1" />
                </head>
                
                <body>
                <div>
                    <h1>Example Domain</h1>
                    <p>This domain is established to be used for illustrative examples in documents. You may use this
                    domain in examples without prior coordination or asking for permission.</p>
                    <p><a href="http://www.iana.org/domains/example">More information...</a></p>
                </div>
                </body>
                </html>'
            }) }
            try {
                Connect-DokuServer -Server $Server -Credential $credential -Unencrypted -APIPath 'dokuwiki/lib/exe/xmlrpc.php' -Force -ErrorVariable DokuErrorVariable -ErrorAction Stop
            } 
            catch {
                $_ | Should -Be 'XML payload sent to: http://Server.fake.domain.name.111dokuwiki/lib/exe/xmlrpc.php but received an invalid response'
            }
        }
        It 'Should detect a fault in the login' {
            Mock -ModuleName PSDokuWiki Invoke-WebRequest { return ([PSCustomObject]@{
                Content = '<?xml version="1.0"?><methodResponse><fault><value><struct><member><name>faultCode</name><value><int>1234</int></value></member><member><name>faultString</name><value><string>Fault Message</string></value></member></struct></value></fault></methodResponse>'
            }) }
            try {
                Connect-DokuServer -Server $Server -Credential $credential -Unencrypted -APIPath 'dokuwiki/lib/exe/xmlrpc.php' -Force -ErrorAction Stop
            }
            catch {
                $_ | Should -Be 'Connected to API endpoint: Server.fake.domain.name.111, but failed login. FaultCode: 1234 - FaultString: Fault Message'
            }
        }
        It 'Should detect an invalid XML response' {
            Mock -ModuleName PSDokuWiki Invoke-WebRequest { return ([PSCustomObject]@{
                Content = '<?xml version="1.0"?><value><struct><member><name>faultCode</name><value><int>1234</int></value></member><member><name>faultString</name><value><string>Fault Message</string></value></member></struct></value>'
            }) }
            try {
                Connect-DokuServer -Server $Server -Credential $credential -Unencrypted -APIPath 'dokuwiki/lib/exe/xmlrpc.php' -Force -ErrorAction Stop
            }
            catch {
                $_ | Should -Be 'XML payload sent to: http://Server.fake.domain.name.111dokuwiki/lib/exe/xmlrpc.php but received an invalid response'
            }
        }
    }
}
