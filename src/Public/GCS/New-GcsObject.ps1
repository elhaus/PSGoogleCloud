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

        [string]$contentType = "application/octet-stream",

        [string]$ObjectName
    )

    # If no object name is specified use the file name of the source file
    if ([string]::IsNullOrWhiteSpace($ObjectName)) {
        $ObjectName = Split-Path $File -Leaf
    }

    # check if source file is exsting
    if (-not (Test-Path $File)) {
        throw "The file $File could not be found"
    }

    # API endpoint for 'media' uploads
    $uri = "https://storage.googleapis.com/upload/storage/v1/b/$($Bucket)/o?uploadType=media&name=$([uri]::EscapeDataString($ObjectName))"

    # read file content as Byte-Array
    $fileBytes = [System.IO.File]::ReadAllBytes($File)

    if ($PSCmdlet.ShouldProcess("gs://$Bucket/$ObjectName", 'upload GCS object')) {

        try {
            Write-Verbose "Starting upload from $SourceFilePath to gs://$Bucket/$ObjectName"

            $response = Invoke-GoogleRequest -Uri $uri `
                                        -Method Post `
                                        -Headers @{
                                            "Content-Type"=$contentType
                                        }  `
                                        -Body $fileBytes `
                                        -ContentType $contentType

            Write-Verbose "Upload successfull! Object-ID: $($response.id)"
            return $response

        } catch {

            $errorDetails = $_.Exception.Message
            Write-Error "Error uploading to GCS: $errorDetails"

        }

    }

}