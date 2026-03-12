<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.sendAs/create



#>
function Set-PSGoogleMailSendAs {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Set-PSGoogleMailSendAs')]
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$UserId = "me",

        [Parameter(Mandatory)]
        [mailaddress]$SendAsEmail,

        [string]$DisplayName,

        [mailaddress]$ReplyToAddress,

        [string]$Signature,

        [switch]$IsDefault
    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/sendAs/{1}" -f $UserId,$SendAsEmail.Address

    $Body = @{}

    if($PSBoundParameters.ContainsKey('DisplayName')) {
        $Body.Add('displayName', $DisplayName)
    }
    if($PSBoundParameters.ContainsKey('ReplyToAddress')) {
        $Body.Add('replyToAddress', $ReplyToAddress.Address)
    }
    if($IsDefault.IsPresent) {
        $Body.Add('isDefault', $IsDefault.IsPresent)
    }
    if($PSBoundParameters.ContainsKey('Signature')) {
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

    if ($PSCmdlet.ShouldProcess($SendAsEmail.Address, 'change send as')) {

        try {

            Invoke-GoogleRequest `
                    -Uri $Uri `
                    -Body $Body `
                    -Method Patch |
                Select-Object $Attributes

        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-Error "Error while adding send as info: $errorDetails"
        }

    }


}