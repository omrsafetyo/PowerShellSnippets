Function Convert-CustomObjectToXml {
<#
.SYNOPSIS
 
Outputs a human readable simple text XML representation of a simple PS object.
 
.PARAMETER object
 
The input object to inspect and dump.
 
.PARAMETER depth
 
The number of levels deep to dump. Defaults to 1.
 
.PARAMETER rootEl
 
The name of the root element in the document. Defaults to "root"
 
.PARAMETER indentString
 
The string used to indent each level of XML. Defaults to two spaces.
Set to "" to remove indentation.
 
.DESCRIPTION
 
Outputs a human readable simple text XML representation of a simple PS object.
 
A PSObject with member types of NoteProperty will be dumped to XML.  Only
nested PSObjects up to the depth specified will be searched. All other
note properties will be ouput using their strings values.
 
The output consists of node with property names and text nodes containing the
property value.

Original Author: http://wannemacher.us/?p=430
Modified to include working with Object arrays, and now outputs XML instead of strings.
 
#>
	[CmdletBinding()]
	param (
		[PSCustomObject]$object,
		[Int32]$depth = 1,
		[String]$rootEl = "root",
		[String]$indentString = "  ",
		[Int32]$indent = 1,
		[switch]$isRoot = $true,
		[String]$XmlVersion = "1.0",
		[String]$Encoding = "UTF-8"
	)
	BEGIN {
		$sb = [System.Text.StringBuilder]::new()
	}
	
	PROCESS {
		# Output the root element opening tag
		if ($isRoot) {
			[void]$sb.AppendLine(("<{0}>" -f $rootEl))
		}
		
		ForEach ( $item in $object ) {
			# Iterate through all of the note properties in the object.
			foreach ($prop in (Get-Member -InputObject $item -MemberType NoteProperty)) {
				$children = $item.($prop.Name)
				foreach ($child in $children) {
					# Check if the property is an object and we want to dig into it
					if ($child.GetType().Name -eq "PSCustomObject" -and $depth -gt 1) {
						[void]$sb.AppendLine(("{0}<{1}>" -f ($indentString * $indent), $prop.Name))
						Convert-CustomObjectToXml $child -isRoot:$false -indent ($indent + 1) -depth ($depth - 1) -indentString $indentString | ForEach-Object { [void]$sb.AppendLine($_) }
						[void]$sb.AppendLine(("{0}</{1}>" -f ($indentString * $indent), $prop.Name))
					}
					else {
						# output the element or elements in the case of an array
						foreach ($element in $child) {
							[void]$sb.AppendLine(("{0}<{1}>{2}</{1}>" -f ($indentString * $indent), $prop.Name, $element))
						}
					}
				}
			}
		}
	 
		# If this is the root, close the root element and convert it to Xml and output
		if ($isRoot) {
			[void]$sb.AppendLine(("</{0}>" -f $rootEl))
			[xml]$Output = $sb.ToString()
			$xmlDeclaration = $Output.CreateXmlDeclaration($XmlVersion,$Encoding,$null)
			[void]$Output.InsertBefore($xmlDeclaration, $Output.DocumentElement)
			$Output
		}
		else {
			# If this is the not the root, this has been called recursively, output the string
			Write-Output $sb.ToString()
		}
	}
	END {}
}
