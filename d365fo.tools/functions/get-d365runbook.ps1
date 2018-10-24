﻿
<#
    .SYNOPSIS
        Get a Dynamics 365 Runbook
        
    .DESCRIPTION
        Get the full path and filename of a Dynamics 365 Runbook
        
    .PARAMETER Path
        Path to the folder containing the runbook files
        
        The default path is "InstallationRecord" which is normally located on the "C:\DynamicsAX\InstallationRecords"
        
    .PARAMETER Name
        Name of the runbook file that you are looking for
        
        The parameter accepts wildcards. E.g. -Name *hotfix-20181024*
        
    .PARAMETER Latest
        Switch to instruct the cmdlet to only get the latest runbook file, based on the last written attribute
        
    .EXAMPLE
        PS C:\> Get-D365Runbook -Latest
        
        This will get the latest runbook file from the default InstallationRecords directory on the machine.
        
    .EXAMPLE
        PS C:\> Get-D365Runbook -Latest | Invoke-D365RunbookAnalyzer
        
        This will find the latest runbook file and have it analyzed by the Invoke-D365RunbookAnalyzer cmdlet to output any error details.
        
    .EXAMPLE
        PS C:\> Get-D365Runbook -Latest | Invoke-D365RunbookAnalyzer | Out-File "C:\Temp\d365fo.tools\runbook-analyze-results.xml"
        
        This will find the latest runbook file and have it analyzed by the Invoke-D365RunbookAnalyzer cmdlet to output any error details.
        The output will be saved into the "C:\Temp\d365fo.tools\runbook-analyze-results.xml" file.
        
    .NOTES
        Author: Mötz Jensen (@Splaxi)
        
#>
function Get-D365Runbook {
    [CmdletBinding()]
    param (
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [string] $Path = $Script:InstallationRecordsDir,

        [string] $Name = "*",

        [switch] $Latest
    )

    begin {
        if (-not (Test-PathExists -Path $Path -Type Container )) { return }
    }
    
    process {
        if (Test-PSFFunctionInterrupt) { return }

        $files = Get-ChildItem -Path "$Path\*.xml" | Sort-Object -Descending { $_.Properties.LastModified }

        if ($Latest) {
            $obj = $files | Select-Object -First 1

            [PSCustomObject]@{
                File     = $obj.Fullname
                Filename = $obj.Name
            }
        }
        else {
            foreach ($obj in $files) {
                if ($obj.Name -NotLike $Name) { continue }

                [PSCustomObject]@{
                    File     = $obj.Fullname
                    Filename = $obj.Name
                }
            }
        }
    }
}