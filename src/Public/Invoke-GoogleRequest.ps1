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

        [switch]$useLegacySql,

        [String]$AccessToken
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

    Write-Verbose "Webrequest $($PSBoundParameters | ConvertTo-Json -Compress)"

    Invoke-RestMethod @PSBoundParameters -Headers $Headers

}