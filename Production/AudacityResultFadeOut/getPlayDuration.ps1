# Path to output file
$outputFile = "mp3_durations.tsv"

# Write the header line to the output file
"Filename`tDuration_seconds`tFFmpeg_Error" | Out-File -FilePath $outputFile -Encoding utf8

# Get all MP3 files in the current directory
$mp3Files = Get-ChildItem -Path . -Filter "*.mp3"

foreach ($file in $mp3Files) {
    Write-Host "Processing '$($file.Name)'..."

    try {
        # Run FFmpeg command using Start-Process for more control
        $ffmpegCommand = "ffmpeg"
        $ffmpegArgs = "-i `"$($file.FullName)`" -f null -"

        # Capture both stdout and stderr using Start-Process
        $ffmpegOutput = Start-Process -FilePath $ffmpegCommand -ArgumentList $ffmpegArgs -PassThru -Wait -RedirectStandardOutput "ffmpeg_output.txt" -RedirectStandardError "ffmpeg_error.txt"

        # Read the FFmpeg error output
        $errorOutput = Get-Content "ffmpeg_error.txt" | Out-String

        # Check if there's an actual error in the error output
        if ($errorOutput) {
            # Log the error message and skip this file
            Write-Host "FFmpeg Error: $errorOutput"
            "$($file.Name)`tERROR (FFmpeg Error)`t$errorOutput" | Out-File -FilePath $outputFile -Append -Encoding utf8
            continue
        }

        # Look for the line that contains the Duration information in the output
        $durationLine = Get-Content "ffmpeg_output.txt" | Select-String -Pattern "Duration"

        if ($durationLine) {
            # Extract the duration part of the line
            $durationString = $durationLine.Line -replace "Duration: ", "" -replace ",.*", ""

            # Split the duration into hours, minutes, and seconds
            $durationParts = $durationString.Split(":")
            
            # Handle the case where the duration is less than an hour (HH:MM:SS.ss format)
            if ($durationParts.Length -eq 3) {
                $hours = [int]$durationParts[0]
                $minutes = [int]$durationParts[1]
                $seconds = [float]$durationParts[2]
            } else {
                # In case of unexpected format, handle as minutes and seconds
                $minutes = [int]$durationParts[0]
                $seconds = [float]$durationParts[1]
                $hours = 0
            }

            # Calculate total seconds
            $totalSeconds = ($hours * 3600) + ($minutes * 60) + $seconds

            # Write the result to the output file
            "$($file.Name)`t$totalSeconds`t" | Out-File -FilePath $outputFile -Append -Encoding utf8
        } else {
            # If no duration found, log the full FFmpeg output for debugging
            Write-Host "Error: No duration found for '$($file.Name)'"
            $ffmpegOutput = Get-Content "ffmpeg_output.txt" | Out-String
            "$($file.Name)`tERROR (No duration found)`t$($ffmpegOutput)" | Out-File -FilePath $outputFile -Append -Encoding utf8
        }
    } catch {
        # Log any other errors
        Write-Host "Error processing '$($file.Name)': $_"
        "$($file.Name)`tERROR (Processing failed)`t$($_)" | Out-File -FilePath $outputFile -Append -Encoding utf8
    }
}

Write-Host "Done! The durations are saved in '$outputFile'."
