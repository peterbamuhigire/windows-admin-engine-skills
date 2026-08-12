function Protect-WseEvidenceValue {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)]$InputObject)

    process {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [string]) {
            $value = $InputObject
            $value = $value -replace '(?i)(password|passwd|pwd|token|secret|recoverykey|privatekey)\s*[:=]\s*[^\s;,]+', '$1=[REDACTED]'
            return $value
        }

        if ($InputObject -is [System.Collections.IDictionary]) {
            $copy = [ordered]@{}
            foreach ($key in $InputObject.Keys) {
                if ([string]$key -match '(?i)password|passwd|pwd|token|secret|recovery.?key|private.?key|credential') {
                    $copy[$key] = '[REDACTED]'
                } else {
                    $copy[$key] = Protect-WseEvidenceValue -InputObject $InputObject[$key]
                }
            }
            return [pscustomobject]$copy
        }

        if ($InputObject -is [System.Collections.IEnumerable] -and -not ($InputObject -is [string])) {
            $items = @()
            foreach ($item in $InputObject) { $items += ,(Protect-WseEvidenceValue -InputObject $item) }
            return $items
        }

        if ($InputObject -is [psobject] -and @($InputObject.PSObject.Properties).Count -gt 0) {
            $copy = [ordered]@{}
            foreach ($property in $InputObject.PSObject.Properties) {
                if ($property.Name -match '(?i)password|passwd|pwd|token|secret|recovery.?key|private.?key|credential') {
                    $copy[$property.Name] = '[REDACTED]'
                } else {
                    $copy[$property.Name] = Protect-WseEvidenceValue -InputObject $property.Value
                }
            }
            return [pscustomobject]$copy
        }

        return $InputObject
    }
}
