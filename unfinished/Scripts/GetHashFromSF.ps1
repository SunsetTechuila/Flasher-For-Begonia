param ([Parameter(Mandatory)] [string]$androidVer,[Parameter(Mandatory)] [string]$gappsVer,$addons=0)
pushd ..
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
[Console]::Title="Получение хеш-сумм"
$dateDownload=Get-Content Flasher\GApps\date_download.txt
$dateDownload2=Get-Content Flasher\GApps\date_download_2.txt
if ($androidVer -ne 12) {
	$packageName='open_gapps-arm64-'+$androidVer+'.0-'+$gappsVer+'-'+$dateDownload+'.zip'
	$gappsLink='https://sourceforge.net/projects/opengapps/files/arm64/'+$dateDownload
} else {
	$packageName='NikGapps-core-arm64-12.1-'+$dateDownload+'-signed.zip'
	$gappsLink='https://sourceforge.net/projects/nikgapps/files/Releases/NikGapps-SL/'+$dateDownload2
	}
$gappsHash=(Invoke-WebRequest -UseBasicParsing $gappsLink).RawContent -match "($([regex]::Escape($packageName))`",`"type`":`"f`",`"link`":`"`",`"downloads`":\d+,`"sha1`":`"\w+`",`"md5`":`"(?<md5>\w+)`",)" | Out-Null
$gappsHash=$matches['md5']
Set-Content Flasher\GApps\hash.txt $('gapps_a'+$androidVer+'_'+$gappsVer+'_'+$dateDownload+'.zip '+$gappsHash)
if ($addons -eq 1) {
	$addonsPackages=Get-Content Flasher\GApps\choiceAddons.txt
	$addonsLink='https://sourceforge.net/projects/nikgapps/files/Releases/Addons-SL/'+$dateDownload2
	$addonsPage=(Invoke-WebRequest -UseBasicParsing $addonsLink).RawContent
	$addonsPackages | ForEach-Object {
	$packageName='NikGapps-Addon-12.1-'+$PSItem+'-'+$dateDownload+'-signed.zip'
	$addonHash=$addonsPage -match "($([regex]::Escape($packageName))`",`"type`":`"f`",`"link`":`"`",`"downloads`":\d+,`"sha1`":`"\w+`",`"md5`":`"(?<md5>\w+)`",)" | Out-Null 
	$addonHash=$matches['md5']
	Add-Content Flasher\GApps\hash.txt $('addon_'+$PSItem+'_'+$dateDownload+'.zip '+$addonHash)
	}
}