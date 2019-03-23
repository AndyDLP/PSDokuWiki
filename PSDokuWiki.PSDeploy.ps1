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
    <#
    Deploy Module {
        By PSGalleryModule {
            FromSource $ENV:BHProjectName
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
            }
        }
    } @Verbose
    #>

    # Prepare git
    git config --global credential.helper store
    Add-Content "$HOME\.git-credentials" "https://$($env:access_token):x-oauth-basic@github.com`n"
    git config --global user.email "andydlp93@gmail.com"
    git config --global user.name "AndyDLP-AV"
    git remote add origin https://github.com/AndyDLP/PSDokuWiki.git

    Deploy GitHub {
        By Git {
            FromSource $env:BHProjectName
            To 'master'
            WithOptions @{
                CommitMessage ='Build success - Updating version - [skip ci]'
            }
        }
    } @Verbose
    
} else {
    "Skipping deployment: To deploy, ensure that...`n" + "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" + "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" + "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)" | Write-Host
}

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