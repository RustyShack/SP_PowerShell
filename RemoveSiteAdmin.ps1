#Load SharePoint PS
Add-PSSnapin *SharePoint*

function button ($title,$mailbx, $WF, $TF) {

###################Load Assembly for creating form & button######
[void][System.Reflection.Assembly]::LoadWithPartialName( “System.Windows.Forms”)
[void][System.Reflection.Assembly]::LoadWithPartialName( “Microsoft.VisualBasic”)

#####Define the form size & placement
$form = New-Object “System.Windows.Forms.Form”;
$form.Width = 500;
$form.Height = 90;
$form.Text = $title;
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;

##############Define text label1
$textLabel1 = New-Object “System.Windows.Forms.Label”;
$textLabel1.Left = 25;
$textLabel1.Top = 15;

$textLabel1.Text = $mailbx;


############Define text box1 for input
$textBox1 = New-Object “System.Windows.Forms.TextBox”;
$textBox1.Left = 150;
$textBox1.Top = 10;
$textBox1.width = 200;


#############Define default values for the input boxes
$defaultValue = “”
$textBox1.Text = $defaultValue;

#############define OK button
$button = New-Object “System.Windows.Forms.Button”;
$button.Left = 360;
$button.Top = 10;
$button.Width = 100;
$button.Text = “Remove”;

############# This is when you have to close the form after getting values
$eventHandler = [System.EventHandler]{
$textBox1.Text;
$form.Close();};

$button.Add_Click($eventHandler) ;

#############Add controls to all the above objects defined
$form.Controls.Add($button);
$form.Controls.Add($textLabel1);
$form.Controls.Add($textBox1);
$ret = $form.ShowDialog();

#################return values

return $textBox1.Text
}


$Return = button “Remove Site Admin v.01” “UserLogin”

#Add Domain
$UserDomain = "oaad\$return"

#Add Claims Prefix
$UserClaim = "i:0#.w|$userdomain"

#Get All Sites except Mysites
Get-SPWebApplication | Where-Object {$_.Url -notlike "*mysite*"} | get-spsite -limit all | foreach {

#Find Site Admns
$members = Get-SpWeb  $_.url | Select -ExpandProperty SiteAdministrators

$site = $_.url

#Cycle through all Admins
foreach ($member in $members) {

If ($member.UserLogin -eq $UserClaim) {

#Create Confirmation Dialog
Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::YesNo
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
$MessageBody = "Are you sure you want to remove $UserClaim from $site"
$MessageTitle = "Confirm Removal"
 
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
 
If ($Result -eq "Yes") {

#Remove Users
Remove-SPuser $UserClaim -web $_.url -Confirm:$false
}

}

}

}