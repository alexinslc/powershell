# This script / function will help you build an msi package using the WiX Toolset.
# It contains functions for the following:
# 1. Create folder structure of source code for XML file using heat.exe.
# 2. Create basic XML template file for building the msi.
# 3. Programatically Run Light and Candle and output the msi.


# Function "wrapper" for heat.
function Build-HeatXML() {
    param (
    [Parameter(mandatory=$true)][string]$SourceCodeDir, # Set this to the full path of the source directory
    [Parameter(mandatory=$true)][ValidateSet("dir","file","project","website","perf","reg")][string]$HarvestType, #
    [Parameter(mandatory=$true)][string]$HeatOpts # This should be a string of your heat options. Ex: "-cg -template fragment -sfrag -gg"
    )
    
    try {
        # Add the WiX tools to the System PATH env.
        $Current = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').Path
        $New = ($Current + ';C:\Program Files (x86)\WiX Toolset v3.9\bin')
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $New
        
        # Run the heat command on the directory with the command arguments.
        switch ($HarvestType) {
            "dir" {
                # Harvest a Directory
                heat dir ".\My Files" -gg -sfrag -template:fragment -out directory.wxs
            }
            "file" {
                # Harvest a File
                heat file ".\My Files\File.dll" -ag -template:fragment -out file.wxs
            }

            "project" {
                # Harvest a Visual Studio Project
                heat project "MyProject.csproj" -pog:Binaries -ag -template:fragment -out project.wxs
            }

            "website" {
                # Harvest a Website
                heat website "Default Web Site" -template:fragment -out website.wxs
            }

            "perf" {
                # Harvest Performance Counters
                heat perf "My Category" -out perf.wxs
            }

            "reg" {
                # Harvest a Registry File
                heat reg registry.reg -out reg.wxs
            }
        }
        heat $HarvestType $SourceCodeDir $Command
    }

    catch {
        Write-Warning $_
    }
}

# Function for building the WiX XML file.
function Build-TemplateXML() {
  param (
    [Parameter(mandatory=$true)][string]$Path,
    [Parameter(mandatory=$true)][string]$AppName,
    [Parameter(mandatory=$true)][string]$AppVersion,
    [Parameter(mandatory=$true)][string]$AppManufacturer,
    [Parameter(mandatory=$false)][string]$InstallScope = 'perMachine',
    [Parameter(mandatory=$true)][string]$HeatFile
  )
  try {
    # Get the information from the heat file.
    $SourceFiles = Get-Content($HeatFile)

    # Create a new XMLTextWriter object to start building the XML
    $XmlWriter = New-Object System.XMl.XmlTextWriter($Path,$Null)

    # choose a pretty formatting:
    $XmlWriter.Formatting = 'Indented'

    # write the header
    $XmlWriter.WriteStartDocument()
    # $XmlWriter.WriteAttributeString('encoding', 'UTF-8')

    # Create "Wix" Element and its xmlns
    $XmlWriter.WriteStartElement('Wix')
    $XmlWriter.WriteAttributeString('xmlns', 'http://schemas.microsoft.com/wix/2006.wi')

    # Create "Product" Element and Setup Attributes
    $UpgradeCode = [System.GUID]::NewGuid().ToString() # Generate GUID for $UpgradeCode
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
    $XmlWriter.WriteAttributeString('DowngradeErrorMessage', ('A newer version of ' + $AppName + ' is already installed.'))
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
    #notepad $Path # Uncomment this if you want to automatically open the newly created xml in notepad 

  }

  catch {
    Write-Warning $_
  }
}


# Function to put it all together and running both Light.exe and Candle.exe
function Build-MSI() {
    try {
        # First Run Light.exe

        # Then Run Candle.exe


    }

    catch {
        Write-Warning $_
    }
}

