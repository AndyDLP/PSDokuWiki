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