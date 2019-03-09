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