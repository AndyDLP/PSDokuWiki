$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "ConvertTo-XmlRpcType" {
    function ConvertTo-XmlRpcType { param ($name) }
    
    Mock ConvertTo-XmlRpcType { return "" }
    It "Works with no method params" {
        ConvertTo-XmlRpcMethodCall -Name "wiki.getAllPages" | Should -be '<?xml version="1.0"?><methodCall><methodName>wiki.getAllPages</methodName><params></params></methodCall>'
    }
}