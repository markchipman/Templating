$customHive = "$PSScriptRoot/CustomHive"

function Test-Template($templateName, $templateNupkg, $isSPA) {
    $tmpDir = "$PSScriptRoot/tmp"
    Remove-Item -Path $tmpDir -Recurse -ErrorAction Ignore

    Create-Hive

    & "$PSScriptRoot/../build.cmd" /t:Package
    Run-DotnetNew "--install", "$PSScriptRoot/../artifacts/build/$templateNupkg"

    New-Item -ErrorAction Ignore -Path $tmpDir -ItemType Directory
    Push-Location $tmpDir
    try {
        Run-DotnetNew $templateName, "--no-restore"
        $csproj = "$tmpDir/tmp.csproj"
        $csprojContent = Get-Content -Path $csproj -Raw
        $csprojContent = $csprojContent -replace ('<Project Sdk="Microsoft.NET.Sdk.Web">', "<Project Sdk=""Microsoft.NET.Sdk.Web"">`n<Import Project=""$PSScriptRoot/../test/Templates.Test/bin/Release/netcoreapp2.2/TemplateTests.props"" />")
        $csprojContent | Set-Content $csproj

        dotnet publish
        dotnet run bin\Release\netcoreapp2.2\publish\tmp.dll

    }
    finally {
        Pop-Location
    }
}

function Create-Hive {
    Write-Host "Creating custom hive"
    Remove-Item -Path $customHive -Force -Recurse -ErrorAction Ignore
    New-Item -Path $customHive -ItemType Directory | out-null
    Clean-Hive
}

function Clean-Hive() {
    $packageArray = Run-DotnetNew "--uninstall"
    $packageStr = $packageArray -join [Environment]::NewLine
    $packagesStr = ($packageStr -split "Currently installed items:")[1]
    $packagesStr = $packagesStr.Trim()
    $packages = $packagesStr -split [Environment]::NewLine

    foreach ($package in $packages) {
        $package = $package.Trim()
        Run-DotnetNew "--uninstall", "$package" | out-null
    }
    Run-DotnetNew "--uninstall" | out-null
}

function Run-DotnetNew($arguments) {
    dotnet new $arguments --debug:custom-hive $customHive
}
