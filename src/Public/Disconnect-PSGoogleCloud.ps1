<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK

#>
function Disconnect-PSGoogleCloud {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    $Script:AccessToken = $null
    $Script:TokenExpiry = $null
    $Script:TokenScope  = $null
    $Script:TokenUser   = $null

    return $true

}