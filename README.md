# PowerShellSnippets

This is just a collection of sample scripts written, or improved, typically in assisting someone on a message board, etc.

## For those here for the Log4j scanner.

This tool is a script that expands on the s one-liner provided here: https://www.reddit.com/r/blueteamsec/comments/rd38z9/log4j_0day_being_exploited/

The one liner would search the C: drive for any .jar files, and search for references to the class JndiLookup.class.  This script does the same thing, but parallelized across systems, and multi-threaded on a given system.  As it does this specific search, it should find potentially vulnerable log4j files, but may also give false positives (the patched version of log4j still contains this reference), as well as other files that don't necessarily use log4j directly.  As such, it can be used to find potential vulnerabilities that development teams can ensure don't have the same issues as the log4j library.

Usage sample:

```powershell
$List = "mypc1","mypc2","mypc3"  
$Credential = Get-Credential
.\Invoke-Log4ShellScan.ps1 -Computername $List -Credential $Credential
```

I personally sourced a scan list from ActiveDirectory:

```powershell
$List = Get-AdComputer -Filter * -Prop LastLogonDate | Where { $_.LastLogonDate -gt [datetime]::now.AddDays(-30) } | Select -expand DNSHostName
```

There is an additional optional parameter for MAXJOBS - this is the number of systems to parallelize the remote jobs across.  The default is 50, and the limiting factor would be memory handling on the batch/utility server you're running this on.  Once you reach MAXJOBS background jobs in a running state, the script will sleep for 30 seconds waiting for jobs to finish.  While it does this, it will check for any jobs in a COMPLETED state, and start trying to pull the results of that system.  

It will write out to CSV file in the current working directory, Log4Shell-[datetimestamp].csv.  This file is written to as results are returned in the above described wait section.

Notes:

MAX_THREADS - this MAX_THREADS is the number of threads to spawn in the remote session. The default is #vCPU + 1, or 5 (whichever is greater). This defines the number of runspaces available in a runspace pool.  Each runspace pool is responsible for scanning a directory for files.  This script will enumerate each drive on the target system(s), and search for "parent directories" at a depth of 2 from each drive.  For instance:

```
C:
C:\Windows
C:\Windows\System32
```

It will scan the level 0 and level 1 directories non-recursively, and then scan the level 2 directories recursively.  This is to limit the number of files that are being checked in a given thread, and to increase parallelism.  If you want to be less aggressive in your search, you can adjust the MAX_THREADS calculation.

timeout - there is a 20 minute timeout by default waiting for jobs to complete after all jobs have been spawned (1200 seconds).  This can be increased or decreased on preference.
