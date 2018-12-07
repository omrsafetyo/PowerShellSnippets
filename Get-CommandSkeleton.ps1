[CmdletBinding()]
PARAM(
	[Parameter(Mandatory=$True)]
	[string]
	$CommandName,
	
	[Parameter(Mandatory=$False)]
	[string]
	[ValidateSet("Alias","Cmdlet","Function","Script")]
	$CommandType
)

BEGIN {
	# This section just gets a list of automatic variables created by [CmdletBinding()] so they are not added to the PARAM block
	Function Test-InternalFunction {
		[CmdletBinding()]
		PARAM()
		PROCESS{}
	}
	
	$IgnoreParameters = (Get-Command Test-InternalFunction).Parameters.Keys
	Remove-Item -Path Function:\Test-InternalFunction
}

PROCESS {
	$ParamHash = @{
		Name = $CommandName
	}
	if ( $PSBoundParameters.ContainsKey("CommandType")) {
		$ParamHash.Add("CommandType",$CommandType)
	}
	
	$Command = Get-Command @ParamHash
	if ( [string]::IsNullOrEmpty($Command) ) {
		exit
	}
	$ModuleName = $Command.ModuleName
	
	$Parameters = $Command.Parameters
	$DefaultParameterSet = $Command.DefaultParameterSet
	$ParameterSets = $Command.ParameterSets.Name
	
	$i=0
	# Write out the function declaration up to the PARAM block
	[array]$Output = "Function $CommandName {"
	if (-NOT([string]::IsNullOrEmpty($DefaultParameterSet))) {
		$Output += "[CmdletBinding(DefaultParameterSetName='$DefaultParameterSet')]"
	}
	else {
		$Output += "[CmdletBinding()]"
	}
	
	$Output += "PARAM("
	
	# This loop will write out each of the parameters for the command
	
	$OutputParameterKeys = $Parameters.Keys | Where-Object { $IgnoreParameters -notcontains $_ }
	
	ForEach ( $Key in $OutputParameterKeys) {
		if ( $Parameters[$Key].SwitchParameter -eq $True ) {
			$Type = "Switch"
		} 
		else {
			$Type = $Parameters[$Key].ParameterType.Name
			if ( $Type -eq 'FlagsExpression`1') {
				$Type = 'System.Management.Automation.FlagsExpression`1[System.IO.FileAttributes]'
			}
		}
		
		if ( $i -eq ($OutputParameterKeys.Count - 1) ) {
			$Comma = ""
		}
		else {
			$Comma = ","
		}
		
		$ParamParameterSets = $Parameters[$Key].ParameterSets.Keys
		
		# Write Out the [Parameter] information
		if ( $ParamParameterSets -eq "__AllParameterSets" ) {
			ForEach ($ParameterSet in $ParameterSets) {
				$Mandatory = $Parameters[$Key].ParameterSets["__AllParameterSets"].IsMandatory
				$Position = $Parameters[$Key].ParameterSets["__AllParameterSets"].Position
				if ($Position -ge 0) {
					$Position = ", Position={0}" -f $Position
				} 
				else {
					$Position = ""
				}
				
				$Output += '    [Parameter(ParameterSetName="{0}", Mandatory=${1}{2})]' -f $ParameterSet, $Mandatory, $Position
			}
		}
		else {
			ForEach ($ParameterSet in $ParamParameterSets) {
				$Mandatory = $Parameters[$Key].ParameterSets[$ParameterSet].IsMandatory
				$Position = $Parameters[$Key].ParameterSets[$ParameterSet].Position
				if ($Position -ge 0) {
					$Position = ", Position={0}" -f $Position
				} else {$Position = ""}
				
				$Output += '    [Parameter(ParameterSetName="{0}", Mandatory=${1}{2})]' -f $ParameterSet, $Mandatory, $Position
			}
		}
		# Parameter Type 
		$Output += '    [{0}]' -f $Type
		# Parameter Name, and comma if not the last
		$Output += '    ${0}{1}' -f $Key, $Comma
		$Output += ''
		   
		$i++
	}
	
	# Finish up the skeleton code
	$Output += ")"
	$Output += "BEGIN {}"
	
	$Output += "PROCESS {"
	# Call the program from its absolute location using the same parameters passed to the current command
	if ( -NOT([string]::IsNullOrEmpty($ModuleName))) {
		$Output += '    {0}\{1} @PSBoundParameters' -f $ModuleName, $CommandName
	}
	else {
		$Output += '{0} @PSBoundParameters' -f $CommandName
	}
	$Output += "}"
	$Output += "END {}"
	$Output += "}"
	
	Write-Output $Output
}
