
function Convert-BQResponseToPSObject {
    param(
        [Parameter(Mandatory=$true)]
        $RawResponse
    )

    # in case the respsonse is empty
    if (-not $RawResponse.rows) {
        return @()
    }

    # extract column names
    $columns = $RawResponse.schema.fields.name

    # transform rows
    $results = foreach ($row in $RawResponse.rows) {
        $obj = [ordered]@{}

        for ($i = 0; $i -lt $columns.Count; $i++) {
            # Google is nesting the values in the 'v' property
            $value = $row.f[$i].v

            $obj[$columns[$i]] = $value
        }

        [PSCustomObject]$obj
    }

    return $results
}