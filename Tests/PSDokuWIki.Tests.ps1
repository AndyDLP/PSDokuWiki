$TopLevelFolder = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Parent
Import-Module (Join-Path -Path $TopLevelFolder -ChildPath 'PSDokuWiki\PSDokuWiki.psm1') -Force

Describe 'ConvertTo-XmlRpcType' {
    Context 'Strict Mode' {

        Set-StrictMode -Version latest

        It 'Should convert strings with single quotes' {
            ConvertTo-XmlRpcType -InputObject 'Hello' | Should -be '<value><string>Hello</string></value>'
        }
        It 'Should convert strings with double quotes' {
            ConvertTo-XmlRpcType -InputObject "Hello" | Should -be '<value><string>Hello</string></value>'
        }
        It 'Should convert strings with a length in a multiple of 4' {
            ConvertTo-XmlRpcType -InputObject "TestWord" | Should -be '<value><string>TestWord</string></value>'
        }
        It 'Should convert bytes into Base64' {
            $Bytes = [System.Text.Encoding]::UTF8.GetBytes("Hello World")
            ConvertTo-XmlRpcType -InputObject $Bytes | Should -be '<value><base64>SGVsbG8gV29ybGQ=</base64></value>'
        }
        It 'Should convert Booleans' {
            ConvertTo-XmlRpcType -InputObject $true | Should -be '<value><boolean>1</boolean></value>'
        }
        It 'Should convert Int32' {
            ConvertTo-XmlRpcType -InputObject 8 | Should -be '<value><i4>8</i4></value>'
        }
        It 'Should convert DateTime' {
            [datetime]$Date = '1/1/1980'
            ConvertTo-XmlRpcType -InputObject $Date | Should -be '<value><dateTime.iso8601>19800101T00:00:00</dateTime.iso8601></value>'
        }
        It 'Should convert array' {
            ConvertTo-XmlRpcType -InputObject @('Hello','World',123) | Should -be '<value><array><data><value><string>Hello</string></value><value><string>World</string></value><value><i4>123</i4></value></data></array></value>'
        }
        It 'Should convert hashtables' {
            ConvertTo-XmlRpcType -InputObject @{'ow' = 1} | Should -be '<value><struct><member><name>ow</name><value><i4>1</i4></value></member></struct></value>'
        }
        It 'Should convert XML' {
            $XML = [xml]'<?xml version="1.0" encoding="utf-8"?><Body><Hello>lol</Hello></Body>'
            ConvertTo-XmlRpcType -InputObject $XML | Should -be '<?xml version="1.0" encoding="utf-8"?><Body><Hello>lol</Hello></Body>'
        }
        It 'Should convert mixed data' {
            ConvertTo-XmlRpcType -InputObject @('Hello World',1,@{'Key1' = 'Value1'; 'Key2' = 2; 'Key3' = @(1,2,3)}) | Should -be '<value><array><data><value><string>Hello World</string></value><value><i4>1</i4></value><value><struct><member><name>Key3</name><value><array><data><value><i4>1</i4></value><value><i4>2</i4></value><value><i4>3</i4></value></data></array></value></member><member><name>Key1</name><value><string>Value1</string></value></member><member><name>Key2</name><value><i4>2</i4></value></member></struct></value></data></array></value>'
        }
        It 'Should convert NULL' {
            ConvertTo-XmlRpcType -InputObject $null | Should -be ''
        }
    }
}

Describe 'ConvertTo-XmlRpcMethodCall' {
    Context 'Strict Mode' {
        Set-StrictMode -Version latest
        It 'Should work for methods with no params' {
            ConvertTo-XmlRpcMethodCall -Name 'wiki.getAllPages' | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getAllPages</methodName><params></params></methodCall>'
        }
        It 'Should work for methods with one (string) parameter' {
            ConvertTo-XmlRpcMethodCall -Name 'wiki.getPage' -Params @('hello') | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getPage</methodName><params><param><value><string>hello</string></value></param></params></methodCall>'
        }
        It 'Should work for methods with two parameters' {
            ConvertTo-XmlRpcMethodCall -Name 'wiki.getPageVersion' -Params @("pagename",@{'Key1' = 'Value1'; 'Key2' = 2}) | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getPageVersion</methodName><params><param><value><string>pagename</string></value></param><param><value><struct><member><name>Key1</name><value><string>Value1</string></value></member><member><name>Key2</name><value><i4>2</i4></value></member></struct></value></param></params></methodCall>'
        }
        It 'Should fail for empty methods' {
            { ConvertTo-XmlRpcMethodCall -Name '' -Params @("test") } | Should -Throw
        }
        It 'Should fail for null methods' {
            { ConvertTo-XmlRpcMethodCall -Name $null -Params @("test") } | Should -Throw
        }
    }
}

Describe 'New-DokuSession' {
    Context 'Strict Mode' {
        $credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList ('username', (ConvertTo-SecureString 'password' -AsPlainText -Force))
        # This is bad :(
        $Server = 'www.dokuwiki.org/dokuwiki'
        Set-StrictMode -Version latest
        
        It 'Should fail when specifying a non-existent server' {
            {New-DokuSession -Server 'Server.fake.domain.name.111' -Unencrypted -SessionMethod 'Cookie' -Credential $credential} | Should -Throw
        }
        It 'Should fail when server is $null' {
            {New-DokuSession -Server $null -Unencrypted -SessionMethod 'Cookie' -Credential $credential} | Should -Throw
        }
        It 'Should fail when using a non-existent session method' {
            {New-DokuSession -Server $Server -Unencrypted -SessionMethod 'Hello World' -Credential $credential} | Should -Throw
        }
        It 'Should return an object with the correct primary type name' {
            Mock Invoke-WebRequest -ModuleName PSDokuWiki { return "nothing" }
            # TODO: 
            #  Do I need a class to do -BeOfType [DokuWiki.Session.Detail]
            (New-DokuSession -Server $Server -Credential $credential).PSTypeNames[0] | Should -Be 'DokuWiki.Session.Detail'
        }
        It 'Should return an object with all the correct properties' {
            Mock -ModuleName PSDokuWiki Invoke-WebRequest { return "nothing" }
            $SessionObjectProperties = (New-DokuSession -Server $Server -Credential $credential).PSObject.Properties.Name 
            @('Server','TargetUri','SessionMethod','Headers','WebSession','TimeStamp','UnencryptedEndpoint') | Where-Object -FilterScript { $SessionObjectProperties -notcontains $_ } | Should -BeNullOrEmpty
        }
    }
}

Describe 'Connect-DokuServer' {
    Context 'Strict Mode' {
        $credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList ('username', (ConvertTo-SecureString 'password' -AsPlainText -Force))
        # This is bad :(
        $Server = 'Server.fake.domain.name.111'
        Set-StrictMode -Version latest
        
        It 'Should fail when specifying a non-existent server' {
            {Connect-DokuServer -ComputerName $Server -Unencrypted -SessionMethod 'Cookie' -Credential $credential} | Should -Throw
        }
        It 'Should fail when server is $null' {
            {Connect-DokuServer -ComputerName $null -Unencrypted -SessionMethod 'Cookie' -Credential $credential} | Should -Throw
        }
        It 'Should fail when using a non-existent session method' {
            {Connect-DokuServer -ComputerName $Server -Unencrypted -SessionMethod 'Hello World' -Credential $credential} | Should -Throw
        }
        It 'Should return an object with the correct primary type name' {
            Mock -ModuleName PSDokuWiki Invoke-WebRequest { return ([PSCustomObject]@{
                Content = '<?xml version="1.0"?><methodResponse><string>Hello World</string></methodResponse>'
            }) }
            # TODO: 
            #  Do I need a class to do -BeOfType [DokuWiki.Session.Detail]
            Connect-DokuServer -Server $Server -Credential $credential
            (Get-DokuServer).PSTypeNames[0] | Should -Be 'DokuWiki.Session.Detail'
        }
        It 'Should return an object with all the correct properties' {
            Mock -ModuleName PSDokuWiki  Invoke-WebRequest { return ([PSCustomObject]@{
                Content = '<?xml version="1.0"?><methodResponse><string>Hello World</string></methodResponse>'
            }) }
            Connect-DokuServer -Server $Server -Credential $credential -Force
            $SessionObjectProperties = (Get-DokuServer).PSObject.Properties.Name 
            @('Server','TargetUri','SessionMethod','Headers','WebSession','TimeStamp','UnencryptedEndpoint') | Where-Object -FilterScript { $SessionObjectProperties -notcontains $_ } | Should -BeNullOrEmpty
        }
    }
}

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
        }
    }
}

Describe 'Disconnect-DokuServer' {
    Context 'Strict Mode' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{
                DummyKey = 'DummyValue'
            }
            It 'Should nullify the variable correctly' {
                Disconnect-DokuServer
                $Script:DokuServer | Should -BeNullOrEmpty
            }
            
            $Script:DokuServer = $null
            It 'Should do nothing if not connected' {
                { Disconnect-DokuServer } | Should -Not -Throw
            }
        }
    }
}

Describe 'Get-DokuServer' {
    Context 'Strict Mode' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{
                Headers = @{ "Content-Type" = "text/xml"; }
                TargetUri = 'http://wiki.example.com/lib/exe/xmlrpc.php'
                SessionMethod = 'Cookie'
                UnencryptedEndPoint = $true
                WebSession = (New-Object Microsoft.PowerShell.Commands.WebRequestSession)
            }
            It 'Should return the currently connected server' {
                Get-DokuServer | Should -Be $Script:DokuServer
            }
            It 'Should return true if currently connected and IsConnected is passed' {
                Get-DokuServer -IsConnected | Should -Be $true
            }
            
            $Script:DokuServer = $null
            It 'Should return nothing if not connected' {
                Get-DokuServer  | Should -BeNullOrEmpty
            }
            It 'Should return false if currently connected and IsConnected is passed' {
                Get-DokuServer -IsConnected | Should -Be $false
            }
        }
    }
}

