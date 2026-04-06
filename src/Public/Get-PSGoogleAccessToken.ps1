<#
.SYNOPSIS
    Retrieves the current authentication context for the Google API session.

.DESCRIPTION
    This function returns a hashtable containing the active OAuth2 Access Token,
    the authenticated user identity, the token's expiration timestamp, and
    the authorized scopes. It pulls these values from the internal module-scoped
    variables set during the 'Connect-PSGoogleCloud' process.

.EXAMPLE
    PS> $session = Get-PSGoogleAccessToken
    PS> Write-Host "Token expires at: $($session.TokenExpiry)"

    Retrieves the current session details and displays the expiration time.

.OUTPUTS
    System.Collections.Hashtable
    A hashtable containing the keys: AccessToken, User, TokenExpiry, and Scope.

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/identity/protocols/oauth2/service-account
#>
function Get-PSGoogleAccessToken {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
    )

    return @{
        AccessToken = $Script:AccessToken
        User        = $Script:TokenUser
        TokenExpiry = $Script:TokenExpiry
        Scope       = $Script:TokenScope
    }

}