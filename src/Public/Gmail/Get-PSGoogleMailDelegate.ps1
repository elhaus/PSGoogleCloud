<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.delegates/list

#>
function Get-PSGoogleMailDelegate {
    [CmdletBinding()]
    param(
        [string]$UserId = "me"
    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/delegates" -f $UserId

    try {

        $Response = Invoke-GoogleRequest `
            -Uri $Uri `
            -Method Get

        $Response.delegates

    }
    catch {
        $errorDetails = $_.Exception.Message
        Write-Error "Error while loading delegates: $errorDetails"
    }

}