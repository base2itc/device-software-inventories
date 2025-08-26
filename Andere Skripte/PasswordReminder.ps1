#Active Directory Passwort Policy:
$MaxPasswordAge = 90	#Max Password age in days
$WarningLevel = 30 		#Warn Users XX Days before Password expires

#Mail Settings:
$SMTPServer = "mediasystem-com.mail.protection.outlook.com"
$From = "password@mediasystem.com"
$Subject = "Bitte ändere dein Kennwort"

#Message Template (Mailbody)
function New-MailBody ($GivenName, $Surname, $DaysBeforePasswordchange, $PasswordExpireDate)
 {
   $Mailbody = "
    <html>
	<head>
	</head>
	<body>
     Hallo $GivenName,
     <br>
     dein Domänen-Kennwort läuft am $PasswordExpireDate ab.
	 <br>
	 Du hast $DaysBeforePasswordchange Tage bevor dein Kennwort abläuft, bitte aktualisiere es jetzt!
	 <br>
	 Auf folgender Website kannst du dein Kennwort ändern: <a href=`"https://passwort.mediasystem.com`">https://passwort.mediasystem.com</a>
	 <br>
     !! WICHTIG !! Das Portal ist aus dem Hausnetz oder via VPN erreichbar.
     <br>
	 Beste Grüße
	 <br>
	 Tim Weise
	 </body>
   "
   return $Mailbody
 }

#Import all active AD-Users
$AllADUsers = Get-ADUser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties PasswordLastSet,mail

#Calculate expirering passwords and store them in an object
$today = get-date
$ExpirePasswordList =@() 
foreach ($ADUser in $AllADUsers)
 {
  $GivenName = $ADUser.GivenName
  $Surname = $ADUser.Surname
  $MailAddress = $ADUser.mail
 
  $PasswordLastSet = $ADUser.PasswordLastSet
  $PasswordExpireDate = $PasswordLastSet.AddDays(+$MaxPasswordAge)
  
  $DaysBeforePasswordchange = ($PasswordExpireDate - $today).Days
  if ($DaysBeforePasswordchange -le $WarningLevel)
   {
	$ExpirePasswordList += new-object PSObject -property @{Givenname=$Givenname;Surname=$Surname;MailAddress=$MailAddress;DaysBeforePasswordchange=$DaysBeforePasswordchange;PasswordExpireDate=$PasswordExpireDate} 
   }
 }

#Filter Users with Mailaddresses
$ExpirePasswordList = $ExpirePasswordList | Where {$_.mailaddress}

#Send mail to every user with expired password
foreach ($ADUser in $ExpirePasswordList)
 {
  $GivenName = $ADUser.GivenName
  $Surname = $ADUser.Surname
  $MailAddress = $ADUser.MailAddress
  #$MailAddress = "t.weise@mediasystem.com"
  $DaysBeforePasswordchange = $ADUser.DaysBeforePasswordchange
  $PasswordExpireDate = $ADUser.PasswordExpireDate
  $PasswordExpireDate = $PasswordExpireDate | get-date -Format dd.MM.yyyy
  $Body = New-MailBody $GivenName $Surname $DaysBeforePasswordchange $PasswordExpireDate
  
  Send-MailMessage -SmtpServer $SMTPServer -To $MailAddress -From $From -Body $Body -BodyAsHtml -Subject $Subject -encoding ([System.Text.Encoding]::UTF8)
 }
