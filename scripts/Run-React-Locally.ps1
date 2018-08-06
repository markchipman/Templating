#!/usr/bin/env pwsh
#requires -version 4

[CmdletBinding(PositionalBinding = $false)]
param()

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'

. $PSScriptRoot\Custom-Hive.ps1

Test-Template "react" "Microsoft.DotNet.Web.Spa.ProjectTemplates.2.2.0-preview1-t000.nupkg" $true
