function CheckChosen
{	
	if (!$choiceInput) {Write-Host "Ничего не введено"; return $False}
	$choiceInput | ForEach-Object {
		if ($PSItem -notmatch "^\d+$") {$rightInput=$False; Write-Host "Введены недопустимые символы"; return}
		if ($PSItem.Length -gt 9 -or [int]$PSItem -gt $i) {$rightInput=$False; Write-Host "Одно или несколько значений больше допустимого максимума"; return}
		if ([int]$PSItem -le 0) {$rightInput=$False; Write-Host "Одно или несколько значений меньше допустимого минимума"; return}
	}
	if ($rightInput -eq $False) {return $False} else {return $True}
}

[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
[Console]::Title="Выбор аддонов"
$arrAddon=Invoke-WebRequest -UseBasicParsing https://sourceforge.net/projects/nikgapps/files/Releases/Addons-SL/$(Get-Content GApps\date_download_2.txt)
$arrAddon=$arrAddon.links.title | ForEach-Object {If ($PSItem -match 'NikGapps-Addon-12\.1-([^-]+)-(\d+)-signed\.zip' -and $matches[1] -notin @('Flipendo', 'PixelLauncher', 'DeviceSetup')) {$matches[1]}}
$arrAddon | ForEach-Object {
	$i++
	Write-Output "$i) $PSItem"
	Start-Sleep -m 10
}
do {
	$choiceInput=(Read-Host "Введите номера нужных аддонов через запятую").Split(",").Trim() | Select -uniq
	$correctInput=CheckChosen
} until ($correctInput -eq $True)
$choiceInput | ForEach-Object {$choiceAddon+=$arrAddon[[int]$PSItem-1]}
[IO.File]::WriteAllLines('GApps\choiceAddons.txt', $choiceAddon)