$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force

Describe "Help tests for $moduleName" -Tags PostBuild {

    $functions = Get-Command -Module $moduleName
    $help = $functions | %{Get-Help $_.name}
    foreach($node in $help)
    {
        Context $node.name {

            it "has a description" {
                $node.description | Should Not BeNullOrEmpty
            }
            it "has an example" {
                 $node.examples | Should Not BeNullOrEmpty
            }
            foreach($parameter in $node.parameters.parameter)
            {
                if($parameter -notmatch 'whatif|confirm')
                {
                    it "parameter $($parameter.name) has a description" {
                        $parameter.Description.text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}

Describe "General project validation: $moduleName" -Tags PostBuild {
    Context "Module: $ModuleName" {
        It "Module can import cleanly" {
            {Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force } | Should Not Throw
        }
        It "Module name is correct" {
            (Get-Module -Name $moduleName).Name | Should -Be 'PSDokuWiki'
        }
        It "Module Description is correct" {
            (Get-Module -Name $moduleName).Description | Should -Be 'Consume the XMLRPC API of a DokuWiki instance via PowerShell'
        }
        It "Module Guid is correct" {
            (Get-Module -Name $moduleName).Guid | Should -Be '8e86c290-3848-47a6-93ec-ad472b06dcc2'
        }
        It "Module ProjectUri is correct" {
            (Get-Module -Name $moduleName).ProjectUri | Should -Be 'https://github.com/AndyDLP/PSDokuWiki'
        }
        It "Module LicenseUri is correct" {
            (Get-Module -Name $moduleName).LicenseUri | Should -Be 'https://github.com/AndyDLP/PSDokuWiki/blob/master/LICENSE'
        }
    }
}