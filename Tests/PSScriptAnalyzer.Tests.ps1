$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf


Describe "PSScriptAnalyzer rule-sets" {

    $Rules   = Get-ScriptAnalyzerRule
    $scripts = Get-ChildItem $moduleRoot -Include *.ps1,*.psm1,*.psd1 -Recurse | where fullname -notmatch 'classes'

    foreach ( $Script in $scripts ) {
        Context "Script '$($script.FullName)'" {

            foreach ( $rule in $rules ) {
                # ignore one buggy rule
                if (($rule.rulename -eq 'PSReviewUnusedParameter') -and ($script.FullName -match 'XmlRpcMethodCall')) {} else {
                    It "Rule [$rule]" {
                        (Invoke-ScriptAnalyzer -Path $script.FullName -IncludeRule $rule.RuleName -Severity ParseError,ParseError,Warning).Count | Should Be 0
                    }
                }
            }
        }
    }
}

