function ConvertTo-HumanReadable {
    param([int64]$Size)
    if ($Size -gt 1TB) { [string]::Format("{0:0.0} TB", $Size / 1TB) }
    elseif ($Size -gt 1GB) { [string]::Format("{0:0.0} GB", $Size / 1GB) }
    elseif ($Size -gt 1MB) { [string]::Format("{0:0.0} MB", $Size / 1MB) }
    elseif ($Size -gt 1KB) { [string]::Format("{0:0.0} KB", $Size / 1KB) }
    else { [string]::Format("{0:0.0} B", $Size) }
}

function Show-Choices {
    Write-Host "Miscellaneous:"
    Write-Host "[E] Exit"
    Write-Host "[A] Download All (Downloads all hooks - pre-commit, commit-msg, etc..)"
    Write-Host "[V] View folder (Opens the folder in File Explorer)"
    Write-Host "[?] Help (Show this dialog)" 
    Write-Host "`nHooks:"
    Write-Host "[1] pre-commit (Formats .CS files using dotnet-format command with )"
    Write-Host "[2] commit-msg (Checks commit message format. Forces conventional commit format)"
}

$currentDirectory = Get-Location

$lookForDirName = ".git/hooks"
$baseUri = "https://raw.githubusercontent.com/Kiruyuto/hooks-collection/master"
$hooksDirectory = Get-ChildItem -Path $currentDirectory -Recurse -Directory -Filter $lookForDirName -ErrorAction SilentlyContinue

if ($hooksDirectory) {
    Write-Host "[$($lookForDirName)] directory found at: [$($hooksDirectory.FullName)].."

    Write-Host "Is this the correct directory?"
    Write-Host "[Y] Yes | [N] No (default is 'N')`n"
    $userConfirmation = Read-Host
    if ($userConfirmation.ToLower() -in @("yes", "y")) {
        # Check if the directory has any files
        $files = Get-ChildItem -Path $hooksDirectory.FullName -File
        if ($files) {
            Write-Host "The [$($hooksDirectory.FullName)] directory has $($files.Count) file(s)."

            do {
                Write-Host "`nWould you like to delete them?"
                Write-Host "[Y] Yes | [N] No | [L] List all files (default is 'N')`n"
                $deleteConfirmation = Read-Host
                if ($deleteConfirmation.ToLower() -in @("yes", "y")) {
                    try {
                        $files | Remove-Item -Force
                        Write-Host "$($files.Count) file(s) deleted." -ForegroundColor Green
                        break
                    }
                    catch {
                        Write-Host "Failed to delete the files. Aborting.." -ForegroundColor Red
                        Write-Host "Error details: $_" -ForegroundColor Red
                    }
                }
                elseif ($deleteConfirmation.ToLower() -in @("list", "l")) {
                    Write-Host "Listing all files in the directory:"
                    $files | ForEach-Object { Write-Host "-  $($_.Name) (Size: $(ConvertTo-HumanReadable $_.Length))" }
                }
                elseif ($deleteConfirmation.ToLower() -in @("no", "n")) {
                    break
                }
            } while ($true)
        }

        Show-Choices
        do {
            Write-Host "Please select an option" -ForegroundColor Yellow
            $choice = Read-Host
            switch ($choice.ToLower()) {
                { $_ -in @("e", "exit", "ex") } { exit }
                { $_ -in @("?", "help") } { Show-Choices }
                { $_ -in @("v", "view") } { 
                    Write-Host "Opening the folder in File Explorer.."
                    Start-Process explorer.exe -ArgumentList $hooksDirectory.FullName 
                }
                { $_ -in @("a", "all") } {
                    foreach ($str in @("pre-commit", "commit-msg")) {
                        $url = "$($baseUri)/$($str)"
                        Invoke-WebRequest -Uri $url -OutFile "$($hooksDirectory.FullName)\$($str)"
                        Write-Host "Successfully downloaded [$str] hook.."
                    }
                    break
                }
                { $_ -in @("1", "pre-commit") } {
                    $url = "$($baseUri)/pre-commit"
                    Invoke-WebRequest -Uri $url -OutFile "$($hooksDirectory.FullName)\pre-commit"
                    Write-Host "Successfully downloaded [pre-commit] hook.."
                    break
                }
                { $_ -in @("2", "commit-msg") } {
                    $url = "$($baseUri)/commit-msg"
                    Invoke-WebRequest -Uri $url -OutFile "$($hooksDirectory.FullName)\commit-msg"
                    Write-Host "Successfully downloaded [commit-msg] hook.."
                    break
                }
                default {
                    Write-Host "Invalid selection. Please try again.." -ForegroundColor Red
                }
            }
        } while ($true)
    }
    else {
        Write-Host "Aborting.." -ForegroundColor Red
    }
}
else {
    Write-Host "[$($lookForDirName)] directory not found in the current directory." -ForegroundColor Red
    Write-Host "Change the path and try again.." -ForegroundColor Red
}