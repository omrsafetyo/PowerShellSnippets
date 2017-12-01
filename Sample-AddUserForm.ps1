[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
 
$Form = New-Object system.Windows.Forms.Form
$Form.Text = "XYZ: Form Account Creation"
$Form.BackColor = "#ffffff"
$Form.TopMost = $true
$Form.Width = 403
$Form.Height = 235
 
$FirstName = New-Object system.windows.Forms.Label
$FirstName.Text = "First Name"
$FirstName.AutoSize = $true
$FirstName.Width = 25
$FirstName.Height = 10
$FirstName.location = new-object system.drawing.point(7,15)
$FirstName.Font = "Consolas,10"
$Form.controls.Add($FirstName)
 
$txtFirstName = New-Object system.windows.Forms.TextBox
$txtFirstName.BackColor = "#ffffff"
$txtFirstName.ForeColor = "#000000"
$txtFirstName.Width = 100
$txtFirstName.Height = 20
$txtFirstName.location = new-object system.drawing.point(107,15)
$txtFirstName.Font = "Consolas,10"
$Form.controls.Add($txtFirstName)
 
$LastName = New-Object system.windows.Forms.Label
$LastName.Text = "Last Name"
$LastName.AutoSize = $true
$LastName.Width = 25
$LastName.Height = 10
$LastName.location = new-object system.drawing.point(7,45)
$LastName.Font = "Consolas,10"
$Form.controls.Add($LastName)
 
$txtLastName = New-Object system.windows.Forms.TextBox
$txtLastName.BackColor = "#ffffff"
$txtLastName.ForeColor = "#000000"
$txtLastName.Width = 100
$txtLastName.Height = 20
$txtLastName.location = new-object system.drawing.point(107,45)
$txtLastName.Font = "Consolas,10"
$Form.controls.Add($txtLastName)
 
$UserCreate = New-Object system.windows.Forms.Button
$UserCreate.Text = "Create"
$UserCreate.Width = 60
$UserCreate.Height = 30
 
$Exit = New-Object system.windows.Forms.Button
$Exit.Text = "Exit"
$Exit.Width = 60
$Exit.Height = 30
$Exit.location = new-object system.drawing.point(147,145)
$Exit.Font = "Consolas,10"
$Form.controls.Add($Exit)
  
#Single Function Combined
Function UserCreate-AddGroup
{
	$params = @{
	        'SamAccountName' = ""
            'DisplayName' = ""
            'GivenName' = $txtFirstName.Text
            'Path' = ""
            'SurName' = $txtLastName.Text
            'ChangePasswordAtLogon' = $false
            'Enabled' = $true
            'UserPrincipalName' = ""
            'AccountPassword' = ""
            'Description' = ""
			'Name' = ""
	}
	write-host "hello world"

    Function UserCreate
    {
		param(
			$SamAccountName,
			$FirstName,
			$LastName
		)
		
		if ( [string]::isNullOrEmpty($FirstName) ) {
			$FirstName = $txtFirstName.Text
		}
		
		if ( [string]::isNullOrEmpty($LastName) ) {
			$LastName = $txtLastName.Text
		}
		
		$dc = "corp-cli-dc2.client.ext"
		$desc = "CompanyXYZ"
		$path = "OU=Users,OU=External Objects,DC=client,DC=ext"
		$groups = "FormLockdownApp"
		 
		$random = Get-Random -Maximum 9999 -Minimum 1000
		$password = $FirstName.substring(0,1).ToUpper() + $LastName.substring(0,1).ToUpper() + "Form" + $random | ConvertTo-SecureString -AsPlainText -Force
		$DisplayName = $FirstName + ' ' + $LastName
		 
		#Checks Last name length for Username. If Username would be more than 8 characters it trims the last name for the Username
		$txtLastNameLocal = ($LastName.Substring(0,1).toupper() + $LastName.Substring(1).tolower())
		
		if ( -Not([string]::isNullOrEmpty($SamAccountName)) ) {
			$sam = $SamAccountName
		} else {
			If($txtLastNameLocal.Length -gt "7")
			{
				$sam = ($FirstName.Substring(0,2) + $LastName.Substring(0,6)).ToLower()
			}
			Else
			{
				$sam = ($FirstName.Substring(0,1) + $LastName).ToLower()
			}
		}
	 
		#Checks if username exist. If it does it creates a new Username
		$UserCheck = Get-ADUser -Filter {sAMaccountName -eq $sam} -ErrorAction 'SilentlyContinue'
		If($UserCheck)
		{
			Try
			{
				$sam = ($FirstName.Substring(0,2) + $LastName.Substring(0,6)).ToLower()
				# This won't work
				UserCreate -SamAccountName $sam -FirstName $FirstName -LastName
				Write-Host "$FirstName;$LastName;$sam Created" -ForegroundColor Green
				$out = "$FirstName;$LastName;$sam"
			}  
			Catch
			{
				$out = "user $Sam " + $error[0].Exception.Message.toString()
				$out | Out-File ".\Error.log" -append
				$Out = ";"
				$Out| out-file '.\Chargercreated.txt' -append
			   
				write-host "Username Creation Error for $txtFirstName $txtLastName " + $error[0].Exception.Message.toString() -ForegroundColor Red
			}
		}
		
		$params.Name = $sam
		$params.SamAccountName = $sam
		$params.UserPrincipalName = $("{0}.client.ext" -f $sam)
		$params.DisplayName = $DisplayName
		$params.Path = $path
		$params.Description = $desc
		$params.AccountPassword = (ConvertTo-SecureString -AsPlainText $password -Force)
		New-ADUser @params -whatif
    }
 
    Function Add-Group
    {
       Add-ADPrincipalGroupMembership -Identity $params.SamAccountName -server $dc -MemberOf $groups -confirm:$false
    }
	UserCreate
}
function do_exit
{
     $Form.close()
}

$txtFirstName.Add_TextChanged({ #Checks wheter First name and Last name is filled, and populates the initials field
	if(($txtFirstName.text.Length -ge 1) -and ($txtLastName.text.length -ge 1)){
		$Initials.text = $txtFirstName.text.substring(0,1) + $txtLastName.text.substring(0,1)
	}
})
 
$LastName.Add_TextChanged({ #Checks wheter First name and Last name is filled, and populates the initials field
	if(($txtFirstName.text.Length -ge 1) -and ($txtLastName.text.length -ge 1)){
		$Initials.text = $txtFirstName.text.substring(0,1) + $txtLastName.text.substring(0,1)
	}
})
 
$UserCreate.add_click({UserCreate-AddGroup})
$UserCreate.location = new-object system.drawing.point(7,145)
$UserCreate.Font = "Consolas,10"
$Form.controls.Add($UserCreate)
 
$Exit.add_click({do_exit})
 
[void]$Form.ShowDialog()
$Form.Dispose()
