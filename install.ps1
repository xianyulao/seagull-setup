# seagull one-click installer for opencode + hermes
# Usage: iwr "https://raw.githubusercontent.com/xianyulao/seagull-setup/main/install.ps1" | iex
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$base = "https://raw.githubusercontent.com/xianyulao/seagull-setup/main"

$ocDir     = "$env:USERPROFILE\.config\opencode"
$agentsDst = "$ocDir\AGENTS.md"
$ocSkills  = "$ocDir\skills"
$hermesSkills = "$env:USERPROFILE\AppData\Local\hermes\profiles\seagull\skills"

Write-Host "[*] seagull installer starting" -ForegroundColor Cyan

# --- 1. AGENTS.md persona ---
if (-not (Test-Path $ocDir)) { New-Item -ItemType Directory -Path $ocDir -Force | Out-Null }
if (Test-Path $agentsDst) {
    Copy-Item $agentsDst "$agentsDst.bak_$(Get-Date -Format yyyyMMdd_HHmmss)" -Force
    Write-Host "[+] backed up existing AGENTS.md"
}
Invoke-WebRequest "$base/AGENTS.md" -OutFile $agentsDst -UseBasicParsing
Write-Host "[+] persona installed -> $agentsDst ($((Get-Item $agentsDst).Length) bytes)" -ForegroundColor Green

# --- 2. download skill zips to temp ---
$tmp = Join-Path $env:TEMP "seagull_setup"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

Write-Host "[*] downloading skill packs..."
Invoke-WebRequest "$base/opencode_skills.zip" -OutFile "$tmp\opencode_skills.zip" -UseBasicParsing
Invoke-WebRequest "$base/hermes_skills.zip"   -OutFile "$tmp\hermes_skills.zip"   -UseBasicParsing

# --- 3. extract opencode skills ---
if (-not (Test-Path $ocSkills)) { New-Item -ItemType Directory -Path $ocSkills -Force | Out-Null }
Expand-Archive "$tmp\opencode_skills.zip" -DestinationPath $ocSkills -Force
Write-Host "[+] opencode skills -> $ocSkills" -ForegroundColor Green

# --- 4. extract hermes skills ---
if (-not (Test-Path $hermesSkills)) { New-Item -ItemType Directory -Path $hermesSkills -Force | Out-Null }
Expand-Archive "$tmp\hermes_skills.zip" -DestinationPath $hermesSkills -Force
Write-Host "[+] hermes skills -> $hermesSkills" -ForegroundColor Green

# --- 5. cleanup ---
Remove-Item $tmp -Recurse -Force
Write-Host ""
Write-Host "[OK] seagull fully installed. restart opencode and send 在吗 to test." -ForegroundColor Green
