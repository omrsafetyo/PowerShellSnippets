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
proprty value.

Original Author: http://wannemacher.us/?p=430
Modified to include working with Object arrays
 
#>
	param (
		[PSCustomObject]$object,
		[Int32]$depth = 1,
		[String]$rootEl = "root",
		[String]$indentString = "  ",
		[Int32]$indent = 1,
		[switch]$isRoot = $true
	)
 
	# Output the root element opening tag
	if ($isRoot) {
		"<{0}>" -f $rootEl
	}
	# Iterate through all of the note properties in the object.
	if ( $object -is [array] ) {
		ForEach ( $item in $object ) {
			foreach ($prop in (Get-Member -InputObject $item -MemberType NoteProperty)) {
				$child = $item.($prop.Name)
		 
				# Check if the property is an object and we want to dig into it
				if ($child.GetType().Name -eq "PSCustomObject" -and $depth -gt 1) {
					"{0}<{1}>" -f ($indentString * $indent), $prop.Name
						Convert-CustomObjectToXml $child -isRoot:$false -indent ($indent + 1) -depth ($depth - 1) -indentString $indentString
					"{0}</{1}>" -f ($indentString * $indent), $prop.Name
				}
				else {
					# output the element or elements in the case of an array
					foreach ($element in $child) {
						"{0}<{1}>{2}</{1}>" -f ($indentString * $indent), $prop.Name, $element
					}
				}
			}
		}
	}
	else {
		foreach ($prop in (Get-Member -InputObject $object -MemberType NoteProperty)) {
			$child = $object.($prop.Name)
	 
			# Check if the property is an object and we want to dig into it
			if ($child.GetType().Name -eq "PSCustomObject" -and $depth -gt 1) {
				"{0}<{1}>" -f ($indentString * $indent), $prop.Name
					Convert-CustomObjectToXml $child -isRoot:$false -indent ($indent + 1) -depth ($depth - 1) -indentString $indentString
				"{0}</{1}>" -f ($indentString * $indent), $prop.Name
			}
			else {
				# output the element or elements in the case of an array
				foreach ($element in $child) {
					"{0}<{1}>{2}</{1}>" -f ($indentString * $indent), $prop.Name, $element
				}
			}
		}
	}
 
	# Output the root element closing tag
	if ($isRoot) {
		"</{0}>" -f $rootEl
	}
}
