<#
.SYNOPSIS
    Authenticate against the Google API

.DESCRIPTION

.EXAMPLE

.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/identity/protocols/oauth2/service-account
#>
function Connect-PSGoogleCloud {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory,ParameterSetName='json_path')]
        [string]$Path,

        [Parameter(Mandatory,ParameterSetName='json_content')]
        [string]$Content,

        [Parameter(Mandatory,ParameterSetName='json_path')]
        [Parameter(Mandatory,ParameterSetName='json_content')]
        [string[]]$Scope,

        [Parameter(ParameterSetName='json_path')]
        [Parameter(ParameterSetName='json_content')]
        [string]$ImpersonationUser,

        [Parameter(ParameterSetName='json_path')]
        [Parameter(ParameterSetName='json_content')]
        [ValidateRange(1,3600)]
        [int]$SessionDuration = 3600
    )

    $RSA = $null
    try {
        if ($Path) {
            Write-Verbose "Use Json file"
            $js = Get-Content $Path | ConvertFrom-Json
        }
        else {
            Write-Verbose "Use Json content"
            $js = $Content | ConvertFrom-Json
        }
        ($js.client_email -and $js.private_key -and $js.private_key_id) -or $(throw 'invalid json format') | Out-Null
        $ServiceAccountMail = $js.client_email
        $KeyId = $js.private_key_id
        $Content = $js.private_key
        $Uri = $js.token_uri
        $Audience = $js.token_uri
    }
    catch
    {
        Write-Error $_.Exception
        return $false
    }

    try {
        # json/p8 use $Content
        if (-not $RSA) {
            Write-Verbose "Aquire private key"
            $PrivateKey = [convert]::FromBase64String(($Content -replace "-{5}(BEGIN|END) (RSA )?PRIVATE KEY-{5}") -join "`n")
            if ($PSVersionTable.PSVersion.Major -lt 7) {
                # PowerShell 5
                $RSA = Import5AsRSA -private_bytes $PrivateKey
            } else {
                # PowerShell 7
                $RSA = Import7AsRSA -private_bytes $PrivateKey
            }
        }
    } catch {
        Write-Error $_.Exception
        return $false
    }

    $Tokenparams = @{
        Issuer = $ServiceAccountMail
        RSA = $RSA
        KeyId = $KeyId
        ImpersonationUser = $ImpersonationUser
        ExpirationSec = $SessionDuration
        Scope = ($Scope -join " ")
        Audience = $Audience
    }
    $Token = NewJWTToken @Tokenparams
    $Body = @{
        grant_type = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
        assertion = $Token
    }

    Write-Verbose (($Body | Out-String) -replace "`r`n")

    $AccessToken = Invoke-RestMethod -Method Post -Uri $Uri -Body $Body -ContentType "application/x-www-form-urlencoded"

    if($AccessToken.access_token) {
        $Script:AccessToken = $AccessToken.access_token
        $Script:TokenExpiry = (Get-Date).AddSeconds($SessionDuration)
        $Script:TokenScope  = $Scope
        if($ImpersonationUser) {
            $Script:TokenUser = $ImpersonationUser
        } else {
            $Script:TokenUser = $ServiceAccountMail
        }
        return $true
    } else {
        return $false
    }


}