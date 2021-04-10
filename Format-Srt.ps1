function Format-Srt {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,  ValueFromPipeline = $true)]
        [string[]] $entries
    )
    
    begin {
        Set-StrictMode -Version Latest
        $current = $null
    }
    
    process {
        foreach ($entry in $entries) {
             if ($entry -match "^\d+$"){
                 $current
                 $current = @{}
                $current.Sequence = [int]$entry
                $current.Text = ""
              } elseif ( $entry -match "(\d{2}:\d{2}:\d{2},\d{3})\s-->\s(\d{2}:\d{2}:\d{2},\d{3})"){
                 $current.From = [timespan]::ParseExact($Matches[1],"hh\:mm\:ss\,fff", [cultureinfo]::InvariantCulture)
                 $current.To = [timespan]::ParseExact($Matches[2],"hh\:mm\:ss\,fff", [cultureinfo]::InvariantCulture)
             } elseif ($entry) {
                $current.Text += "$entry`n"
             }
        }
    }
    
    end {
        $current
    }
}

Get-Content '.\Hamburger Hill (1987).da.srt' | Format-Srt | select -first 1  | % Text

