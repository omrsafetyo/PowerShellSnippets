[CmdletBinding()]
PARAM(
    [Parameter(Mandatory=$False)]
    [string[]]
    $Computername = $ENV:COMPUTERNAME,

    [Parameter(Mandatory=$False)]
    [System.Management.Automation.PSCredential]
    $Credential,

    [Parameter(Mandatory=$False)]
    [int]
    $MAXJOBS = 50
)
BEGIN {
    $ScriptBlock = {
        Function New-Runspace {
            [cmdletbinding()]
            param(
                [string]$BaseDir
                , [switch]$Recurse
            )
            $ScriptBlock = {
                Param(
                    $BaseDir
                    , [switch]$Recurse
                )
                begin{
                    Function Get-SpecificChildItem {
                        [CmdletBinding()]
                        Param(
                            [parameter(Mandatory=$true, ValueFromPipeline=$true)]
                            [string]
                            $Path,
                            [switch] $Recurse
                        )
                        begin {}
                        process {
                            if ( $Recurse ) {
                                Get-ChildItem $Path -Recurse -force -include *.jar -ErrorAction SilentlyContinue | ForEach-Object {
                                    if (select-string "JndiLookup.class" $_.FullName) {
                                        $_ | Select-Object -Property @{N="Computername";E={$ENV:COMPUTERNAME}}, Name, FullName
                                    }
                                }
                                
                            } # files
                            else {
                                Get-ChildItem (Join-Path $Path "*.jar") -force -ErrorAction SilentlyContinue | ForEach-Object {
                                    if (select-string "JndiLookup.class" $_.FullName) {
                                        $_ | Select-Object -Property @{N="Computername";E={$ENV:COMPUTERNAME}}, Name, FullName
                                    }
                                }
                            } # else 
                        }
                        end {}
                    } # Function Get-SpecificChildItem
                }
                process {
                    if ( $Recurse ) {
                        Get-SpecificChildItem -Path $BaseDir -Recurse
                    }
                    else {
                        Get-SpecificChildItem -Path $BaseDir
                    }
                }
            } # ScriptBlock
            $PowerShell = [PowerShell]::Create()
            $PowerShell.RunspacePool = $Global:RunspacePool
            # What to run in the thread
            [void]$PowerShell.AddScript($ScriptBlock)
            # Parameters
            [void]$PowerShell.AddParameter("BaseDir",$BaseDir)
            if ( $Recurse ) {
                [void]$PowerShell.AddParameter("Recurse",$True)
            }
            
            # Save a reference to the thread, with meta data
            [void]$Global:JobThreads.Add((
                New-Object -Type PSCustomObject -Property @{
                    PowerShell  = $PowerShell
                    AsyncResult = $PowerShell.BeginInvoke()
                    BaseDir     = $BaseDir
                }
            ))
        } # Function New-Runspace

        $AllFiles = [System.Collections.ArrayList]@()
        $Global:JobThreads = [System.Collections.ArrayList]@()

        # Set up runspace factory
        $MAX_THREADS          = [int]$ENV:NUMBER_OF_PROCESSORS + 1
        if ($MAX_THREADS -lt 5 ) { $MAX_THREADS = 5 }
        Write-Host "Max Threads: $MAX_THREADS"
        $Global:RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $MAX_THREADS)
        $Global:RunspacePool.ApartmentState = "MTA"
        [void]$Global:RunspacePool.Open()

        #region enumerate files
        $DriveLetters = Get-WmiObject Win32_Logicaldisk | Where-Object { $_.DriveType -in @(2,3,5,6) } | ForEach-Object { "$($_.DeviceId)\" }

        ForEach ( $DriveLetter in $DriveLetters ) {
            [array]$BaseDirectories  = Get-ChildItem $DriveLetter -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer } | Select-Object -ExpandProperty FullName
            New-RunSpace -BaseDir $DriveLetter
            # For each parent directory on each drive, including recycle bin - spawn a thread to enumerate files
            ForEach ($BaseDir in $BaseDirectories) {
                if ( $null -eq $BaseDir ) { continue }  # PSv2 always enters into the loop even if the loop item is null, so it will process 1 null entry.
                New-RunSpace -BaseDir $BaseDir
                
                [array]$SubDirectories  = Get-ChildItem $BaseDir -Directory -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
                ForEach ( $SubDir in $SubDirectories ) {
                    if ( $null -eq $SubDir ) { continue }  # PSv2 always enters into the loop even if the loop item is null, so it will process 1 null entry.
                    New-RunSpace -BaseDir $SubDir -Recurse
                }
            } # ForEach ($BaseDir in $BaseDirectories)
        } # ForEach ( $DriveLetter in $DriveLetters )

        # Wait for each thread to complete
        ForEach ( $job in $Global:JobThreads ) {
            $currentBaseDir = $job.BaseDir
            Write-Verbose "Waiting for $currentBaseDir"

            [void]$job.AsyncResult.AsyncWaitHandle.WaitOne()
            $Data = $job.PowerShell.EndInvoke($job.AsyncResult)
            [void]$AllFiles.AddRange($Data[0..$Data.count])
            $job.PowerShell.Dispose()
        }
        if ( $AllFiles.Count -gt 0 ) {
            $AllFiles
        }
        #endregion enumerate files

        $RunspacePool.Dispose()
    }
}
PROCESS {
    $Jobs = New-Object -TypeName "System.Collections.ArrayList"
    $WorkingDir = (Get-Location).path
    $OutputFile = Join-Path $WorkingDir $("Log4Shell-{0}.csv" -f [datetime]::now.ToString("yyMMdd-HHmm"))
    $JobCount = 0
    if ( $PSBoundParameters.ContainsKey("Computername") -and $PSBoundParameters.ContainsKey("Credential") ) {
        ForEach ($Computer in $Computername) {
            $RunningJobs = $Jobs.Where({$_.State -eq "Running"}).Count
            if ( $RunningJobs -ge $MAXJOBS ) {

                do {
                    Write-Host "$RunningJobs Jobs running, $JobCount started out of $($Computername.count).   Sleeping."
                    ForEach ( $job in $Jobs.Where({$_.State -eq "Completed"}) ) {
                        Write-Host "Pulling results for $($Job.name)"
                        $result = $Job | Receive-Job                        
                        $result | Export-Csv -NoTypeInformation $OutputFile -Append
                        [void]$jobs.Remove($job)
                    }
                    Start-Sleep -Seconds 30
                    $RunningJobs = $Jobs.Where({$_.State -eq "Running"}).Count
                } while ($RunningJobs -ge $MAXJOBS)
            }

            $IVParams = @{
                ComputerName = $Computer
                Credential = $Credential
                ScriptBlock = $ScriptBlock
                AsJob = $True
                JobName = $Computer
            }
            
            $Job = Invoke-Command @IVParams
            $Jobs.Add($Job) | Out-Null
            $JobCount++
        }

        if ( $Jobs.count -gt 0 ) {
            $timeout = 1200 # 15 minutes
            Write-Host "Waiting up to $timeout seconds for $($Jobs.count) jobs to finish"
            $Jobs | Wait-Job -Timeout $timeout | Out-Null
            
            # for each job that did not return results back, log those items
            #ForEach ($item in $Computername.Where({$Jobs.Name -notcontains $_})) {
            #    Write-Host "Did not retrieve results for $item" -ForegroundColor Red
            #}
        
            # receive the results from the remaining, successful jobs
            ForEach ( $job in $Jobs.Where({$_.State -eq "Completed"}) ) {
                Write-Host "Pulling results for $($Job.name)"
                $result = $Job | Receive-Job
                $result | Export-Csv -NoTypeInformation $OutputFile -Append
            }

            # Any jobs still running or in a failed status - log the computer and state
            ForEach ($item in $Jobs.Where({$_.State -ne "Completed"})) {
                Write-Host "Job state for  $($item.Name) is $($item.State)" -Foreground Red
                #$Jobs.Remove($item) | Out-Null
                #$item | Remove-Job -Force | Out-Null
            }
            $Jobs | Remove-Job -Force
        }
    }
    else {
        Invoke-Command -ScriptBlock $ScriptBlock | Export-Csv -NoTypeInformation $OutputFile -Append
    }
}
END {}
