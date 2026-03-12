<#
.LINK
https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.settings.delegates/delete

#>
function Remove-PSGoogleMailDelegate {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)]
        [mailaddress]$Delegate,

        [string]$UserId = "me"
    )

    $Uri = "https://gmail.googleapis.com/gmail/v1/users/{0}/settings/delegates/{1}" -f $UserId,$Delegate.Address

    if ($PSCmdlet.ShouldProcess($Delegate.Address, 'remove delegation')) {

        try {

            Invoke-GoogleRequest `
                -Uri $Uri `
                -Method Delete | Out-Null
            return $true

        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-Error "Error while removing delegate: $errorDetails"
        }

    }


}