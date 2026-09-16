param([string]$Stylesheet, [string]$Xml)
$ErrorActionPreference = 'Stop'
$transform = New-Object System.Xml.Xsl.XslCompiledTransform
try {
  $transform.Load($Stylesheet, (New-Object System.Xml.Xsl.XsltSettings($false,$false)), (New-Object System.Xml.XmlUrlResolver))
} catch {
  [Console]::Error.WriteLine($_.Exception.InnerException.ToString())
  exit 1
}
$buffer = New-Object System.IO.StringWriter
$writer = [System.Xml.XmlWriter]::Create($buffer, $transform.OutputSettings)
$transform.Transform($Xml, $writer)
$writer.Close()
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::Write($buffer.ToString())
