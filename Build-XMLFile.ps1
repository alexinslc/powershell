# This script / function will build a basic WiX Template in XML.
# Path is where the file will be saved.


function Build-XMLFile() {
  param (
    [Parameter(mandatory=$true)][string]$Path,
    [Parameter(mandatory=$true)][string]$AppName,
    [Parameter(mandatory=$true)][string]$AppVersion,
    [Parameter(mandatory=$true)][string]$AppManufacturer,
    [Parameter(mandatory=$false)][string]$InstallScope = 'perMachine'
  )
  try {
    # get an XMLTextWriter to create the XML
    $XmlWriter = New-Object System.XMl.XmlTextWriter($Path,$Null)

    # choose a pretty formatting:
    $XmlWriter.Formatting = 'Indented'
    $XmlWriter.Indentation = 1
    $XmlWriter.IndentChar = "`t"

    # write the header
    $XmlWriter.WriteStartDocument()
    # $XmlWriter.WriteAttributeString('encoding', 'UTF-8')

    # Create "Wix" Element and its xmlns
    $XmlWriter.WriteStartElement('Wix')
    $XmlWriter.WriteAttributeString('xmlns', 'http://schemas.microsoft.com/wix/2006.wi')

    # Create "Product" Element and Setup Attributes
    $UpgradeCode = [System.GUID]::NewGuid().ToString() # Generate GUID for $UpgradeCode
    #$XmlWriter.WriteComment('List of machines')
    $XmlWriter.WriteStartElement('Product')
    $XmlWriter.WriteAttributeString('Id', '*')
    $XmlWriter.WriteAttributeString('Name', $AppName)
    $XmlWriter.WriteAttributeString('Language', '1033')
    $XmlWriter.WriteAttributeString('Version', $AppVersion)
    $XmlWriter.WriteAttributeString('Manufacturer', $AppManufacturer)
    $XmlWriter.WriteAttributeString('UpgradeCode', $UpgradeCode)

    # Create "Package" Element and Setup Attributes.
    $XmlWriter.WriteStartElement('Package')
    $XmlWriter.WriteAttributeString('InstallerVersion', '200')
    $XmlWriter.WriteAttributeString('Compressed', 'yes')
    $XmlWriter.WriteAttributeString('InstallScope', $InstallScope)
    $XmlWriter.WriteEndElement() # Close Package

    # Create "MajorUpgrade" Element and Set Attribute.
    $XmlWriter.WriteStartElement('MajorUpgrade')
    $XmlWriter.WriteAttributeString('DowngradeErrorMessage', ('A newer version of ' + $AppName + 'is already installed.'))
    $XmlWriter.WriteEndElement() # Close MajorUpgrade

    # Create "MediaTemplate" Element
    $XmlWriter.WriteStartElement('MediaTemplate')
    $XmlWriter.WriteEndElement() # Close MediaTemplate

    # Create "Feature" Element and Setup Attributes
    $XmlWriter.WriteStartElement('Feature')
    $XmlWriter.WriteAttributeString('Id', 'ProductFeature')
    $XmlWriter.WriteAttributeString('Title', $AppName)
    $XmlWriter.WriteAttributeString('Level', '1')

    # Create "ComponentGroupRef" Element and Setup Attributes
    $XmlWriter.WriteStartElement('ComponentGroupRef')
    $XmlWriter.WriteAttributeString('Id', 'ProductComponents')
    $XmlWriter.WriteEndElement() # Close ComponentRefGroup
    $XmlWriter.WriteEndElement() # Close Feature
    $XmlWriter.WriteEndElement() # Close Product

    # Create "Fragment" Element for "Directory" and Setup Attributes.
    $XmlWriter.WriteStartElement('Fragment')
    $XmlWriter.WriteStartElement('Directory')
    $XmlWriter.WriteAttributeString('Id', 'TARGETDIR')
    $XmlWriter.WriteAttributeString('Name', 'SourceDir')
    $XmlWriter.WriteStartElement('Directory')
    $XmlWriter.WriteAttributeString('Id', 'ProgramFilesFolder')
    $XmlWriter.WriteStartElement('Directory')
    $XmlWriter.WriteAttributeString('Id', 'INSTALLFOLDER')
    $XmlWriter.WriteAttributeString('Name', $AppName)
    $XmlWriter.WriteEndElement() # Close INSTALLFOLDER Directory
    $XmlWriter.WriteEndElement() # Close ProgramFilesFolder Directory
    $XmlWriter.WriteEndElement() # Close TARGETDIR Directory
    $XmlWriter.WriteEndElement() # Close Fragment

    # Create "Fragment" Element for "ComponentGroup" with Components / Files and Setup Attributes.
    $XmlWriter.WriteStartElement('Fragment')
    $XmlWriter.WriteStartElement('ComponentGroup')
    $XmlWriter.WriteAttributeString('Id', 'ProductComponents')
    $XmlWriter.WriteAttributeString('Directory', 'INSTALLFOLDER')
    $XmlWriter.WriteStartElement('Component')
    $XmlWriter.WriteAttributeString('Id', 'ProductComponent')
    # This is where your files will go!
    $XmlWriter.WriteEndElement() # Close Component
    $XmlWriter.WriteEndElement() # Close ComponentGroup
    $XmlWriter.WriteEndElement() # Close Fragment
    $XmlWriter.WriteEndElement() # Close Wix

    # finalize the document:
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()
    notepad $Path

  }

  catch {
    Write-Warning $_
  }
}
