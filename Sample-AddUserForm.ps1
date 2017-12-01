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
 
$params = @{'SamAccountName' = $sam.Text;
            'DisplayName' = $DisplayName;
            'GivenName' = $txtFirstName.Text;
            'Path' = $path;
            'SurName' = $txtLastName.Text;
            'ChangePasswordAtLogon' = $false;
            'Enabled' = $true;
            'UserPrincipalName' = ($sam + ".client.ext");
            'AccountPassword' = $password;
            'Description' = $desc.Description;
            }
 
#Single Function Combined
Function UserCreate-AddGroup
{
    Function UserCreate
    {
$dc = "corp-cli-dc2.client.ext"
$desc = "CompanyXYZ"
$path = "OU=Users,OU=External Objects,DC=client,DC=ext"
 
$groups = "FormLockdownApp"
 
$random = Get-Random -Maximum 9999 -Minimum 1000
$password = $txtFirstName.substring(0,1).ToUpper() + $txtLastName.substring(0,1).ToUpper() + "Form" + $random | ConvertTo-SecureString -AsPlainText -Force
$DisplayName = $txtFirstName.Text + ' ' + $txtLastName.Text
 
$txtFirstName.Add_TextChanged({ #Checks wheter First name and Last name is filled, and populates the initials field
    if(($txtFirstName.text.Length -ge 1) -and ($txtLastName.text.length -ge 1)){
        $Initials.text = $txtFirstName.text.substring(0,1) + $txtLastName.text.substring(0,1)
    }
})
 
$LastName.Add_TextChanged({ #Checks wheter First name and Last name is filled, and populates the initials field
    if(($txtLFirstName.text.Length -ge 1) -and ($txtLLastName.text.length -ge 1)){
        $Initials.text = $txtLFirstName.text.substring(0,1) + $txtLLastName.text.substring(0,1)
    }
})
 
#Checks Last name length for Username. If Username would be more than 8 characters it trims the last name for the Username
$txtLastName= ($txtLastName.Substring(0,1).toupper() + $txtLastName.Substring(1).tolower())
    If($txtLastName.Length -gt "7")
    {
        $sam = ($txtFirstName.Substring(0,2) + $txtLastName.Substring(0,6)).ToLower()
    }
    Else
    {
        $sam = ($txtFirstName.Substring(0,1) + $txtLastName).ToLower()
    }
 
    #Checks if username exist. If it does it creates a new Username
    $UserCheck = Get-ADUser -Filter {sAMaccountName -eq $sam} -ErrorAction 'SilentlyContinue'
    If($UserCheck)
    {
        Try
        {
            $sam = ($txtFirstName.Substring(0,2) + $txtLastName.Substring(0,6)).ToLower()
            CreateUser $sam $txtFirstName
            Write-Host "$FirstName;$LastName;$sam Created" -ForegroundColor Green
            $out = "$FirstName;$LastName;$sam"
       
        }
       
    Catch
        {
            $out = "user $Sam " + $error[0].Exception.Message.toString()
            $out | Out-File ".\Error.log" -append
            $Out = ";"
            $Out| out-file '.\Chargercreated.txt' -append
           
            write-host "Username Creation Error for $FirstName $lastName " + $error[0].Exception.Message.toString() -ForegroundColor Red
}
}
   
       New-ADUser $params
    }
 
    Function Add-Group
    {
       Add-ADPrincipalGroupMembership -Identity $sam -server $dc -MemberOf $groups -confirm:$false
    }
}
function do_exit
{
     $Exit.close()
}
 
$UserCreate.add_click({UserCreate-AddGroup})
$UserCreate.location = new-object system.drawing.point(7,145)
$UserCreate.Font = "Consolas,10"
$Form.controls.Add($UserCreate)
 
$Exit.add_click({do_exit})
 
[void]$Form.ShowDialog()
$Form.Dispose()
