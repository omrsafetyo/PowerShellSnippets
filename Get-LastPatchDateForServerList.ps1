Workflow Get-LastPatchDateForServerList {
	param($Servers)
	
	ForEach -Parallel ( $Server in $Servers ) {
		$ServerName = $Server.Name

		try{
			# This command was failing with a strange error:
			<#
				writeErrorStream      : True
				PSMessageDetails      :
				OriginInfo            : [localhost]
				Exception             : System.Management.Automation.RemoteException: A parameter cannot be found that matches parameter name 'InformationAction'.
										   at Microsoft.PowerShell.Activities.PSActivity.OnResumeBookmark(NativeActivityContext context, Bookmark bookmark, Object value)
										   at System.Activities.Runtime.BookmarkWorkItem.Execute(ActivityExecutor executor, BookmarkManager bookmarkManager)
				TargetObject          :
				CategoryInfo          : NotSpecified: (:) [Write-Error], RemoteException
				FullyQualifiedErrorId : System.Management.Automation.RemoteException,Microsoft.PowerShell.Commands.WriteErrorCommand
				ErrorDetails          :
				InvocationInfo        : System.Management.Automation.InvocationInfo
				ScriptStackTrace      :
				PipelineIterationInfo : {}
			#>
			$Patches = Get-HotFix -PSComputerName $ServerName -ErrorAction Stop 

		}
		catch{
			$Patches = InlineScript {
				Invoke-Command -ComputerName $Using:ServerName -ErrorAction SilentlyContinue -ScriptBlock { Get-HotFix }
			} 
		}

		#$OS = Get-WmiObject Win32_OperatingSystem -PSComputer $ServerName
		# https://mcpmag.com/articles/2013/05/07/remote-to-second-powershell.aspx
		[regex]$regex="\d\.\d$"
		try {
			$data = Test-WSMan $ServerName -ErrorAction Stop 
		} 
		catch {
			InlineScript {
				$msg = "Unable to connect to {0} to test WSMan" -f $using:ServerName
				Write-Warning $msg
			}
		}
		if ( $regex.match($data.ProductVersion).value -eq "2.0" -eq $True ) {
			$OS = InlineScript {
				$CimSessionOption = New-CimSessionOption -Protocol Dcom
				$CimSession = New-CimSession -ComputerName $Using:ServerName -SessionOption $CimSessionOption  -ErrorAction SilentlyContinue
				$CimSession | Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue 
			}  
		}
		else {
			try{
				$OS = Get-CimInstance Win32_OperatingSystem -PSComputer $ServerName -ErrorAction Stop 
			}
			catch {
				$OS = InlineScript {
					$CimSessionOption = New-CimSessionOption -Protocol Dcom
					$CimSession = New-CimSession -ComputerName $Using:ServerName -SessionOption $CimSessionOption -ErrorAction SilentlyContinue
					$CimSession | Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
				}
			}
		}
		
		$LastPatch = $Patches | Sort-Object InstalledOn -Descending  | Select-Object -first 1
		$KB2919355 = @($Patches | Where-Object { $_.HotFixID -eq "KB2919355" })
		
		if ( $null -ne $LastPatch ) {
			# When using WMI to get OS information - 
			# $LastBootTime = ([WMI] "").ConvertToDateTime($OS.Lastbootuptime)
			$LastBootTime = "{0} {1}" -f $OS.LastBootupTime.ToShortDateString(), $OS.LastBootupTime.ToShortTimeString()
			InlineScript {
				$msg = "Found patch information for {0}" -f $using:ServerName
				Write-Verbose  $msg
			}
			[PSCustomObject] @{
				CSName = $ServerName
				LastBootTime = $LastBootTime
				HotFixId = $LastPatch.HotFixId
				Description = $LastPatch.Description
				InstalledOn = $LastPatch.InstalledOn
				InstalledBy = $LastPatch.InstalledBy
				KB2919355 = ($KB2919355.Count -gt 0)
				OS = $OS.Caption
				Groups = (($Server | select-object -expand MemberOf) -join ",")
			}
		} else {
			[PSCustomObject] @{
				CSName = $ServerName
				LastBootTime = ""
				HotFixId = ""
				Description = $Exception
				InstalledOn = ""
				InstalledBy = ""
				KB2919355 = $False
				OS = ""
				Groups = (($Server | select-object -expand MemberOf) -join ",")
			}
		}
	}
}
