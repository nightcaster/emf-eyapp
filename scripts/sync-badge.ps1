# Sync script to copy EyApp to a physical Tildagon Badge using mpremote

Write-Host "Connecting to Tildagon badge..." -ForegroundColor Cyan

# Check if python is available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python is not installed or not in your PATH. Cannot run mpremote."
    exit 1
}

# Create destination app directory on the badge if it doesn't exist
Write-Host "Creating apps/mbooth101_emf_eyapp directory on the badge..." -ForegroundColor Yellow
& python -m mpremote fs mkdir :apps/mbooth101_emf_eyapp 2>$null

# Compile app.py to app.mpy
Write-Host "Compiling app.py to app.mpy..." -ForegroundColor Yellow
$appPyPath = Join-Path $PSScriptRoot "..\app.py"
& python -m mpy_cross $appPyPath
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to compile app.py with mpy-cross."
    exit $LASTEXITCODE
}

$filesToCopy = @(
    "app.mpy",
    "tildagon.toml",
    "__init__.py"
)

# Copy files
foreach ($file in $filesToCopy) {
    $filePath = Join-Path $PSScriptRoot "..\$file"
    if (Test-Path $filePath) {
        Write-Host "Copying $file to badge..." -ForegroundColor Yellow
        & python -m mpremote fs cp $filePath :apps/mbooth101_emf_eyapp/$file
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to copy $file to badge."
            exit $LASTEXITCODE
        }
    }
    else {
        Write-Warning "File $file not found locally, skipping."
    }
}

# Reset badge to apply changes
Write-Host "Resetting badge to apply changes..." -ForegroundColor Yellow
& python -m mpremote reset

Write-Host "Sync to Badge completed successfully!" -ForegroundColor Green
exit 0
