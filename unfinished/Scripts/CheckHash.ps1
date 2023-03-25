param ([Parameter(Mandatory)] [string]$pathToHashFile)
[Console]::Title="Проверка целостности файлов"
$pathToFiles=$pathToHashFile -Replace ('hash.txt','')
(Get-Content $pathToHashFile) | ForEach-Object {
	$PSItem -match '(.+) (.+)'| Out-Null
	$fileName=$matches[1]
	$expectedHash=$matches[2]
	$file=$pathToFiles+$fileName
	$realHash=(Get-FileHash $file -Algorithm MD5).Hash
	if ($realHash -ne $expectedHash) {Write-Error ('Файл '+$fileName+' поврежден!')}
	}