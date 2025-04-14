$SCRIPT = Join-Path $PSScriptRoot "find_gtags_defs.ps1"
$expression = "global -c | fzf"
$result = Invoke-Expression( $expression )

# Output is filename, line number, character, contents
if ("$result".Length -lt 1) {
    Write-Host canceled
    "1" | Out-File -FilePath "$Env:CANARY_FILE" -Encoding UTF8
    exit 1
} else {
    powershell -File $SCRIPT $result @args "-x"
}
