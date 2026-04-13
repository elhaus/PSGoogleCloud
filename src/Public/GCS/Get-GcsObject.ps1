<#
.LINK
https://docs.cloud.google.com/storage/docs/json_api/v1/objects/insert
#>
function Get-GcsObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Bucket,

        [Parameter(Mandatory = $true)]
        [string]$ObjectName
    )

    $Uri = "https://storage.googleapis.com/storage/v1/b/{0}/o/{1}" -f $Bucket, ([uri]::EscapeDataString($ObjectName))

    Write-Verbose "Uri: $($Uri)"

    Invoke-GoogleRequest -Uri $Uri `
                        -Method Get

}