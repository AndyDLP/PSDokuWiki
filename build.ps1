# Stolen from RamblingCookieMoster 
# http://ramblingcookiemonster.github.io/PSDeploy-Inception/
# https://github.com/RamblingCookieMonster/PSDeploy/blob/f813a8ba39702cf446fe0b23994e18936412ea9c/build.ps1
function Resolve-Module {
    [Cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [string[]]$Name
    )

    begin {}#

    process {
        foreach ($ModuleName in $Name) {
            $Module = Get-Module -Name $ModuleName -ListAvailable
            Write-Verbose -Message "Resolving Module $($ModuleName)"
            if ($Module) {
                $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
                $GalleryVersion = Find-Module -Name $ModuleName -Repository PSGallery | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
                if ($Version -lt $GalleryVersion) {
                    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }
                    Write-Verbose -Message "$($ModuleName) Installed Version [$($Version.tostring())] is outdated. Installing Gallery Version [$($GalleryVersion.tostring())]"
                    Install-Module -Name $ModuleName -Force | Out-Null
                    Import-Module -Name $ModuleName -Force -RequiredVersion $GalleryVersion
                } else {
                    Write-Verbose -Message "Module Installed, Importing $($ModuleName)"
                    Import-Module -Name $ModuleName -Force -RequiredVersion $Version
                }
            } else {
                Write-Verbose -Message "$($ModuleName) Missing, installing Module"
                Install-Module -Name $ModuleName -Force -Repository PSGallery | Out-Null
                $Module = Get-Module -Name $ModuleName -ListAvailable
                $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
                Import-Module -Name $ModuleName -Force -RequiredVersion $Version
            }
        } # foreach module
    } # process

    end {}
} # function

# Grab nuget bits, install modules, set build variables, start build.
Install-PackageProvider -Name NuGet -Force | Out-Null
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Resolve-Module -Name Psake,PSDeploy,Pester,BuildHelpers,PsScriptAnalyzer,PlatyPS

Set-BuildEnvironment

Invoke-psake .\psake.ps1
exit ( [int]( -not $psake.build_success ) )