<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.sendAs/create

#>
function New-PSGoogleMailSendAs {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'New-PSGoogleMailSendAs')]
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$UserId = "me",

        [Parameter(Mandatory)]
        [mailaddress]$SendAsEmail,

        [string]$DisplayName,

        [mailaddress]$ReplyToAddress,

        [string]$Signature,

        [switch]$IsDefault,

        [bool]$TreatAsAlias = $true
    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/sendAs" -f $UserId

    $Body = @{
        sendAsEmail=$SendAsEmail.Address
        displayName=$DisplayName
        treatAsAlias=$TreatAsAlias
        isDefault=$IsDefault.IsPresent
    }

    if($ReplyToAddress) {
        $Body.Add('replyToAddress', $ReplyToAddress.Address)
    }
    if($Signature) {
        $Body.Add('signature', $Signature)
    }


    $Body = ConvertTo-Json -InputObject $Body -Compress

    Write-Verbose "Request Body $Body"

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

    if ($PSCmdlet.ShouldProcess($SendAsEmail.Address, 'add send as address')) {

        try {

            Invoke-GoogleRequest `
                    -Uri $Uri `
                    -Body $Body `
                    -Method Post |
                Select-Object $Attributes

        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-Error "Error while adding send as info: $errorDetails"
        }

    }

}