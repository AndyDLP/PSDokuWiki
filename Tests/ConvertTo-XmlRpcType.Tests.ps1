Describe 'ConvertTo-XmlRpcType' {
    Context 'Strict Mode' {
        Set-StrictMode -Version latest 
        InModuleScope PSDokuWiki {
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
                ConvertTo-XmlRpcType -InputObject @('Hello World',1,@{'Key1' = 'Value1'}) | Should -be '<value><array><data><value><string>Hello World</string></value><value><i4>1</i4></value><value><struct><member><name>Key1</name><value><string>Value1</string></value></member></struct></value></data></array></value>'
            }
            It 'Should convert NULL' {
                ConvertTo-XmlRpcType -InputObject $null | Should -be ''
            }
        }
    }
}