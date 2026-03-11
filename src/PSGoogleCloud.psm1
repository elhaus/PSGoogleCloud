
Try {
    Get-ChildItem "$PSScriptRoot\Private\*.ps1" | ForEach-Object {
        . $_.FullName
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}

Try {
    Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}
