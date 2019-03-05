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