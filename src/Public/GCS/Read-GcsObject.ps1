<#
.LINK
https://docs.cloud.google.com/storage/docs/json_api/v1/objects/insert
#>
function Read-GcsObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Bucket,

        [Parameter(Mandatory = $true)]
        [string]$ObjectName,

        [Parameter(Mandatory = $true)]
        [string]$OutFile,

        [int]$ChunkSize,

        [switch]$Force
    )

    $Uri = "https://storage.googleapis.com/storage/v1/b/{0}/o/{1}?alt=media" -f $Bucket, ([uri]::EscapeDataString($ObjectName))

    Write-Verbose "Uri: $($Uri)"

    if($PSBoundParameters.ContainsKey('Signature')) {
        $Body.Add('signature', $Signature)
    }

    if($OutFile -and -not $Force.IsPresent -and (Test-Path -Path $OutFile)) {
        throw "file already exsiting"
    }
    
    if (-not $PSBoundParameters.ContainsKey('ChunkSize')) {
        
        Write-Verbose "Downloading in one step..."

        #$FileStream = [System.IO.File]::Open($OutFile, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write)
        $FileStream = [System.IO.File]::Create($OutFile)

        try {

            $Response = Invoke-GoogleRequest `
                -AsWebRequest `
                -Uri $Uri `
                -Method Get
            
            $Response.RawContentStream.CopyTo($FileStream)
            
        }
        finally {
            $FileStream.Close()
        }

    } else {

        Write-Verbose "Downloading in chunks of $ChunkSize bytes..."

        if($PSVersionTable.PSVersion.Major -lt 7) {
            throw "downloading data in chunks is not implmented for this PowerShell version (please use PowerShell 7 or higher)"    
        }

        $GcsObject = Get-GcsObject -Bucket $Bucket -ObjectName $ObjectName
        $TotalSize = $GcsObject.size

        #$FileStream = [System.IO.File]::Open($OutFile, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write)
        $FileStream = [System.IO.File]::Create($OutFile)

        $Start = 0

        try {

            while ($Start -lt $TotalSize) {

                $End = [Math]::Min($Start + $ChunkSize - 1, $TotalSize - 1)
                $RangeHeader = "bytes=$Start-$End"
                $Headers = @{"Range"=$RangeHeader}

                Write-Verbose "Downloading range: $RangeHeader"

                # Chunked download with header for Range
                $Response = Invoke-GoogleRequest `
                    -AsWebRequest `
                    -Uri $Uri `
                    -Method Get `
                    -Headers $Headers

                # check, if content is empty
                if ($Response.Content.Length -eq 0) {
                    Write-Warning "The requested section is empty or invalid: $RangeHeader"
                } else {
                    # writing to file
                    $Response.RawContentStream.CopyTo($FileStream)
                }

                $Start = $End + 1
            }

        }
        finally {
            $FileStream.Close()
        }

        Write-Verbose "Download complete: $OutFile"

    }

}