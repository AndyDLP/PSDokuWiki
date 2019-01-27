$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "ConvertTo-XmlRpcType" {
    It "Converts string(s)" {
        ConvertTo-XmlRpcType -InputObject "Hello" | Should -be "<value><string>Hello</string></value>"
    }
    It "Converts Booleans" {
        ConvertTo-XmlRpcType -InputObject $true | Should -be "<value><boolean>1</boolean></value>"
    }
    It "Converts Base64 Encoded data" {
        ConvertTo-XmlRpcType -InputObject "SGVsbG8gV29ybGQ=" | Should -be "<value><base64>SGVsbG8gV29ybGQ=</base64></value>"
    }
    It "Converts Int32" {
        ConvertTo-XmlRpcType -InputObject 8 | Should -be "<value><i4>8</i4></value>"
    }
    It "Converts DateTime" {
        [datetime]$Date = "1/1/1980"
        ConvertTo-XmlRpcType -InputObject $Date | Should -be "<value><dateTime.iso8601>19800101T00:00:00</dateTime.iso8601></value>"
    }
    It "Converts array" {
        ConvertTo-XmlRpcType -InputObject @("Hello","World",123) | Should -be "<value><array><data><value><string>Hello</string></value><value><string>World</string></value><value><i4>123</i4></value></data></array></value>"
    }
    It "Converts hashtables" {
        ConvertTo-XmlRpcType -InputObject @{'ow' = 1} | Should -be "<value><struct><member><name>ow</name><value><i4>1</i4></value></member></struct></value>"
    }   
    It "Converts XML" {
        # How to create a valid xml object without ConvertTo-Xml ???
        ConvertTo-XmlRpcType -InputObject (ConvertTo-Xml -InputObject @("lol",1,"hello")) | Should -be '<?xml version="1.0" encoding="utf-8"?><Objects><Object Type="System.Object[]"><Property Type="System.String">lol</Property><Property Type="System.Int32">1</Property><Property Type="System.String">hello</Property></Object></Objects>'
    }
    It "Converts mixed data" {
        ConvertTo-XmlRpcType -InputObject @("Hello World",1,@{'Key1' = "Value1"; 'Key2' = 2; 'Key3' = @(1,2,3)}) | Should -be "<value><array><data><value><string>Hello World</string></value><value><i4>1</i4></value><value><struct><member><name>Key3</name><value><array><data><value><i4>1</i4></value><value><i4>2</i4></value><value><i4>3</i4></value></data></array></value></member><member><name>Key1</name><value><string>Value1</string></value></member><member><name>Key2</name><value><i4>2</i4></value></member></struct></value></data></array></value>"
    }
    It "Converts NULL" {
        ConvertTo-XmlRpcType -InputObject $null | Should -be ""
    }
}