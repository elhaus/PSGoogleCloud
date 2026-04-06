<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK

#>

function Invoke-GoogleRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Uri]$Uri,

        [Parameter(Mandatory)]
        [ValidateSet('Delete','Get','Patch','Post','Put')]
        [String]$Method,

        [Object]$Body,

        [String]$ContentType = "application/json",

        [hashtable]$Headers = @{
            "Content-Type" = "application/json"
        },

        [String]$AccessToken,

        [switch]$AsWebRequest
    )

    if(-not $Headers.Authorization -and $AccessToken) {
        $Headers.Add("Authorization", "Bearer $AccessToken")
    }
    if(-not $Headers.Authorization -and $Script:AccessToken -and $Script:TokenExpiry -gt (Get-Date)) {
        $Headers.Add("Authorization", "Bearer $($Script:AccessToken)")
    }

    if(-not $Headers.Authorization) {
        throw "no access token"
    }

    $PSBoundParameters.Remove('Headers') | Out-Null
    $PSBoundParameters.Remove('AccessToken') | Out-Null
    $PSBoundParameters.Remove('AsWebRequest') | Out-Null

    Write-Verbose "Webrequest $($PSBoundParameters | ConvertTo-Json -Compress)"

    if($AsWebRequest) {
        Invoke-WebRequest @PSBoundParameters -Headers $Headers
    } else {
        Invoke-RestMethod @PSBoundParameters -Headers $Headers
    }

}