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