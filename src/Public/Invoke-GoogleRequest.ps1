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
        [uri]$Uri,

        [Parameter(Mandatory)]
        [ValidateSet('Delete','Get','Patch','Post','Put')]
        [string]$Method,

        [object]$Body,

        [string]$ContentType = "application/json",

        [hashtable]$Headers = @{
            "Content-Type" = "application/json"
        },

        [string]$AccessToken,

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
        Invoke-WebRequest @PSBoundParameters -Headers $Headers -UseBasicParsing
    } else {
        Invoke-RestMethod @PSBoundParameters -Headers $Headers
    }

}