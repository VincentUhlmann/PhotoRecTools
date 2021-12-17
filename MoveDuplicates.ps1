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
    $duplicates = Get-ChildItem $dir.FullName -File -ErrorAction SilentlyContinue | Get-FileHash | Group-Object -Property Hash | Where-Object Count -GT 1

    foreach($duplicate in $duplicates)
    {
        foreach($duplicatePath in ($duplicate.Group.Path | Select-Object -Skip 1))
        {
            $targetFolder = Join-Path $targetDir $dir.Name
                
            if(!(Test-Path -Path $targetFolder ))
            {
                new-item -ItemType Directory -Path $targetFolder | Out-Null
            } 

            Move-Item -Path $duplicatePath -Destination $targetFolder
        }
    }

    Write-Output "Progress: $($dirs.IndexOf($dir) + 1)/$($dirs.Count)"
}