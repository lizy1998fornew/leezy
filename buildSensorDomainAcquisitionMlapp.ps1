$ErrorActionPreference = 'Stop'

$root = 'D:\codex'
$sourceM = Join-Path $root 'SensorDomainAcquisitionApp.m'
$outputMlapp = Join-Path $root 'SensorDomainAcquisitionApp.mlapp'
$templateMlapp = 'D:\MATLAB\R2022b\examples\daq\main\LiveDataAcquisition.mlapp'
$tempZip = Join-Path $root 'SensorDomainAcquisitionApp_template.zip'
$tempDir = Join-Path $root 'SensorDomainAcquisitionApp_mlapp_tmp'

if (!(Test-Path $sourceM)) {
    throw "Source file not found: $sourceM"
}

if (Test-Path $tempZip) {
    Remove-Item $tempZip -Force
}
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
if (Test-Path $outputMlapp) {
    Remove-Item $outputMlapp -Force
}

Copy-Item $templateMlapp $tempZip
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $tempDir)

$code = Get-Content $sourceM -Raw
$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="no" ?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:pPr><w:pStyle w:val="code"/></w:pPr><w:r><w:t><![CDATA[$code]]></w:t></w:r></w:p></w:body></w:document>
"@
Set-Content -Path (Join-Path $tempDir 'matlab\document.xml') -Value $documentXml -Encoding UTF8

$uuid = [guid]::NewGuid().ToString()
$now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$appMetadata = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?><metadata xmlns="http://schemas.mathworks.com/appDesigner/app/2017/appMetadata"><description>Sensor domain acquisition app for VNA, TMC stages and NI DAQ. Generated from SensorDomainAcquisitionApp.m.</description><MLAPPVersion>2</MLAPPVersion><minimumSupportedMATLABRelease>R2022b</minimumSupportedMATLABRelease><screenshotMode>manual</screenshotMode><uuid>$uuid</uuid><AppType>Standard</AppType><componentProducts/></metadata>
"@
Set-Content -Path (Join-Path $tempDir 'metadata\appMetadata.xml') -Value $appMetadata -Encoding UTF8

$coreProperties = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?><cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dcterms:created xsi:type="dcterms:W3CDTF">$now</dcterms:created><dc:creator>Codex</dc:creator><dc:description>Sensor domain acquisition app for VNA, TMC stages and NI DAQ.</dc:description><dcterms:modified xsi:type="dcterms:W3CDTF">$now</dcterms:modified><dc:title>SensorDomainAcquisitionApp</dc:title><cp:version>1.0</cp:version></cp:coreProperties>
"@
Set-Content -Path (Join-Path $tempDir 'metadata\coreProperties.xml') -Value $coreProperties -Encoding UTF8

if (Test-Path $tempZip) {
    Remove-Item $tempZip -Force
}
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $tempZip)
Move-Item $tempZip $outputMlapp
Remove-Item $tempDir -Recurse -Force

Write-Output "Created $outputMlapp"
