#!/usr/bin/env pwsh
# Copyright 2018-2022 the Deno authors. All rights reserved. MIT license.
# Copyright 2023 Jo Bates. All rights reserved. MIT license.
# TODO(everyone): Keep this script simple and easily auditable.

$ErrorActionPreference = 'Stop'

if ($v) {
  $Version = "v${v}"
}
if ($Args.Length -eq 1) {
  $Version = $Args.Get(0)
}

$DenoInstall = $env:DENO_INSTALL
$BinDir = if ($DenoInstall) {
  "${DenoInstall}\bin"
} else {
  "${Home}\.deno\bin"
}

$DenoZip = "$BinDir\denox.zip"
$DenoExe = "$BinDir\denox.exe"
$Target = 'x86_64-pc-windows-msvc'

$DownloadUrl = if (!$Version) {
  "https://github.com/denoxdev/denox/releases/latest/download/denox-${Target}.zip"
} else {
  "https://github.com/denoxdev/denox/releases/download/${Version}/denox-${Target}.zip"
}

if (!(Test-Path $BinDir)) {
  New-Item $BinDir -ItemType Directory | Out-Null
}

curl.exe -Lo $DenoZip $DownloadUrl

tar.exe xf $DenoZip -C $BinDir

Remove-Item $DenoZip

$User = [System.EnvironmentVariableTarget]::User
$Path = [System.Environment]::GetEnvironmentVariable('Path', $User)
if (!(";${Path};".ToLower() -like "*;${BinDir};*".ToLower())) {
  [System.Environment]::SetEnvironmentVariable('Path', "${Path};${BinDir}", $User)
  $Env:Path += ";${BinDir}"
}

Write-Output "Denox was installed successfully to ${DenoExe}"
Write-Output "Run 'denox --help' to get started"
