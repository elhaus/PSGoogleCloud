<#
.SYNOPSIS
    
.DESCRIPTION
    
.EXAMPLE
    
.OUTPUTS
    
.NOTES
    Author: Jan Elhaus
.LINK
    https://docs.cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query
#>

function Invoke-BQQuery {
[CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Project,

        [Parameter(Mandatory)]
        [string]$Query,

        [Alias('MaxResults')]
        [int]$MaxRows = 1000,

        [switch]$useLegacySql,

        [ValidateRange(1,3600)]
        [int]$SessionDuration = 3600
    )

    $RestParmeters = @{
        Uri = "https://bigquery.googleapis.com/bigquery/v2/projects/$($Project)/queries"
        Method = "POST"
        Body = @{
            query = $Query
            maxResults = $MaxRows
            useLegacySql = $useLegacySql
        } | ConvertTo-Json -Compress
    }

    $data = Invoke-GoogleRequest @RestParmeters

    Convert-BQResponseToPSObject $data

}