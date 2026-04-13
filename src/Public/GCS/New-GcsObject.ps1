<#
.LINK
https://docs.cloud.google.com/storage/docs/json_api/v1/objects/insert
#>
function New-GcsObject {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Bucket,

        [Parameter(Mandatory = $true)]
        [string]$File,

        [string]$ContentType = "application/octet-stream",

        [string]$ObjectName,

        [int]$ChunkSize = 30Mb,

        [hashtable]$Metadata,

        [switch]$Force,

        [int]$MaxAttempts = 5,

        [int]$SecoundsAfterAttempt = 5,

        [datetime]$CustomTime
    )

    # If no object name is specified use the file name of the source file
    if ([string]::IsNullOrWhiteSpace($ObjectName)) {
        $ObjectName = Split-Path $File -Leaf
    }

    if(($ChunkSize % 256KB) -ne 0) {
        throw "ChunkSize must be a multiple of 256KB"
    }

    # check if source file is exsting
    if (-not (Test-Path $File)) {
        throw "The file $File could not be found"
    }

    $FileInfo = Get-Item $File
    $FileSize = $FileInfo.Length

    Write-Verbose "File size: $($FileSize)"

    # API endpoint for 'resumable' uploads
    $Uri = "https://storage.googleapis.com/upload/storage/v1/b/{0}/o?uploadType=resumable&name={1}" -f $Bucket,[uri]::EscapeDataString($ObjectName)

    if(-not $Force.IsPresent) {
        $Uri += "&ifGenerationMatch=0"
    }

    Write-Verbose "Upload URI: $($Uri)"

    if ($PSCmdlet.ShouldProcess("gs://$Bucket/$ObjectName", 'upload GCS object')) {

        $Body = @{}

        if($Metadata) {
            $Body["metadata"] = $Metadata
        }
        if($CustomTime) {
            $Body["customTime"] = Get-Date $CustomTime -Format "yyyy-MM-dd HH:mm:ss.fff zzz"
        }

        $Body = ConvertTo-Json -InputObject $Body -Compress

        Write-Verbose "Body: $($Body)"

        $InitResponse = Invoke-GoogleRequest -AsWebRequest -Uri $Uri `
                                -Body $Body `
                                -Method Post `
                                -Headers @{
                                    "X-Upload-Content-Type"=$ContentType
                                    "X-Upload-Content-Length"=$FileSize
                                    "Content-Type"="application/json; charset=UTF-8"
                                } `
                                -ErrorAction Stop

        $SessionUri = [string] $InitResponse.Headers.Location
        Write-Verbose "Session Uri: $($SessionUri)"

        $FileStream = [System.IO.File]::OpenRead($File)

        try{

            [long]$CurrentByte = 0

            do {

                if($MaxAttempts -lt 0) {

                    Write-Verbose "Try to gracefully cancel the upload"
                    $CloseSession = Invoke-WebRequest -Uri $SessionUri -Method Delete -Headers @{ "Content-Length" = 0 }
                    Write-Verbose "Close Result: $(ConvertTo-Json $CloseSession -Compress)"
                    throw "Too many retrys"

                }

                $RemainingBytes = $FileSize - $CurrentByte
                $CurrentChunkSize = [System.Math]::Min($ChunkSize, $RemainingBytes)
                $ContentRangeHeader = "bytes {0}-{1}/{2}" -f $CurrentByte,($CurrentByte + $CurrentChunkSize - 1),$FileSize
                Write-Verbose "ContentRange Header: $($ContentRangeHeader)"

                Write-Progress -Activity "Uploading to GCS" -Status $ContentRangeHeader -PercentComplete ($CurrentByte/$FileSize*100)

                if($CurrentByte -ne $FileStream.Position) {
                    Write-Verbose "Correct position of FileStream from $($FileStream.Position) to $($CurrentByte)"
                    $FileStream.Seek($CurrentByte, [System.IO.SeekOrigin]::Begin) | Out-Null
                }
                $Buffer = New-Object byte[] $CurrentChunkSize
                [void]$FileStream.Read($Buffer, 0, $CurrentChunkSize)

                $UploadHeaders = @{
                    "Content-Range" = $ContentRangeHeader
                }

                try {
                    $Upload = Invoke-WebRequest -Uri $SessionUri -Method Put -Headers $UploadHeaders -Body $Buffer -SkipHttpErrorCheck
                } catch {
                    Write-Warning $_.Exception.Message
                    $MaxAttempts -= 1
                    Start-Sleep -Seconds $SecoundsAfterAttempt
                    continue
                }


                switch($Upload.StatusCode) {
                    308 { # Resume Incomplete
                        $RangeHeader = [string] $Upload.Headers.Range
                        Write-Verbose "Response Header Range: $($RangeHeader)"
                        if($RangeHeader -match '(\d+)$') {
                            $CurrentByte = ([long]$Matches[1]) + 1
                        } else {
                            Write-Warning "Range header missing or invalid. Retrying last byte."
                        }
                        Write-Verbose "Next Byte: $($CurrentByte)"
                    }
                    200 {} # OK
                    201 {} # created
                    default {
                        Write-Verbose "Try to gracefully cancel the upload"
                        $CloseSession = Invoke-WebRequest -Uri $SessionUri -Method Delete -Headers @{ "Content-Length" = 0 }
                        Write-Verbose "Close Result: $(ConvertTo-Json $CloseSession -Compress)"
                        throw "Unexpected Status Code: $($Upload.StatusCode): $((ConvertFrom-Json $Upload.Content).error.message)"
                    }
                }

            } until ($Upload.StatusCode -in 200, 201)

            ConvertFrom-Json $Upload.Content

        }
        finally {
            $FileStream.Close()
            Write-Progress -Activity "Uploading to GCS" -Completed
        }

    }

}