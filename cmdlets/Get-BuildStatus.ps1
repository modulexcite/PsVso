
function Get-XamlBuildStatus {
<#
.SYNOPSIS
Gets the current status of the XAML build

.DESCRIPTION
Get-XamlBuildStatus will query your VSO project to see the status of the last build. This is usefull to make sure you don't push 
changes when the build is not green

.PARAMETER BuildDefinition
The name of the build definition.  Can be inherited from a config file.

.PARAMETER Account
The acount name to use. Can be inherited from a config file.
If your VSO url is hello.visualstudio.com then this value should be hello.

.PARAMETER Project
The project name to use. Can be inherited from a config file.

.Example
Get-XamlBuildStatus -BuildDefinition myBuildDef -Account myAccount -Project myProject

.LINK
about_PsVso

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$BuildDefinition,
        [Parameter(Mandatory = $false)]
        [string]$Account,
        [Parameter(Mandatory = $false)]
        [string]$Project
    )

    refreshCachedConfig

    $definitionName = getFromValueOrConfig $BuildDefinition $script:config_buildDefinitionKey
    $accountName    = getFromValueOrConfig $Account $script:config_accountKey
    $projectName    = getFromValueOrConfig $Project $script:config_projectKey

    $buildResults = getBuilds $accountName $projectName $definitionName

    if($buildResults) {
        if($buildResults[0].status -eq "succeeded") {
            Write-Host "Build $($buildResults[0].buildNumber) SUCCEEDED" -ForegroundColor Green
        }
        elseif($buildResults[0].status -eq "failed") {
            Write-Host "Build $($buildResults[0].buildNumber) FAILED" -ForegroundColor Red
        }
        else {
            Write-Host "Build $($buildResults[0].buildNumber) $($buildResults[0].status.ToUpper())"
        }
        
    }
    else {
        Write-Warning "Unable to find build for $definitionName"
    }

}
