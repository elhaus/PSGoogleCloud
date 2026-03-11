<#
.LINK
https://docs.cloud.google.com/storage/docs/json_api/v1/objects/delete

#>
function Remove-GcsObject {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Bucket,
        
        [Parameter(Mandatory = $true)]
        [string]$ObjectName
    )

    # API Endpunkt für 'media' Uploads (Beachte das /upload/ Präfix in der URL)
    $uri = "https://storage.googleapis.com/storage/v1/b/{0}/o/{1}" -f $Bucket,([uri]::EscapeDataString($ObjectName))

    if ($PSCmdlet.ShouldProcess("gs://$Bucket/$ObjectName", 'delete GCS object')) {

        try {
            Write-Verbose "Starting deletion of gs://$Bucket/$ObjectName"
            
            Invoke-GoogleRequest -Uri $uri `
                                        -Method Delete | Out-Null

            Write-Verbose "Deletion successfull!"
            return $true
        }
        catch {
            $errorDetails = $_.Exception.Message
            Write-Error "Error while deleting on GCS: $errorDetails"
        }

    }

}