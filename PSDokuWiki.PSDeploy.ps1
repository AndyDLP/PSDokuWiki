# Generic module deployment.
# This stuff should be moved to psake for a cleaner deployment view

# ASSUMPTIONS:

 # folder structure of:
 # - RepoFolder
 #   - This PSDeploy file
 #   - ModuleName
 #     - ModuleName.psd1

 # Nuget key in $ENV:NugetApiKey

 # Set-BuildEnvironment from BuildHelpers module has populated ENV:BHProjectName

 $Verbose = @{}
 if($ENV:BHCommitMessage -match "!verbose")
 {
     $Verbose = @{Verbose = $True}
 }

# Publish to gallery with a few restrictions
if($env:BHProjectName -and $env:BHProjectName.Count -eq 1 -and $env:BHBuildSystem -ne 'Unknown' -and $env:BHBranchName -eq "master" -and $env:BHCommitMessage -match '!deploy') {
    Write-Host "Deploying to PSGallery..."
    Deploy Module {
        By PSGalleryModule {
            FromSource $ENV:BHProjectName
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
            }
        }
    } @Verbose -ErrorAction Stop

    Write-Host "`n"
    Write-Host "checking out"
    $Output = Invoke-git "checkout -B master" -ErrorAction SilentlyContinue

    Write-Host "Adding files to git"
    $Output = Invoke-Git "add *" -ErrorAction SilentlyContinue

    Write-Host "Committing changes"
    $Output = Invoke-Git 'commit -m "Build successful - [skip ci]"' -ErrorAction SilentlyContinue

    Write-Host "Pushing back to GitHub"
    $Output = Invoke-git "push origin master" -ErrorAction SilentlyContinue

} else {
    "Skipping deployment: To deploy, ensure that...`n" + "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" + "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" + "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)" | Write-Host
}

<#
# Publish to AppVeyor if we're in AppVeyor
if ($env:BHProjectName -and $ENV:BHProjectName.Count -eq 1 -and $env:BHBuildSystem -eq 'AppVeyor' ) {
    Write-Host "`nDeploying developer build to AppVeyor"
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $ENV:BHProjectName
            To AppVeyor
            WithOptions @{
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }
    } @Verbose
}
#>