# ---------------- PS7 & DEPENDENCY HANDLER ----------------
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host ">>> Checking for PowerShell 7..." -Fore Yellow
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if (!$pwsh -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host ">>> Installing PS7 via winget..." -Fore Cyan
        winget install --id Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements | Out-Null
        $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    }
    if ($pwsh) { 
        Write-Host ">>> Relaunching in PS7..." -Fore Green
        Start-Process pwsh -ArgumentList "-File `"$PSCommandPath`"" ; exit 
    } else { 
        Write-Host ">>> Error: PowerShell 7 required." -Fore Red; pause; exit 
    }
}

$moduleName = "Microsoft.PowerShell.ConsoleGuiTools"
if (-not (Get-Command Out-ConsoleGridView -ErrorAction SilentlyContinue)) {
    if (-not (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Host ">>> OFFLINE: Dependency missing. Connect to internet and restart." -Fore Red; pause; exit
    } else {
        Write-Host ">>> Installing UI Tools..." -Fore Cyan
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false | Out-Null
        Install-Module -Name $moduleName -Scope CurrentUser -Force -SkipPublisherCheck -Confirm:$false
    }
}
Import-Module $moduleName -ErrorAction SilentlyContinue

# ---------------- CONFIG & SCAN ----------------
Set-Location $PSScriptRoot
$config = @{ Files = @(); Format = "cso1"; Flags = @(); Dest = ""; Overwrite = $false }
$currentStep = 1

while ($currentStep -lt 5) {
    switch ($currentStep) {
        1 {
            $path = Read-Host "Scan path (Enter for current: $(Get-Location))"
            $target = if ([string]::IsNullOrWhiteSpace($path)) { Get-Location } else { $path }
            if (!(Test-Path $target)) { Write-Host "Invalid Path" -Fore Red; continue }
            $files = Get-ChildItem $target -Recurse -File | Where { $_.Extension -in '.iso','.bin','.img' -and $_.Length -gt 10MB }
            if (!$files) { Write-Host "No disc images found." -Fore Red; continue }
            $config.Files = $files | Out-ConsoleGridView -Title "Step 1: Select Files" -OutputMode Multiple
            if (!$config.Files) { continue }; $currentStep++
        }
        2 {
            $fmt = @("cso (Standard)","zso (LZ4)","dax (Legacy)","[ BACK ]") | Out-ConsoleGridView -Title "Step 2: Format" -OutputMode Single
            if ($null -eq $fmt -or $fmt -eq "[ BACK ]") { $currentStep--; continue }
            $config.Format = if ($fmt -like "*zso*") { "zso" } elseif ($fmt -like "*dax*") { "dax" } else { "cso1" }
            $currentStep++
        }
        3 {
            $opts = @("[ BACK ]","OVERWRITE","block=2048","block=16384","use-zlib","use-zopfli","use-lz4","use-libdeflate") | Out-ConsoleGridView -Title "Step 3: Flags" -OutputMode Multiple
            if ($null -eq $opts -or $opts -contains "[ BACK ]") { $currentStep--; continue }
            $config.Flags = @(); $config.Overwrite = $false
            foreach ($o in $opts) {
                if ($o -eq "OVERWRITE") { $config.Overwrite = $true }
                elseif ($o -match "block=\d+") { $config.Flags += "--$($Matches[0])" }
                elseif ($o -match "use-[\w\d]+") { $config.Flags += "--$($Matches[0])" }
            }
            $currentStep++
        }
        4 {
            $dest = @("Current Directory","Paste Path","[ BACK ]") | Out-ConsoleGridView -Title "Step 4: Destination" -OutputMode Single
            if ($null -eq $dest -or $dest -eq "[ BACK ]") { $currentStep--; continue }
            if ($dest -eq "Paste Path") {
                $p = Read-Host "Enter Path"; if (Test-Path $p) { $config.Dest = $p; $currentStep++ }
            } else { $config.Dest = (Get-Location).Path; $currentStep++ }
        }
    }
}

# ---------------- EXECUTION ----------------
Write-Host "`n>>> STARTING BATCH: $([Environment]::ProcessorCount) THREADS <<<" -Fore Cyan
$stats = [PSCustomObject]@{ Original = 0; Final = 0; Count = 0 }

foreach ($file in $config.Files) {
    $outExt = if ($config.Format -eq 'cso1') { 'cso' } else { $config.Format }
    $outPath = Join-Path $config.Dest ($file.BaseName + "." + $outExt)
    if ($config.Overwrite -and (Test-Path $outPath)) { Remove-Item $outPath -Force }

    # Built-in PowerShell argument list (No manual quotes needed)
    $maxArgs = @(
        "--threads=$([Environment]::ProcessorCount)", 
        "--format=$($config.Format)"
    )
    foreach($f in $config.Flags) { $maxArgs += $f }
    $maxArgs += $file.FullName
    $maxArgs += "-o"
    $maxArgs += $outPath
    
    if (Test-Path ".\maxcso.exe") {
        Write-Host "`nProcessing: $($file.Name)" -Fore Cyan
        # Pass the array directly. PS7 handles the space in paths automatically.
        & ".\maxcso.exe" @maxArgs
        
        if (Test-Path $outPath) {
            $stats.Original += $file.Length
            $stats.Final += (Get-Item $outPath).Length
            $stats.Count++
        }
    } else { Write-Host "maxcso.exe missing!" -Fore Red; break }
}

# ---------------- SUMMARY ----------------
Write-Host "`n--- COMPRESSION SUMMARY ---" -Fore Cyan
if ($stats.Count -gt 0) {
    $saved = [math]::Round((1 - ($stats.Final / $stats.Original)) * 100, 1)
    Write-Host "Files: $($stats.Count) | Savings: $saved %" -Fore Green
    Write-Host "Final Size: $([math]::Round($stats.Final/1GB, 3)) GB" -Fore Cyan
} else { Write-Host "Files processed." -Fore Yellow }
Pause
