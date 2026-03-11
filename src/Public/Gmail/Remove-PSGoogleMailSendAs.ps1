<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.sendAs/delete

#>
function Remove-PSGoogleMailSendAs {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)]
        [mailaddress]$SendAsEmail,
        
        [string]$UserId = "me"
    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/sendAs/{1}" -f $UserId,$SendAsEmail.Address

    if ($PSCmdlet.ShouldProcess($SendAsEmail.Address, 'remove send as address')) {

        try {

            Invoke-GoogleRequest `
                -Uri $Uri `
                -Method Delete | Out-Null
            return $true

        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-Error "Error while removing send as: $errorDetails"
        }

    }


}