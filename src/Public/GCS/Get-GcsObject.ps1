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
        [string]$ObjectName,

        [string]$OutFile
    )

    $Uri = "https://storage.googleapis.com/storage/v1/b/{0}/o/{1}" -f $Bucket, ([uri]::EscapeDataString($ObjectName))

    if($PSBoundParameters.ContainsKey('OutFile')) {
        $Uri += "?alt=media"
    }

    Write-Verbose "Uri: $($Uri)"

    $Response = Invoke-GoogleRequest -Uri $Uri `
                                        -Method Get

    $Response

}