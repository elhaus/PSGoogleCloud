<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.sendAs/list
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.sendAs/get

GET https://gmail.googleapis.com/gmail/v1/users/{userId}/settings/sendAs/{sendAsEmail}



#>
function Get-PSGoogleMailSendAs {
    [CmdletBinding()]
    param(
        [string]$UserId = "me",

        [mailaddress]$SendAsEmail
    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/sendAs" -f $UserId
    
    if($SendAsEmail) {
        $Uri = "{0}/{1}" -f $Uri,$SendAsEmail.Address
    }

    $Attributes = @(
            "sendAsEmail",
            "displayName",
            "replyToAddress",
            "signature",
            "isPrimary",
            "isDefault",
            "treatAsAlias",
            "smtpMsa",
            "verificationStatus"
        )

    try {

        $Response = Invoke-GoogleRequest `
            -Uri $Uri `
            -Method Get

        if($SendAsEmail) {
            $Response | Select-Object $Attributes
        } else {
            $Response.sendAs | Select-Object $Attributes
        }

    }
    catch {
        $errorDetails = $_.Exception.Message
        Write-Error "Error while loading send as info: $errorDetails"
    }


}