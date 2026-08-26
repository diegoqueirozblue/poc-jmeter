param(
    [string]$ConfigFile = "config/benchmark.properties",
    [string]$ResultDir = "results",
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$JMeterArguments
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

if ($env:RESULT_DIR -and $ResultDir -eq "results") {
    $ResultDir = $env:RESULT_DIR
}

if (-not (Test-Path $ConfigFile)) {
    throw "Configuration file not found: $ConfigFile. Copy config/benchmark.properties.example first."
}

$JMeterBin = if ($env:JMETER_BIN) { $env:JMETER_BIN } else { "jmeter" }
$JtlFile = if ($env:JTL_FILE) { $env:JTL_FILE } else { Join-Path $ResultDir "result.jtl" }
$ReportDir = if ($env:REPORT_DIR) { $env:REPORT_DIR } else { Join-Path $ResultDir "report" }

New-Item -ItemType Directory -Force -Path $ResultDir | Out-Null
if (Test-Path $JtlFile) {
    Remove-Item -Force $JtlFile
}
if (Test-Path $ReportDir) {
    Remove-Item -Recurse -Force $ReportDir
}

& $JMeterBin -n `
    -t "jmeter/benchmark.jmx" `
    -q $ConfigFile `
    -l $JtlFile `
    -e -o $ReportDir `
    @JMeterArguments

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
