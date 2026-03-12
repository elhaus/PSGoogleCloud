<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings/getVacation

#>
function Get-PSGoogleMailVacationSetting {
    [CmdletBinding()]
    param(
        [string]$UserId = "me"
    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/vacation" -f $UserId

    try {

        Invoke-GoogleRequest `
                -Uri $Uri `
                -Method Get |
            Select-Object `
                enableAutoReply,
                responseSubject,
                responseBodyPlainText,
                responseBodyHtml,
                restrictToContacts,
                restrictToDomain,
                @{n="startTime";e={([System.DateTimeOffset]::FromUnixTimeMilliseconds($_.startTime)).DateTime}},
                @{n="endTime";e={([System.DateTimeOffset]::FromUnixTimeMilliseconds($_.endTime)).DateTime}}

    }
    catch {
        $errorDetails = $_.Exception.Message
        Write-Error "Error while loading vacation setting: $errorDetails"
    }


}