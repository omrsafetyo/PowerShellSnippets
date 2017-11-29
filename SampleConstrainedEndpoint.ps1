# Need to set up a new Event Log source:
# New-EventLog -Source ExampleConstrainedEndpoint -LogName application

$Script:AssumedUser  = $PSSenderInfo.UserInfo.Identity.name 
if ($Script:AssumedUser) { 
    Write-EventLog -LogName Application -Source ExampleConstrainedEndpoint -EventId 1 -Message "$Script:AssumedUser, Started a remote Session" 
}

#region functions
Function Get-Service {
	<#
	.FORWARDHELPTARGETNAME Get-Service
	#>
	[CmdletBinding(DefaultParameterSetName='Default')]
	param(
		[Parameter(ParameterSetName='Default', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[Alias('ServiceName')]
		[string[]]
		${Name},

		[Alias('DS')]
		[switch]
		${DependentServices},

		[Alias('SDO','ServicesDependedOn')]
		[switch]
		${RequiredServices},

		[Parameter(ParameterSetName='DisplayName', Mandatory=$true)]
		[string[]]
		${DisplayName},

		[ValidateNotNullOrEmpty()]
		[string[]]
		${Include},

		[ValidateNotNullOrEmpty()]
		[string[]]
		${Exclude},

		[Parameter(ParameterSetName='InputObject', ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[PSCustomObject[]]
		${InputObject}
	)
	
	PROCESS {
		$params = @{}
		ForEach ( $key in $PSBoundParameters.Keys ) {
			$params.Add($key,$PSBoundParameters[$key])
		}
		try {
			$service = Microsoft.PowerShell.Management\Get-Service @params -ErrorAction Stop| Where-Object { $_.DisplayName -match "Spooler"}
			if ( $null -ne $service ) {
				$service
			}
			else {
				if ( $DisplayName -or $Name ) {
					throw "Cannot find any service with service name, or you do not have permission."
				}
			}
		}
		catch {
			throw $_
		}
	}
}

Function Start-Service {
	<#
	.FORWARDHELPTARGETNAME Start-Service
	#>
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory=$False)]
		[ValidateScript({
			if (-not(((Get-Service).Name) -contains $_) ) {
				throw "You do not have permission to do that."
			}
			else {
				return $true
			}
		})]
		[string[]]
		[Alias("ServiceName")]
		$Name,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$DependentServices,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$RequiredServices,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		[ValidateScript({
			if (-not(((Get-Service).DisplayName) -contains $_) ) {
				throw "You do not have permission to do that."
			}
			else {
				return $true
			}
		})]
		$DisplayName,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		$Include,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		$Exclude,
		
		[Parameter(Mandatory=$False)]
		[PSCustomObject[]]
		$InputObject,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$Passthru
	)
	
	PROCESS {
		$params = @{}
		ForEach ( $key in $PSBoundParameters.Keys ) {
			if ( $key -eq "Passthru" ) {
				continue
			}
			$params.Add($key,$PSBoundParameters[$key])
		}
		Microsoft.PowerShell.Management\Start-Service @params
		
		if ($Script:AssumedUser) {
			$msg = "{0} Started Service(s): {1}" -f $Script:AssumedUser, ($Service.Name -Join ",")
			Write-EventLog -LogName Application -Source ExampleConstrainedEndpoint -EventId 1 -Message $msg 
		}
		$Service = Get-Service @params 
		if ( $null -ne $Service ) {
			$InternalParams = ${
				InputObject = $Service
			}

			if ( $PSBoundParameters.ContainsKey("Passthru") ) {
				$InternalParams.Add("Passthru", $Passthru)
			}
			Microsoft.PowerShell.Management\Start-Service @InternalParams
			
			if ($Script:AssumedUser) {
				$msg = "{0} Started Service(s): {1}" -f $Script:AssumedUser, ($Service.Name -Join ",")
				Write-EventLog -LogName Application -Source ExampleConstrainedEndpoint -EventId 1 -Message $msg 
			}
		}
		else {
			throw "Cannot find any service with service name, or you do not have permission."
		}
	}
}

Function Restart-Service {
	<#
	.FORWARDHELPTARGETNAME Restart-Service
	#>
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory=$False)]
		[ValidateScript({
			if (-not(((Get-Service).Name) -contains $_) ) {
				throw "You do not have permission to do that."
			}
			else {
				return $true
			}
		})]
		[string[]]
		[Alias("ServiceName")]
		$Name,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$DependentServices,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$RequiredServices,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		[ValidateScript({
			if (-not(((Get-Service).DisplayName) -contains $_) ) {
				throw "You do not have permission to do that."
			}
			else {
				return $true
			}
		})]
		$DisplayName,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		$Include,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		$Exclude,
		
		[Parameter(Mandatory=$False)]
		[PSCustomObject[]]
		$InputObject,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$Passthru
	)
	
	PROCESS {
		$params = @{}
		ForEach ( $key in $PSBoundParameters.Keys ) {
			if ( $key -eq "Passthru" ) {
				continue
			}
			$params.Add($key,$PSBoundParameters[$key])
		}
		Microsoft.PowerShell.Management\Restart-Service @Params
		if ($Script:AssumedUser) {
			$msg = "{0} Restarted Service(s): {1}" -f $Script:AssumedUser, ($Service.Name -Join ",")
			Write-EventLog -LogName Application -Source ExampleConstrainedEndpoint -EventId 1 -Message $msg 
		}
		$Service = Get-Service @params
		if ( $null -ne $Service ) {
			$InternalParams = ${
				InputObject = $Service
			}

			if ( $PSBoundParameters.ContainsKey("Passthru") ) {
				$InternalParams.Add("Passthru", $Passthru)
			}
			
			Microsoft.PowerShell.Management\Restart-Service @InternalParams
			
			if ($Script:AssumedUser) {
				$msg = "{0} Restarted Service(s): {1}" -f $Script:AssumedUser, ($Service.Name -Join ",")
				Write-EventLog -LogName Application -Source ExampleConstrainedEndpoint -EventId 1 -Message $msg 
			}
		}
		else {
			throw "Cannot find any service with service name, or you do not have permission."
		}
	}
}

Function Stop-Service {
	<#
	.FORWARDHELPTARGETNAME Stop-Service
	#>
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory=$False)]
		[ValidateScript({
			if (-not(((Get-Service).Name) -contains $_) ) {
				throw "You do not have permission to do that."
			}
			else {
				return $true
			}
		})]
		[string[]]
		[Alias("ServiceName")]
		$Name,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$DependentServices,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$RequiredServices,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		[ValidateScript({
			if (-not(((Get-Service).DisplayName) -contains $_) ) {
				throw "You do not have permission to do that."
			}
			else {
				return $true
			}
		})]
		$DisplayName,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		$Include,
		
		[Parameter(Mandatory=$False)]
		[string[]]
		$Exclude,
		
		[Parameter(Mandatory=$False)]
		[PSCustomObject[]]
		$InputObject,
		
		[Parameter(Mandatory=$False)]
		[switch]
		$Passthru
	)
	
	PROCESS {
		$params = @{}
		ForEach ( $key in $PSBoundParameters.Keys ) {
			if ( $key -eq "Passthru" ) {
				continue
			}
			$params.Add($key,$PSBoundParameters[$key])
		}
		Microsoft.PowerShell.Management\Stop-Service @params
		if ($Script:AssumedUser) {
			$msg = "{0} Stopped Service(s): {1}" -f $Script:AssumedUser, ($Service.Name -Join ",")
			Write-EventLog -LogName Application -Source ExampleConstrainedEndpoint -EventId 1 -Message $msg 
		}
		$Service = Get-Service @params
		if ( $null -ne $Service ) {
			$InternalParams = ${
				InputObject = $Service
			}
			if ( $PSBoundParameters.ContainsKey("Passthru") ) {
				$InternalParams.Add("Passthru", $Passthru)
			}
			
			Microsoft.PowerShell.Management\Stop-Service @InternalParams
			
			if ($Script:AssumedUser) {
				$msg = "{0} Stopped Service(s): {1}" -f $Script:AssumedUser, ($Service.Name -Join ",")
				Write-EventLog -LogName Application -Source ExampleConstrainedEndpoint -EventId 1 -Message $msg 
			}
		}
		else {
			throw "Cannot find any service with service name, or you do not have permission."
		}
	}
}

#endregion functions

if (-not $psise) {  
	# set visibility of all Cmdlets, Filters, Functions, and Aliases to Private.  This prevents them being executed outside of a function.
    Get-Command -CommandType Cmdlet,Filter | ForEach-Object  {$_.Visibility = 'Private' } 
    Get-Command -CommandType Function | 
		Where-Object { -NOT(@("Get-Service", "Start-Service", "Restart-Service", "Stop-Service") -contains $_.Name) } | 
		ForEach-Object  {$_.Visibility = 'Private' } 
    Get-Alias                                       | ForEach-Object  {$_.Visibility = 'Private' } 
    #To show multiple commands put the name as a comma separated list  
    # Get-Command -Name Get-Printer                   | ForEach-Object  {$_.Visibility = 'Public'  }  
	
    $ExecutionContext.SessionState.Applications.Clear() 
    $ExecutionContext.SessionState.Scripts.Clear()
	
	# Expose some commands that will be useful, and don't do anything just in case
    $RemoteServer =  [System.Management.Automation.Runspaces.InitialSessionState]::CreateRestricted( 
                                      [System.Management.Automation.SessionCapabilities]::RemoteServer) 
    $RemoteServer.Commands.Where{($_.Visibility -eq 'public') -and ($_.CommandType -eq 'Function') } |  ForEach-Object {  
		Set-Item -path "Function:\$($_.Name)" -Value $_.Definition 
	}
}

# set the Language mode - this prevents the user from defining their own functions and bypassing our security.
if (-not $psise) {$ExecutionContext.SessionState.LanguageMode = [System.Management.Automation.PSLanguageMode]::NoLanguage} 
