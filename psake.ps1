# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) {
        $ProjectRoot = $PSScriptRoot
    }

    $Timestamp = Get-Date -UFormat '%Y%m%d-%H%M%S'
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if ($ENV:BHCommitMessage -match '!verbose') {
        $Verbose = @{Verbose = $True }
    }
}

Task Default -depends 'Deploy'

Task Init {
    $lines
    Set-Location $ProjectRoot
    'Build System Details:'
    Get-Item ENV:BH*

    "`n"
}

Task Analyze -depends Init {
    $lines
    # ScriptAnalyzer
    "`nSCRIPTANALYZER: CHECKING..."

    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
        Add-AppveyorTest -name 'PsScriptAnalyzer' -Outcome 'Running'
    }

    $CodeResults = Invoke-ScriptAnalyzer -Path "$ProjectRoot\PSDokuWiki" -Recurse -Severity 'Error' -ErrorAction SilentlyContinue @Verbose
    If ($CodeResults) {
        $ResultString = $CodeResults | Out-String
        Write-Warning $ResultString

        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Add-AppveyorMessage -Message "PSScriptAnalyzer output contained one or more result(s) with 'Error' severity. Check the 'Tests' tab of this build for more details." -Category Error
            Update-AppveyorTest -name 'PsScriptAnalyzer' -Outcome 'Failed' -ErrorMessage $ResultString
        }

        # Failing the build
        Throw 'Build failed - PSScriptAnalyzer'
    } else {
        "`tNO ERRORS`n"
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Update-AppveyorTest -name 'PsScriptAnalyzer' -Outcome 'Passed'
        }
    }
    "`n"
}

Task Test -depends Analyze {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    Import-Module (Join-Path -Path $ProjectRoot -ChildPath 'PSDokuWiki') -Force @Verbose

    # Gather test results. Store them in a variable and file
    $Script:TestResults = Invoke-Pester -Path "$ProjectRoot\Tests" -OutputFormat 'NUnitXml' -OutputFile "$ProjectRoot\$TestFile" -PassThru -CodeCoverage "$ProjectRoot\PSDokuWiki\*\*.ps1" @Verbose -ExcludeTag PostBuild
    $Script:TestResults | Export-Clixml -Path "$ProjectRoot\PesterResults$PSVersion.xml"

    $AllFiles = Get-ChildItem -Path "$ProjectRoot\*Results*.xml" | Select-Object -ExpandProperty 'FullName'
    "COLLATING FILES:`n$($AllFiles | Out-String)"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        Get-ChildItem -Path "$ProjectRoot\TestResults_PS*.xml" | ForEach-Object -Process {
            $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
            $Source = $_.FullName
            "UPLOADING FILES: $Address $Source"
            (New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )
        }
    }

    $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Import-Clixml )
    $FailedCount = $Results | Select-Object -ExpandProperty 'FailedCount' | Measure-Object -Sum | Select-Object -ExpandProperty 'Sum'

    if ($FailedCount -gt 0) {

        $FailedItems = $Results | Select-Object -ExpandProperty 'TestResult' | Where-Object -FilterScript { $_.Passed -notlike $True }
        "FAILED TESTS SUMMARY:`n"

        $FailedItems | ForEach-Object -Process {
            $Test = $_
            [pscustomobject]@{
                Describe = $Test.Describe
                Context  = $Test.Context
                Name     = "It $($Test.Name)"
                Result   = $Test.Result
            }
        } | Sort-Object -Property 'Describe', 'Context', 'Name', 'Result' | Format-List
        throw "$FailedCount tests failed."
    }

    Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Remove-Item -Force -ErrorAction 'SilentlyContinue'
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction 'SilentlyContinue'
}

Task Coverage -depends Test {
    # CODE COVERAGE

    "`nCODE COVERAGE:"
    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
        Add-AppveyorTest -name 'PesterStatementCoverage' -Outcome 'Running'
        Add-AppveyorTest -name 'PesterFunctionCoverage' -Outcome 'Running'
    }
    $CodeCoverage = @{
        Functions = @{}
        Statement = @{
            Analyzed = $Script:TestResults.CodeCoverage.NumberOfCommandsAnalyzed
            Executed = $Script:TestResults.CodeCoverage.NumberOfCommandsExecuted
            Missed   = $Script:TestResults.CodeCoverage.NumberOfCommandsMissed
            Coverage = 0
        }
        Function  = @{}
    }
    $CodeCoverage.Statement.Coverage = [math]::Round($CodeCoverage.Statement.Executed / $CodeCoverage.Statement.Analyzed * 100, 2)

    $Script:TestResults.CodeCoverage.HitCommands | Group-Object -Property Function | ForEach-Object {
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
    $Script:TestResults.CodeCoverage.MissedCommands | Group-Object -Property Function | ForEach-Object {
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
        $CodeCoverage.Functions[$_.Name].Missed += $_.Count
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


    # Define thresholds for pass / fail dont actually fail the build though yet, just for more info
    $StatementThreshold = 80
    $FunctionThreshold = 100

    "`n`tStatement coverage: $($CodeCoverage.Statement.Analyzed) analyzed, $($CodeCoverage.Statement.Executed) executed, $($CodeCoverage.Statement.Missed) missed, $($CodeCoverage.Statement.Coverage)%."
    if ($CodeCoverage.Statement.Coverage -ge $StatementThreshold) {
        # passed Statement coverage test
        Write-Host "`tPassed statement coverage threshold of: $StatementThreshold%" -ForegroundColor 'Green'
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Update-AppveyorTest -name 'PesterStatementCoverage' -Outcome 'Passed'
        }
    } else {
        # failed Statement coverage test
        Write-Warning "`tFailed function coverage threshold of: $StatementThreshold%"
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Add-AppveyorMessage -Message "`tFailed function coverage threshold of: $StatementThreshold%`n" -Category 'Error'
            Update-AppveyorTest -name 'PesterStatementCoverage' -Outcome 'Failed' -ErrorMessage "Pester statement coverage did not meet threshold of $StatementThreshold%"
        }
        # Failing the build
        Throw 'Build failed'
    }
    "`n`tFunction coverage: $($CodeCoverage.Function.Analyzed) analyzed, $($CodeCoverage.Function.Executed) executed, $($CodeCoverage.Function.Missed) missed, $($CodeCoverage.Function.Coverage)%."
    if ($CodeCoverage.Function.Coverage -ge $FunctionThreshold) {
        # passed Function coverage test
        Write-Host "`tPassed function coverage threshold of: $FunctionThreshold%" -ForegroundColor 'Green'
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Update-AppveyorTest -name 'PesterFunctionCoverage' -Outcome 'Passed'
        }
    } else {
        # failed Function coverage test
        Write-Warning "`tFailed function coverage threshold of: $FunctionThreshold%"

        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Add-AppveyorMessage -Message "`tFailed function coverage threshold of: $FunctionThreshold%`n" -Category 'Error'
            Update-AppveyorTest -name 'PesterFunctionCoverage' -Outcome 'Failed' -ErrorMessage "Pester statement coverage did not meet threshold of $FunctionThreshold%"
        }
        # Failing the build
        Throw 'Build failed'
    }
    "`n"
}

Task Build -depends Coverage {
    $lines
    Write-Host "`nUpdating exported module members"
    Set-ModuleFunctions @Verbose
    Write-Host "`nIncrementing build number"
    Update-Metadata -Path $env:BHPSModuleManifest @Verbose

    # Generate help for the module
    Get-Module -name 'PlatyPS', 'PSDokuWiki' | Remove-Module -Force
    Import-Module (Join-Path -Path $ProjectRoot -ChildPath 'PSDokuWiki\PSDokuWiki.psm1') -Global -Force @Verbose
    Write-Host 'Generating markdown help'
    Update-MarkdownHelpModule -Path "$ProjectRoot\docs\" -AlphabeticParamsOrder -Force -RefreshModulePage @Verbose | Out-Null
    New-Item -Path "$ProjectRoot\PSDokuWiki\en-US" -ItemType 'Directory' -ErrorAction 'SilentlyContinue' @Verbose | Out-Null
    try {
        Write-Host 'Generating MAML help'
        New-ExternalHelp -Path '.\docs\' -OutputPath '.\PSDokuWiki\en-US' -Force -ErrorAction 'Stop' @Verbose | Out-Null
    } catch {
        throw 'Build failed - Failed to generate help files'
        $_
    }
    "`n"
}

Task PostBuildTest -depends Build {
    $lines
    "`n`tSTATUS: Post-build test with PowerShell $PSVersion"

    Get-Module -name 'PSDokuWiki' | Remove-Module -Force
    Import-Module (Join-Path -Path $ProjectRoot -ChildPath 'PSDokuWiki\PSDokuWiki.psd1') -Force @Verbose

    # Gather test results. Store them in a variable and file
    $Script:TestResults = Invoke-Pester -Path "$ProjectRoot\Tests" -OutputFormat 'NUnitXml' -OutputFile "$ProjectRoot\$TestFile" -PassThru @Verbose -Tag PostBuild
    $Script:TestResults | Export-Clixml -Path "$ProjectRoot\PesterResults$PSVersion.xml"

    $AllFiles = Get-ChildItem -Path "$ProjectRoot\*Results*.xml" | Select-Object -ExpandProperty 'FullName'
    "COLLATING FILES:`n$($AllFiles | Out-String)"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        Get-ChildItem -Path "$ProjectRoot\TestResults_PS*.xml" | ForEach-Object -Process {
            $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
            $Source = $_.FullName
            "UPLOADING FILES: $Address $Source"
            (New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )
        }
    }

    $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Import-Clixml )
    $FailedCount = $Results | Select-Object -ExpandProperty 'FailedCount' | Measure-Object -Sum | Select-Object -ExpandProperty 'Sum'

    if ($FailedCount -gt 0) {

        $FailedItems = $Results | Select-Object -ExpandProperty 'TestResult' | Where-Object -FilterScript { $_.Passed -notlike $True }
        "FAILED TESTS SUMMARY:`n"

        $FailedItems | ForEach-Object -Process {
            $Test = $_
            [pscustomobject]@{
                Describe = $Test.Describe
                Context  = $Test.Context
                Name     = "It $($Test.Name)"
                Result   = $Test.Result
            }
        } | Sort-Object -Property 'Describe', 'Context', 'Name', 'Result' | Format-List
        throw "$FailedCount tests failed."
    }

    Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Remove-Item -Force -ErrorAction 'SilentlyContinue'
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction 'SilentlyContinue'

    "`n"
}

Task Deploy -depends PostBuildTest {
    $lines

    # Publish to gallery with a few restrictions
    if (($env:BHProjectName) -and ($env:BHProjectName.Count -eq 1) -and ($env:BHBuildSystem -ne 'Unknown') -and ($env:BHBranchName -eq 'master') -and ($env:BHCommitMessage -match '!deploy') -and ($isWindows -eq $true)) {
        Write-Host 'Deploying to PSGallery...'
        Publish-Module -Path $ENV:BHPSModulePath -Repository 'PSGallery' -NuGetApiKey $ENV:NugetApiKey -ErrorAction Stop @Verbose
    } else {
        "Skipping deployment: To deploy, ensure that...`n" + "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" + "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" + "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)" + "`t* The build OS is Windows (Current: $isWindows)" | Write-Host
    }
}