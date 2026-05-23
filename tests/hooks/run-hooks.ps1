param(
    [string]$CasesPath = "tests/hooks/cases.json"
)

$ErrorActionPreference = "Stop"

function Resolve-Bash {
    $bash = Get-Command bash -ErrorAction SilentlyContinue
    if ($null -ne $bash) {
        return $bash.Source
    }

    $candidates = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    throw "bash was not found on PATH. Install Git Bash or provide bash on PATH."
}

function Resolve-Jq {
    $jq = Get-Command jq -ErrorAction SilentlyContinue
    if ($null -ne $jq) {
        return
    }

    $wingetJq = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" `
        -Recurse `
        -Filter jq.exe `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($null -ne $wingetJq) {
        $jqDirectory = Split-Path -Parent $wingetJq.FullName
        $env:PATH = "$jqDirectory;$env:PATH"
        return
    }

    throw "jq was not found on PATH. Install jq before running hook tests."
}

function Invoke-HookCase {
    param(
        [object]$Case,
        [string]$BashPath
    )

    $inputJson = $Case.input | ConvertTo-Json -Depth 20 -Compress
    $tempIn = New-TemporaryFile
    $tempOut = New-TemporaryFile
    $tempErr = New-TemporaryFile

    try {
        Set-Content -Path $tempIn -Value $inputJson -NoNewline -Encoding UTF8

        $process = Start-Process `
            -FilePath $BashPath `
            -ArgumentList @($Case.hook) `
            -NoNewWindow `
            -RedirectStandardInput $tempIn `
            -RedirectStandardOutput $tempOut `
            -RedirectStandardError $tempErr `
            -Wait `
            -PassThru

        $stdout = Get-Content -Raw -Path $tempOut
        $stderr = Get-Content -Raw -Path $tempErr
        $exitCode = $process.ExitCode

        $ok = $true
        $messages = New-Object System.Collections.Generic.List[string]

        if ($exitCode -ne [int]$Case.expectedExit) {
            $ok = $false
            $messages.Add("expected exit $($Case.expectedExit), got $exitCode")
        }

        if ($Case.PSObject.Properties.Name -contains "expectStderr") {
            if (!$stderr.Contains([string]$Case.expectStderr)) {
                $ok = $false
                $messages.Add("stderr did not contain '$($Case.expectStderr)'")
            }
        }

        if ($ok) {
            Write-Host "PASS $($Case.name)"
            return $true
        }

        Write-Host "FAIL $($Case.name)" -ForegroundColor Red
        foreach ($message in $messages) {
            Write-Host "  $message" -ForegroundColor Red
        }
        if ($stdout) {
            Write-Host "  stdout: $stdout"
        }
        if ($stderr) {
            Write-Host "  stderr: $stderr"
        }

        return $false
    }
    finally {
        Remove-Item -Force $tempIn, $tempOut, $tempErr -ErrorAction SilentlyContinue
    }
}

Resolve-Jq
$bashPath = Resolve-Bash

if (!(Test-Path $CasesPath)) {
    throw "Cases file not found: $CasesPath"
}

$cases = Get-Content -Raw -Path $CasesPath | ConvertFrom-Json
$failures = 0

foreach ($case in $cases) {
    if (!(Test-Path $case.hook)) {
        Write-Host "FAIL $($case.name)" -ForegroundColor Red
        Write-Host "  hook not found: $($case.hook)" -ForegroundColor Red
        $failures++
        continue
    }

    $passed = Invoke-HookCase -Case $case -BashPath $bashPath
    if (!$passed) {
        $failures++
    }
}

if ($failures -gt 0) {
    Write-Host "$failures hook test(s) failed." -ForegroundColor Red
    exit 1
}

Write-Host "All $($cases.Count) hook tests passed."
