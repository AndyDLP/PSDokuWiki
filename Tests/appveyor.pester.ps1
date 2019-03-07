# Shamelessly stolen from https://github.com/RamblingCookieMonster/PSDiskPart/
# This script will invoke pester tests
# It should invoke on PowerShell v2 and later
# We serialize XML results and pull them in appveyor.yml

# If Finalize is specified, we collect XML output, upload tests, and indicate build errors
param([switch]$Finalize)

# Initialize some variables, move to the project root
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResultsPS$PSVersion.xml"
    $ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
    Set-Location $ProjectRoot

    Write-Host "Build version :`  $env:APPVEYOR_BUILD_VERSION"
    Write-Host "Branch        :`  $env:APPVEYOR_REPO_BRANCH"

# Run a test with the current version of PowerShell
if(-not $Finalize) {
    "`n`tSTATUS: Testing with PowerShell $PSVersion`n"

    Import-Module (Resolve-Path 'C:\Program Files\WindowsPowerShell\Modules\Pester\*\Pester.psd1')
    Import-Module (Join-Path -Path $ProjectRoot -ChildPath 'PSDokuWiki') -Force

    Invoke-Pester -Path "$ProjectRoot\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru | Export-Clixml -Path "$ProjectRoot\PesterResults$PSVersion.xml"
} else {
    # If finalize is specified, check for failures and 
    # Show status...
        $AllFiles = Get-ChildItem -Path $ProjectRoot\*Results*.xml | Select-Object -ExpandProperty FullName
        "`n`tSTATUS: Finalizing results`n"
        "COLLATING FILES:`n$($AllFiles | Out-String)"

    # Upload results for test page
        Get-ChildItem -Path "$ProjectRoot\TestResultsPS*.xml" | Foreach-Object -Process {
    
            $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
            $Source = $_.FullName

            "UPLOADING FILES: $Address $Source"

            (New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )
        }

    # What failed?
        $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Import-Clixml )
        
        $FailedCount = $Results | Select-Object -ExpandProperty FailedCount | Measure-Object -Sum | Select-Object -ExpandProperty Sum

        if ($FailedCount -gt 0) {

            $FailedItems = $Results | Select-Object -ExpandProperty TestResult | Where-Object -FilterScript {$_.Passed -notlike $True}

            "FAILED TESTS SUMMARY:`n"
            $FailedItems | ForEach-Object -Process {
                $Test = $_
                [pscustomobject]@{
                    Describe = $Test.Describe
                    Context = $Test.Context
                    Name = "It $($Test.Name)"
                    Result = $Test.Result
                }
            } | Sort-Object -Property Describe, Context, Name, Result | Format-List

            throw "$FailedCount tests failed."
        }

    # ScriptAnalyzer
    "`n`tSCRIPTANALYZER: CHECKING...`n"
    Add-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Running
    $CodeResults = Invoke-ScriptAnalyzer -Path $ProjectRoot\PSDokuWiki -Recurse -Severity Error -ErrorAction SilentlyContinue
    If ($CodeResults) {
        $ResultString = $CodeResults | Out-String
        Write-Warning $ResultString
        Add-AppveyorMessage -Message "PSScriptAnalyzer output contained one or more result(s) with 'Error' severity.`
        Check the 'Tests' tab of this build for more details." -Category Error
        Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Failed -ErrorMessage $ResultString
        
        # Failing the build
        Throw "Build failed"
    }
    Else {
        "`tNO ERRORS`n"
        Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Passed
    }

    
    "`n`tCODE COVERAGE:`n"
    Add-AppveyorTest -Name "PesterStatementCoverage" -Outcome Running
    Add-AppveyorTest -Name "PesterFunctionCoverage" -Outcome Running
    #region Show coverage
    # https://dille.name/blog/2017/06/29/code-coverage-metrics-using-pester-for-powershell-modules/
    $TestResults = Invoke-Pester -Path ".\Tests" -CodeCoverage ".\PSDokuWiki\*\*.ps1" -PassThru -Show None

    $CodeCoverage = @{
        Functions = @{}
        Statement = @{
            Analyzed = $TestResults.CodeCoverage.NumberOfCommandsAnalyzed
            Executed = $TestResults.CodeCoverage.NumberOfCommandsExecuted
            Missed   = $TestResults.CodeCoverage.NumberOfCommandsMissed
            Coverage = 0
        }
        Function = @{}
    }
    $CodeCoverage.Statement.Coverage = [math]::Round($CodeCoverage.Statement.Executed / $CodeCoverage.Statement.Analyzed * 100, 2)

    $TestResults.CodeCoverage.HitCommands | Group-Object -Property Function | ForEach-Object {
        if (-Not $CodeCoverage.Functions.ContainsKey($_.Name)) {
            $CodeCoverage.Functions.Add($_.Name, @{
                Name     = $_.Name
                Analyzed = 0
                Executed = 0
                Missed   = 0
                Coverage = 0
            })
        }

        $CodeCoverage.Functions[$_.Name].Analyzed += $_.Count
        $CodeCoverage.Functions[$_.Name].Executed += $_.Count
    }
    $TestResults.CodeCoverage.MissedCommands | Group-Object -Property Function | ForEach-Object {
        if (-Not $CodeCoverage.Functions.ContainsKey($_.Name)) {
            $CodeCoverage.Functions.Add($_.Name, @{
                Name     = $_.Name
                Analyzed = 0
                Executed = 0
                Missed   = 0
                Coverage = 0
            })
        }

        $CodeCoverage.Functions[$_.Name].Analyzed += $_.Count
        $CodeCoverage.Functions[$_.Name].Missed   += $_.Count
    }
    foreach ($function in $CodeCoverage.Functions.Values) {
        $function.Coverage = [math]::Round($function.Executed / $function.Analyzed * 100)
    }
    $CodeCoverage.Function = @{
        Analyzed = $CodeCoverage.Functions.Count
        Executed = ($CodeCoverage.Functions.Values | Where-Object { $_.Executed -gt 0 }).Length
        Missed   = ($CodeCoverage.Functions.Values | Where-Object { $_.Executed -eq 0 }).Length
    }
    $CodeCoverage.Function.Coverage = [math]::Round($CodeCoverage.Function.Executed / $CodeCoverage.Function.Analyzed * 100, 2)
    
    #endregion
    $StatementThreshold = 80
    $FunctionThreshold = 100
    
    "`n`tStatement coverage: $($CodeCoverage.Statement.Analyzed) analyzed, $($CodeCoverage.Statement.Executed) executed, $($CodeCoverage.Statement.Missed) missed, $($CodeCoverage.Statement.Coverage)%."
    if ($CodeCoverage.Statement.Coverage -gt $StatementThreshold) {
        # passed Statement coverage test
        "`tPassed statement coverage threshold of: $StatementThreshold%`n"
        Update-AppveyorTest -Name "PesterStatementCoverage" -Outcome Passed
    } else {
        # failed Statement coverage test
        Add-AppveyorMessage -Message "`tFailed function coverage threshold of: $StatementThreshold%`n" -Category Error
        Update-AppveyorTest -Name "PesterStatementCoverage" -Outcome Failed -ErrorMessage "Pester statement coverage did not meet threshold of $StatementThreshold%"
    }
    "`tFunction coverage: $($CodeCoverage.Function.Analyzed) analyzed, $($CodeCoverage.Function.Executed) executed, $($CodeCoverage.Function.Missed) missed, $($CodeCoverage.Function.Coverage)%."
    if ($CodeCoverage.Function.Coverage -gt $FunctionThreshold) {
        # passed Function coverage test
        "`tPassed function coverage threshold of: $FunctionThreshold%`n"
        Update-AppveyorTest -Name "PesterFunctionCoverage" -Outcome Passed

    } else {
        # failed Function coverage test
        Add-AppveyorMessage -Message "`tFailed function coverage threshold of: $FunctionThreshold%`n" -Category Error
        Update-AppveyorTest -Name "PesterFunctionCoverage" -Outcome Failed -ErrorMessage "Pester statement coverage did not meet threshold of $FunctionThreshold%"
    }
}