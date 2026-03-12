<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings/updateVacation

#>
function Set-PSGoogleMailVacationSetting {
    [CmdletBinding()]
    param(
        [string]$UserId = "me",

        [bool]$EnableAutoReply,

        [string]$ResponseSubject = "Automatic reply",

        [string]$ResponseBody,

        [switch]$AsHtml,

        [switch]$RestrictToContacts,

        [switch]$RestrictToDomain,

        [Alias('StartDate')]
        [DateTime]$StartTime,

        [Alias('EndDate')]
        [DateTime]$EndTime

    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/vacation" -f $UserId

    $Body = @{
        enableAutoReply=$EnableAutoReply
        responseSubject=$ResponseSubject
        restrictToContacts=$RestrictToContacts.IsPresent
        restrictToDomain=$RestrictToDomain.IsPresent
    }

    if($AsHtml.IsPresent) {
        $Body.Add('responseBodyHtml', $ResponseBody)
    } else {
        $Body.Add('responseBodyPlainText', $ResponseBody)
    }

    if($StartTime) {
        $Body.Add('startTime', ([DateTimeOffset]$StartTime).ToUnixTimeMilliseconds())
    }
    if($EndTime) {
        $Body.Add('endTime', ([DateTimeOffset]$EndTime).ToUnixTimeMilliseconds())
    }

    $Body = ConvertTo-Json -InputObject $Body -Compress

    Write-Verbose "Request Body $Body"

    try {

        Invoke-GoogleRequest `
                -Uri $Uri `
                -Body $Body `
                -Method Put |
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
        Write-Error "Error while setting vacation setting: $errorDetails"
    }

}