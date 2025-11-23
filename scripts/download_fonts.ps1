# Download Montserrat font files into assets/fonts
# Usage (PowerShell):
#   .\scripts\download_fonts.ps1

$targetDir = "assets/fonts"
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

$files = @(
    @{ name = "Montserrat-Regular.ttf"; url = "https://github.com/google/fonts/raw/main/ofl/montserrat/Montserrat-Regular.ttf" },
    @{ name = "Montserrat-Medium.ttf"; url = "https://github.com/google/fonts/raw/main/ofl/montserrat/Montserrat-Medium.ttf" },
    @{ name = "Montserrat-SemiBold.ttf"; url = "https://github.com/google/fonts/raw/main/ofl/montserrat/Montserrat-SemiBold.ttf" },
    @{ name = "Montserrat-Bold.ttf"; url = "https://github.com/google/fonts/raw/main/ofl/montserrat/Montserrat-Bold.ttf" }
)

foreach ($f in $files) {
    $out = Join-Path $targetDir $($f.name)
    Write-Host "Downloading $($f.name) ..."
    try {
        Invoke-WebRequest -Uri $f.url -OutFile $out -UseBasicParsing -ErrorAction Stop
        Write-Host "Saved -> $out"
    } catch {
        Write-Warning "Failed to download $($f.url): $_"
    }
}

Write-Host "Done. Run: flutter pub get"