$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "ConvertTo-XmlRpcType" {
    function ConvertTo-XmlRpcType {  }
    
    Mock ConvertTo-XmlRpcType { return "" }
    It "Works for methods with no params" {
        ConvertTo-XmlRpcMethodCall -Name "wiki.getAllPages" | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getAllPages</methodName><params></params></methodCall>'
    }
}