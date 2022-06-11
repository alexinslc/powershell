function ConvertTo-MacAddress() {
    param (
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        $patterns = @(
        '^([0-9a-f]{2}:){5}([0-9a-f]{2})$'
        '^([0-9a-f]{2}-){5}([0-9a-f]{2})$'
        '^([0-9a-f]{4}.){2}([0-9a-f]{4})$'
        '^([0-9a-f]{12})$'
        )
        if ($_ -match ($patterns -join '|')) {$true} else { throw "The argument '$_' does not match a valid MAC address format." }
    })]
    [string]$MacAddress,
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateSet(':', '-', '.', $null)]
    [string]$Delimiter = '-'
    )

    process {

        $rawAddress = $MacAddress -replace '\W'

        switch ($Delimiter) {
            {$_ -match ':|-'} {
            
            for ($i = 2 ; $i -le 14 ; $i += 3) {
            $result = $rawAddress = $rawAddress.Insert($i, $_)
            }
            break
            }

            '.' {
            
            for ($i = 4 ; $i -le 9 ; $i += 5) {$result = $rawAddress = $rawAddress.Insert($i, $_)
            }
            break
            }

            default {
            $result = $rawAddress
            }
        } 
        $result
    }
}