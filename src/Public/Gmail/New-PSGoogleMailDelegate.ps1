<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.delegates/create

#>
function New-PSGoogleMailDelegate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [mailaddress]$Delegate,

        [string]$UserId = "me"
    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/delegates" -f $UserId

    $Body = @{
            delegateEmail=$Delegate.Address
            verificationStatus="accepted"
        } | ConvertTo-Json -Compress

    try {

        Invoke-GoogleRequest `
            -Uri $Uri `
            -Method Post `
            -Body $Body

    }
    catch {
        $errorDetails = $_.Exception.Message
        Write-Error "Error while adding delegate: $errorDetails"
    }


}