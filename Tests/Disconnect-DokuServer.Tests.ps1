Describe 'Disconnect-DokuServer' {
    Set-StrictMode -Version latest
    Context 'When connected' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{
                DummyKey = 'DummyValue'
            }
            It 'Should nullify the variable correctly' {
                Disconnect-DokuServer
                $Script:DokuServer | Should -BeNullOrEmpty
            }
        }
    }
    Context 'When not connected' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = $null
            It 'Should do nothing if not connected' {
                { Disconnect-DokuServer } | Should -Not -Throw
            }
        }
    }
}