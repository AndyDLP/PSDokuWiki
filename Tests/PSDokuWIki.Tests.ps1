$TopLevelFolder = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Parent
Import-Module (Join-Path -Path $TopLevelFolder -ChildPath 'PSDokuWiki\PSDokuWiki.psm1') -Force

Describe 'ConvertTo-XmlRpcType' {
    Context 'Strict Mode' {

        Set-StrictMode -Version latest

        It 'Successfully converts strings with single quotes' {
            ConvertTo-XmlRpcType -InputObject 'Hello' | Should -be '<value><string>Hello</string></value>'
        }
        It 'Successfully converts strings with double quotes' {
            ConvertTo-XmlRpcType -InputObject "Hello" | Should -be '<value><string>Hello</string></value>'
        }
        It 'Successfully converts strings with a length in a multiple of 4' {
            ConvertTo-XmlRpcType -InputObject "TestWord" | Should -be '<value><string>TestWord</string></value>'
        }
        It 'Successfully converts bytes into Base64' {
            $Bytes = [System.Text.Encoding]::UTF8.GetBytes("Hello World")
            ConvertTo-XmlRpcType -InputObject $Bytes | Should -be '<value><base64>SGVsbG8gV29ybGQ=</base64></value>'
        }
        It 'Successfully converts Booleans' {
            ConvertTo-XmlRpcType -InputObject $true | Should -be '<value><boolean>1</boolean></value>'
        }
        It 'Successfully converts Int32' {
            ConvertTo-XmlRpcType -InputObject 8 | Should -be '<value><i4>8</i4></value>'
        }
        It 'Successfully converts DateTime' {
            [datetime]$Date = '1/1/1980'
            ConvertTo-XmlRpcType -InputObject $Date | Should -be '<value><dateTime.iso8601>19800101T00:00:00</dateTime.iso8601></value>'
        }
        It 'Successfully converts array' {
            ConvertTo-XmlRpcType -InputObject @('Hello','World',123) | Should -be '<value><array><data><value><string>Hello</string></value><value><string>World</string></value><value><i4>123</i4></value></data></array></value>'
        }
        It 'Successfully converts hashtables' {
            ConvertTo-XmlRpcType -InputObject @{'ow' = 1} | Should -be '<value><struct><member><name>ow</name><value><i4>1</i4></value></member></struct></value>'
        }
        It 'Successfully converts XML' {
            $XML = [xml]'<?xml version="1.0" encoding="utf-8"?><Body><Hello>lol</Hello></Body>'
            ConvertTo-XmlRpcType -InputObject $XML | Should -be '<?xml version="1.0" encoding="utf-8"?><Body><Hello>lol</Hello></Body>'
        }
        It 'Successfully converts mixed data' {
            ConvertTo-XmlRpcType -InputObject @('Hello World',1,@{'Key1' = 'Value1'; 'Key2' = 2; 'Key3' = @(1,2,3)}) | Should -be '<value><array><data><value><string>Hello World</string></value><value><i4>1</i4></value><value><struct><member><name>Key3</name><value><array><data><value><i4>1</i4></value><value><i4>2</i4></value><value><i4>3</i4></value></data></array></value></member><member><name>Key1</name><value><string>Value1</string></value></member><member><name>Key2</name><value><i4>2</i4></value></member></struct></value></data></array></value>'
        }
        It 'Successfully converts NULL' {
            ConvertTo-XmlRpcType -InputObject $null | Should -be ''
        }
    }
}

Describe 'ConvertTo-XmlRpcMethodCall' {
    Context 'Strict Mode' {
        Set-StrictMode -Version latest
        It 'Succeeds for methods with no params' {
            ConvertTo-XmlRpcMethodCall -Name 'wiki.getAllPages' | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getAllPages</methodName><params></params></methodCall>'
        }
        It 'Succeeds for methods with one (string) parameter' {
            ConvertTo-XmlRpcMethodCall -Name 'wiki.getPage' -Params @('hello') | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getPage</methodName><params><param><value><string>hello</string></value></param></params></methodCall>'
        }
        It 'Succeeds for methods with two parameters' {
            ConvertTo-XmlRpcMethodCall -Name 'wiki.getPageVersion' -Params @("pagename",@{'Key1' = 'Value1'; 'Key2' = 2}) | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getPageVersion</methodName><params><param><value><string>pagename</string></value></param><param><value><struct><member><name>Key1</name><value><string>Value1</string></value></member><member><name>Key2</name><value><i4>2</i4></value></member></struct></value></param></params></methodCall>'
        }
        It 'Fails for empty methods' {
            { ConvertTo-XmlRpcMethodCall -Name '' -Params @("test") } | Should -Throw
        }
        It 'Fails for null methods' {
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
        
        It 'Fails when specifying a non-existent server' {
            {New-DokuSession -Server 'Server.fake.domain.name.111' -Unencrypted -SessionMethod 'Cookie' -Credential $credential} | Should -Throw
        }
        It 'Fails when server is $null' {
            {New-DokuSession -Server $null -Unencrypted -SessionMethod 'Cookie' -Credential $credential} | Should -Throw
        }
        It 'Fails when using a non-existent session method' {
            {New-DokuSession -Server $Server -Unencrypted -SessionMethod 'Hello World' -Credential $credential} | Should -Throw
        }
        It 'Successfully returns an object with the correct primary type name' {
            Mock Invoke-WebRequest -ModuleName PSDokuWiki { return "nothing" }
            # TODO: 
            #  Do I need a class to do -BeOfType [DokuWiki.Session.Detail]
            (New-DokuSession -Server $Server -Credential $credential).PSTypeNames[0] | Should -Be 'DokuWiki.Session.Detail'
        }
        It 'Successfully returns an object with all the correct properties' {
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
        
        It 'Fails when specifying a non-existent server' {
            {Connect-DokuServer -ComputerName $Server -Unencrypted -SessionMethod 'Cookie' -Credential $credential} | Should -Throw
        }
        It 'Fails when server is $null' {
            {Connect-DokuServer -ComputerName $null -Unencrypted -SessionMethod 'Cookie' -Credential $credential} | Should -Throw
        }
        It 'Fails when using a non-existent session method' {
            {Connect-DokuServer -ComputerName $Server -Unencrypted -SessionMethod 'Hello World' -Credential $credential} | Should -Throw
        }
        It 'Successfully returns an object with the correct primary type name' {
            Mock -ModuleName PSDokuWiki Invoke-WebRequest { return "nothing" }
            # TODO: 
            #  Do I need a class to do -BeOfType [DokuWiki.Session.Detail]
            Connect-DokuServer -Server $Server -Credential $credential
            (Get-DokuServer).PSTypeNames[0] | Should -Be 'DokuWiki.Session.Detail'
        }
        It 'Successfully returns an object with all the correct properties' {
            Mock -ModuleName PSDokuWiki  Invoke-WebRequest { return "nothing" }
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
            Add-Type -AssemblyName System.Web
            $Script:DokuServer = [PSCustomObject]@{
                Headers = @{ "Content-Type" = "text/xml"; }
                TargetUri = 'http://www.dokuwiki.org/dokuwiki/lib/exe/xmlrpc.php'
                SessionMethod = 'Cookie'
                UnencryptedEndPoint = $true
                WebSession = (New-Object Microsoft.PowerShell.Commands.WebRequestSession)
            }

            Invoke-DokuApiCall -MethodName 'wiki.getAllPages' | Should -be 1
        }
    }
}

# Add-Type -AssemblyName System.Web
# New-Object Microsoft.PowerShell.Commands.WebRequestSession