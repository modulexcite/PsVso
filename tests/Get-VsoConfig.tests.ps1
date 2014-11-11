$here = Split-Path -Parent $MyInvocation.MyCommand.Path

"$here\..\functions\*.ps1", "$here\..\cmdlets\*.ps1" |
Resolve-Path |
Where-Object { -not ($_.ProviderPath.Contains(".Tests.")) } |
ForEach-Object { . $_.ProviderPath }


Describe "Get-VsoConfig" {
    $globalConfig = '{"project": "globalProject", "account":"globalAccount"}'
    $localConfig = '{"project": "localProject", "repository":"localRepository"}'

    $appData = [System.Environment]::ExpandEnvironmentVariables("%userprofile%")
    Write-Host "*$appData*"
    Context "When asking for just local config" {
        Mock Get-Content { return $globalConfig } -ParameterFilter { $path -like "*$appData*"} 
        Mock Get-Content { return $localConfig } -ParameterFilter { -not ($path -like "*$appData*") } 

        $result = Get-VsoConfig -Local
        Write-Host $result

        It "returns all local values"{
            $result.count | Should be 2
        }


        It "returns the local value"{
            $result.project | Should be "localProject"
        }
    }


    Context "When asking for just global config" {
        Mock Get-Content { return $globalConfig} -ParameterFilter { $path -like "*$appData*"}
        Mock Get-Content { return $localConfig} -ParameterFilter {-not ($path -like "*$appData*")}

        $result = Get-VsoConfig -Global

        It "returns all local values"{
            $result.count | Should be 2
        }


        It "returns the global value"{
            $result.project | Should be "globalProject"
        }
    }

    Context "When asking for config" {
        Mock Get-Content { return $globalConfig} -ParameterFilter { $path -like "*$appData*"} 
        Mock Get-Content { return $localConfig} -ParameterFilter {-not ($path -like "*$appData*")}

        $result = Get-VsoConfig


        It "returns all combined values"{
            $result.count | Should be 3
        }

        It "returns the local value over global"{
            $result.project | Should be "localProject"
        }


        It "returns the global value when no local"{
            $result.account | Should be "globalAccount"
        }
    }

}