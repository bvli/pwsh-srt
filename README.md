# Powershell tools for manipulating subtitle files (.srt)

This module contains a few methods for easy manipulation of subtitle text files.

## Manual installation

 Clone this repository and import the module.

 ```powershell
PS> git clone 'https://git.beverli.net/bvli/pwsh-srt'
PS> Import-Module './pwsh-srt'
 ```

## Examples of usage

### Add an offset to all entries in file

This is probaly the most needed capability of the toolset. We all know the situation where we're going to watch a movie, and then the subtitles appears 10 seconds before the dialog. This is exactly why this toolset was created. So find the offset by timing the difference between when the dialog appear and the subtitle appear by watching the movie and let's fix it. If you want the titles to appear ealier use a negative number, if you want them to appear later, use a positive number.

```powershell
PS> Get-Content -Path 'Pretty Woman (1990).en.srt' | 
    ConvertFrom-Srt | 
    Add-SrtTimeDifference -MilliSeconds -500 | 
    ConvertTo-Srt | 
    Out-File '.\Pretty Woman (1990).en.fixed.srt'
```

### Remove first subtitle entry

Sometimes the first few entries in a subtitle file contains ads or other information, you don't want to have in the file. It's quite easy to delete these, while still keeping the sequence in sync.

```powershell
PS> Get-Content -Path 'Pretty Woman (1990).en.srt' | 
    ConvertFrom-Srt | 
    Select-Object -Skip 1 | 
    ConvertTo-Srt |
    Out-File -Path 'Pretty Woman (1990).en.no-ads.srt'
```

### Insert a subtitle entry

If you want to be one of the annoying persons, adding entries to a subtitle file (you don't!) then it's quite easy as well:

```powershell
PS> @('0', '00:00:00,000 --> 00:00:02,000', 'Manipulated by pwsh-srt', '© bvli, 2021', '') + (cat '.\Pretty Woman (1990).en.srt') | 
    ConvertFrom-Srt | 
    ConvertTo-Srt | 
    Out-File -Path '.\Pretty Woman (1990).en.ads.srt'
```

The sequence number of the inserted entry is not important here, as the `ConvertTo-Srt` cmdlet will handle the sequencing when converting back to the srt file format.

### Automate it

Of course you can mix and match as you'd like - and probably do it all in a one-liner of you prefer. Just remember to take file encodings into consideration when working with subtitles with special characters. (So please **backup your original file** before trying to manipulate it in a single go)

```powershell
    $FileName = 'Pretty Woman (1990).en.srt'
    (Get-Content -Path $FileName | 
        ConvertFrom-Srt | 
        Select-Object -Skip 1 |
        Add-SrtTimeDifference -Seconds 15
        ConvertTo-Srt) | 
    Out-File -Path $FileName
```
