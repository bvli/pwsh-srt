function ConvertFrom-Srt {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]] $entries
    )
    
    begin {
        Set-StrictMode -Version Latest
        $current = $null
    }
    
    process {
        foreach ($entry in $entries) {
            if ($entry -match "^\d+$") {
                $current
                $current = [PSCustomObject]@{}
                $current | Add-Member -MemberType NoteProperty -Name 'Sequence' -Value ([int]$entry)
                $current | Add-Member -MemberType NoteProperty -Name 'Text' -Value ""
            }
            elseif ( $entry -match "(\d{2}:\d{2}:\d{2},\d{3})\s-->\s(\d{2}:\d{2}:\d{2},\d{3})") {
                $current | Add-Member -MemberType NoteProperty -Name 'From' -Value ([timespan]::ParseExact($Matches[1], "hh\:mm\:ss\,fff", [cultureinfo]::InvariantCulture))
                $current | Add-Member -MemberType NoteProperty -Name 'To' -Value  ([timespan]::ParseExact($Matches[2], "hh\:mm\:ss\,fff", [cultureinfo]::InvariantCulture))
            }
            elseif ($entry) {
                $current.Text += "$entry`n"
            }
        }
    }
    
    end {
        $current
    }
}

function Add-SrtTimeDifference {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [PSCustomObject[]] $entries,
        [Parameter(Mandatory = $true, ParameterSetName = 'Seconds')]
        [int] $Seconds,
        [Parameter(Mandatory = $true, ParameterSetName = 'MilliSeconds')]
        [int] $MilliSeconds
    )
    
    begin {
        Set-StrictMode -Version Latest
        if ($Seconds) {
            $difference = [timespan]::FromSeconds($Seconds);
        }
        if ($MilliSeconds) {
            $difference = [timespan]::FromMilliseconds($MilliSeconds);
        }
    }

    process {
        foreach ($entry in $entries) {
            $entry | Add-Member -MemberType NoteProperty -Name 'Difference' -Value $difference
            $entry.From = $entry.From.Add($difference)
            $entry.To = $entry.To.Add($difference)
            $entry
        }
    }
}

function ConvertTo-Srt {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [PSCustomObject[]] $entries
    )

    begin {
        Set-StrictMode -Version Latest
        $format = 'hh\:mm\:ss\,fff'
        $sequence = [int]0
    }
    
    process {
        foreach ($entry in $entries) {
            $sequence += 1
            $sequence
            "$($entry.From.ToString($format, [cultureinfo]::InvariantCulture)) --> $($entry.To.ToString($format, [cultureinfo]::InvariantCulture))"
            $entry.Text.TrimEnd()
            ""
        }
    }
}

Get-Content '.\content\Hamburger Hill (1987).en.srt' | ConvertFrom-Srt | Add-SrtTimeDifference -Seconds 30 | ConvertTo-Srt 