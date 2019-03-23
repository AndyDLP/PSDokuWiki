# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
        $ProjectRoot = $ENV:BHProjectPath
        if (-not $ProjectRoot) {
            $ProjectRoot = $PSScriptRoot
        }

    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
}

Task Default -Depends Deploy

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Analyze -depends Init {
    $lines
    # ScriptAnalyzer
    "`nSCRIPTANALYZER: CHECKING..."

    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
        Add-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Running
    }

    $CodeResults = Invoke-ScriptAnalyzer -Path $ProjectRoot\PSDokuWiki -Recurse -Severity Error -ErrorAction SilentlyContinue @Verbose
    If ($CodeResults) {
        $ResultString = $CodeResults | Out-String
        Write-Warning $ResultString

        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Add-AppveyorMessage -Message "PSScriptAnalyzer output contained one or more result(s) with 'Error' severity. Check the 'Tests' tab of this build for more details." -Category Error
            Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Failed -ErrorMessage $ResultString
        }

        # Failing the build
        Throw "Build failed - PSScriptAnalyzer"
    } else {
        "`tNO ERRORS`n"
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Passed
        }
    }
    "`n"
}

Task Test -Depends Analyze {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    Import-Module (Join-Path -Path $ProjectRoot -ChildPath 'PSDokuWiki') -Force @Verbose

    # Gather test results. Store them in a variable and file
    $Script:TestResults = Invoke-Pester -Path "$ProjectRoot\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru -CodeCoverage "$ProjectRoot\PSDokuWiki\*\*.ps1" @Verbose
    $Script:TestResults | Export-Clixml -Path "$ProjectRoot\PesterResults$PSVersion.xml"

    $AllFiles = Get-ChildItem -Path $ProjectRoot\*Results*.xml | Select-Object -ExpandProperty FullName
    "COLLATING FILES:`n$($AllFiles | Out-String)"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        Get-ChildItem -Path "$ProjectRoot\TestResults_PS*.xml" | Foreach-Object -Process {
            $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
            $Source = $_.FullName
            "UPLOADING FILES: $Address $Source"
            (New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )
        }
    }

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

    Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Remove-Item -Force -ErrorAction SilentlyContinue
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
}

Task Coverage -Depends Test {
    # CODE COVERAGE

    "`nCODE COVERAGE:"
    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
        Add-AppveyorTest -Name "PesterStatementCoverage" -Outcome Running
        Add-AppveyorTest -Name "PesterFunctionCoverage" -Outcome Running
    }
    $CodeCoverage = @{
        Functions = @{}
        Statement = @{
            Analyzed = $Script:TestResults.CodeCoverage.NumberOfCommandsAnalyzed
            Executed = $Script:TestResults.CodeCoverage.NumberOfCommandsExecuted
            Missed   = $Script:TestResults.CodeCoverage.NumberOfCommandsMissed
            Coverage = 0
        }
        Function = @{}
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


    # Define thresholds for pass / fail dont actually fail the build though yet, just for more info
    $StatementThreshold = 80
    $FunctionThreshold = 100

    "`n`tStatement coverage: $($CodeCoverage.Statement.Analyzed) analyzed, $($CodeCoverage.Statement.Executed) executed, $($CodeCoverage.Statement.Missed) missed, $($CodeCoverage.Statement.Coverage)%."
    if ($CodeCoverage.Statement.Coverage -ge $StatementThreshold) {
        # passed Statement coverage test
        Write-Host "`tPassed statement coverage threshold of: $StatementThreshold%" -ForegroundColor Green
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Update-AppveyorTest -Name "PesterStatementCoverage" -Outcome Passed
        }
    } else {
        # failed Statement coverage test
        Write-Warning "`tFailed function coverage threshold of: $StatementThreshold%"
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Add-AppveyorMessage -Message "`tFailed function coverage threshold of: $StatementThreshold%`n" -Category Error
            Update-AppveyorTest -Name "PesterStatementCoverage" -Outcome Failed -ErrorMessage "Pester statement coverage did not meet threshold of $StatementThreshold%"
        }
        # Failing the build
        Throw "Build failed"
    }
    "`n`tFunction coverage: $($CodeCoverage.Function.Analyzed) analyzed, $($CodeCoverage.Function.Executed) executed, $($CodeCoverage.Function.Missed) missed, $($CodeCoverage.Function.Coverage)%."
    if ($CodeCoverage.Function.Coverage -ge $FunctionThreshold) {
        # passed Function coverage test
        Write-Host "`tPassed function coverage threshold of: $FunctionThreshold%" -ForegroundColor Green
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Update-AppveyorTest -Name "PesterFunctionCoverage" -Outcome Passed
        }
    } else {
        # failed Function coverage test
        Write-Warning "`tFailed function coverage threshold of: $FunctionThreshold%"
        
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Add-AppveyorMessage -Message "`tFailed function coverage threshold of: $FunctionThreshold%`n" -Category Error
            Update-AppveyorTest -Name "PesterFunctionCoverage" -Outcome Failed -ErrorMessage "Pester statement coverage did not meet threshold of $FunctionThreshold%"
        }
        # Failing the build
        Throw "Build failed"
    }
    "`n"
}

Task Build -Depends Coverage {
    $lines
    Write-Host "`nUpdating exported module members"
    Set-ModuleFunctions @Verbose
    Write-Host "`nIncrementing build number"
    Update-Metadata -Path $env:BHPSModuleManifest @Verbose

    # Generate help for the module
    Set-Location $ProjectRoot
    Import-Module '.\PSDokuWiki' -Force
    Update-MarkdownHelpModule -Path ".\docs" -AlphabeticParamsOrder -Force -RefreshModulePage
    New-Item -Path '.\PSDokuWiki\en-US' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    try {
        New-ExternalHelp -Path ".\docs" -OutputPath ".\PSDokuWiki\en-US" -Force -ErrorAction Stop
    }
    catch {
        throw "Build failed - Failed to generate help files"
    }
    "`n"
}

Task Deploy -Depends Build {
    $lines
    $Params = @{
        Path = $ProjectRoot
        Force = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }
    Invoke-PSDeploy @Verbose @Params
}