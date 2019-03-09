Describe 'ConvertTo-XmlRpcMethodCall' {
    Context 'Strict Mode' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            It 'Should work for methods with no params' {
                ConvertTo-XmlRpcMethodCall -Name 'wiki.getAllPages' | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getAllPages</methodName><params></params></methodCall>'
            }
            It 'Should work for methods with one (string) parameter' {
                ConvertTo-XmlRpcMethodCall -Name 'wiki.getPage' -Params @('hello') | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getPage</methodName><params><param><value><string>hello</string></value></param></params></methodCall>'
            }
            It 'Should work for methods with two parameters' {
                ConvertTo-XmlRpcMethodCall -Name 'wiki.getPageVersion' -Params @("pagename",@{'Key1' = 'Value1'}) | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getPageVersion</methodName><params><param><value><string>pagename</string></value></param><param><value><struct><member><name>Key1</name><value><string>Value1</string></value></member></struct></value></param></params></methodCall>'
            }
            It 'Should fail for empty methods' {
                { ConvertTo-XmlRpcMethodCall -Name '' -Params @("test") } | Should -Throw
            }
            It 'Should fail for null methods' {
                { ConvertTo-XmlRpcMethodCall -Name $null -Params @("test") } | Should -Throw
            }
        }
    }
}