[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][AllowEmptyString()][String] $sourceDir,
  [Parameter(Mandatory=$true)][AllowEmptyString()][String] $targetDir
)

If ([string]::IsNullOrEmpty($sourceDir) -or !(Test-Path $sourceDir) -or [string]::IsNullOrEmpty($targetDir) -or!(Test-Path $targetDir)){
    Write-Warning "Invalid source or target directory"
    Exit
}

Write-Output "Scanning folders..."

$dirs = Get-ChildItem $sourceDir -Directory

Write-Output "Moving files..."

foreach($dir in $dirs) {
    $files = Get-ChildItem $dir.FullName -File

    foreach($file in $files) {
        $newFolderPath = Join-Path -Path $targetDir -ChildPath $file.Extension
        $newFilePath = Join-Path -Path $newFolderPath -ChildPath "$($file.BaseName)$($file.Extension)"

        if(!(Test-Path -Path $newFolderPath ))
        {
            new-item -ItemType Directory -Path $newFolderPath | Out-Null
        }

        $trigger = $false
        $counter = 1

        Do {
            If (!(Test-Path -Path $newFilePath)) {
                $trigger = $true
            } Else {
                $newFilePath = Join-Path -Path $newFolderPath -ChildPath "$($file.BaseName + $counter)$($file.Extension)"
                $counter++
            }

        } Until ($trigger)
      

        Copy-Item -Path $file.FullName -Destination $newFilePath
    }

    Write-Output "Progress: $($dirs.IndexOf($dir) + 1)/$($dirs.Count)"
}