# bat wrapper script for grep result format
#
# grep_bat.ps1 $options /path/to/file:lineno:
# --> bat $options --line-range n:m /path/to/file
#
$opts = @()
$positional = @()

foreach ($arg in $args) {
    if ($arg -like '-*') {
        $opts += $arg
    } else {
        $positional += $arg
    }
}
# C:/path/to/:line:
$path = $positional[0]
if ($path -match '^(.*):(\d+):$') {
    $filepath = $matches[1]
    $lineno = [int]$matches[2]
}
$p = $lineno - 3
$n = $lineno + 3
$extraArgs = $opts +  " --line-range ${p}:${n} " + $filepath
powershell bat @extraArgs