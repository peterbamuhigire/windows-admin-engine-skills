function Write-WseEvidencePack {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]$OperationResult,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$EvidenceRoot
    )

    process {
        $safeId = [regex]::Replace([string]$OperationResult.OperationId, '[^a-zA-Z0-9._-]', '_')
        $root = [System.IO.Path]::GetFullPath($EvidenceRoot)
        $operationPath = Join-Path $root $safeId
        if (-not $PSCmdlet.ShouldProcess($operationPath, 'Write redacted evidence pack')) { return $null }

        New-Item -ItemType Directory -Path $operationPath -Force -ErrorAction Stop | Out-Null
        $resultPath = Join-Path $operationPath 'operation.json'
        $manifestPath = Join-Path $operationPath 'manifest.json'
        $safeResult = Protect-WseEvidenceValue -InputObject $OperationResult
        $safeResult | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $resultPath -Encoding UTF8 -ErrorAction Stop
        $hash = (Get-FileHash -LiteralPath $resultPath -Algorithm SHA256 -ErrorAction Stop).Hash.ToLowerInvariant()
        $verdict = 'PASS'
        if ($OperationResult.Status -eq 'Failed') { $verdict = 'FAIL' }
        elseif ($OperationResult.Status -in @('PartiallySucceeded','Aborted')) { $verdict = 'PARTIAL' }
        $manifest = [ordered]@{
            schema_version = '1.0'
            engine_version = '0.1.0'
            created_at = [datetime]::UtcNow.ToString('o')
            operation = [string]$OperationResult.OperationId
            files = @([ordered]@{ path = 'operation.json'; sha256 = $hash })
            limitations = @($OperationResult.Warnings)
            verdict = $verdict
        }
        $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8 -ErrorAction Stop
        return $operationPath
    }
}
