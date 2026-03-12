@{
    # Script module or binary module file associated with this manifest.
    RootModule          = 'PSGoogleCloud'

    # Version number of this module.
    ModuleVersion       = '0.1.0.0'

    # Unique ID of this module
    GUID                = '0461ff28-8d55-461e-8c97-7455fd0e99e1'

    # Author of this module
    Author              = 'Jan Elhaus'
    CompanyName         = ''
    Copyright           = '(c) 2026 Jan Elhaus. All rights reserved.'

    # Description of the functionality provided by this module
    Description         = 'Module for the interaction with Google Cloud Storage, BigQuery and Google Workspace APIs.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion   = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport   = @(
        'Connect-PSGoogleCloud',
        'Disconnect-PSGoogleCloud',
        'Get-PSGoogleAccessToken',
        'Invoke-GoogleRequest',

        'Invoke-BQQuery',

        'New-GcsObject',
        'Remove-GcsObject',

        'New-PSGoogleMailDelegate',
        'Remove-PSGoogleMailDelegate',
        'Get-PSGoogleMailDelegate',
        'New-PSGoogleMailSendAs',
        'Remove-PSGoogleMailSendAs',
        'Get-PSGoogleMailSendAs',
        'Set-PSGoogleMailSendAs',
        'Get-PSGoogleMailVacationSettings',
        'Set-PSGoogleMailVacationSettings'
    )

    # Cmdlets and Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport     = @()
    VariablesToExport   = @()
    AliasesToExport     = @()

    # required external modules
    RequiredModules     = @()

    # Private data (optional)
    PrivateData = @{
        PSData = @{
            Tags       = @('GoogleCloud', 'GCS', 'BigQuery', 'API', 'REST', 'Google', 'GWS', 'Google', 'Workspace')
            ProjectUri = 'https://github.com/elhaus/PSGoogleCloud'
            LicenseUri = 'https://opensource.org/licenses/MIT'
        }
    }
}