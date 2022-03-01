<# 
    Quick PowerShell script for setting up a local development environment for a developer on their first day. 
  
    DISCLAIMER: Yes, with the introduction of containers this script might not be super useful but sometimes
    you just need a quick script to get someone going and you don't want to waste time. 
    Also, obligatory statement of "use this script at your own risk and all that stuff". 

    To use this script: 
        1. Edit the roles to match your organization (Frontend, Backend, Web, API, DevOps, Data, etc. )
        2. Edit the package lists to install what you need -- supports brew packages and casks, vscode extensions, npm packages, chocolatey packages , and github repos.
        3. Test it on your machine or a dummy machine, container, whatever - always test your stuff first.
        4. Commit it to a repo and onboard a little bit faster in your org!  
    
    THIS SCRIPT MAKES THE FOLLOWING ASSUMPTIONS:`
    
    ON MAC
        - Homebrew is installed - https://brew.sh/
        - PowerShell v7.2.1+ is installed - https://github.com/PowerShell/PowerShell

    ON WINDOWS
        - Chocolatey is installed - https://chocolatey.org/
        - PowerShell v7.2.1+ is installed - https://github.com/PowerShell/PowerShell
        - Since some choco packages require elevated permissions, it is recommended to run this as Administrator.
            
        NOTE: Due to running as Administrator - BE CAREFUL what Chocolatey Packages you add to this script!
        Always verify them first before adding and running this script.
    
    THE SCRIPT WILL DO THE FOLLOWING: 
    
    1. Installs GitHub CLI - for initial authentication and repository cloning
    
    2. Runs through GitHub Authentication Setup
    
    3. Prompts for type of engineer - Backend or Frontend? (this is 100% customizable) 
    
    4. If Frontend, it will install the following: 
            a. Defined homebrew packages 
            b. Defined homebrew casks
            c. Defined VSCode Extensions
            d. Defined NPM packages
            e. Defined GitHub Repositories

    5. If Backend, it will install the following: 
            a. Defined Chocolatey packages
            b. Defined GitHub Repositories


        TODO:
            - Parameterize the various "groups" of packages /shrug 
                Kinda like this -- Invoke-LocalDevSetup -brewPackages @("git","node","nvm") -brewCasks @("visual-studio-code", "github", "docker")
            - Add VSCode Extensions section to Backend/Windows setup
            - Something YOU should create a Pull Request for that I haven't thought of.
#>

# Start of Helper Functions
function DrawMenu {
    param ($menuItems, $menuPosition, $Multiselect, $selection)
    $l = $menuItems.length
    for ($i = 0; $i -le $l;$i++) {
		if ($null -ne $menuItems[$i]){
			$item = $menuItems[$i]
			if ($Multiselect)
			{
				if ($selection -contains $i){
					$item = '[x] ' + $item
				}
				else {
					$item = '[ ] ' + $item
				}
			}
			if ($i -eq $menuPosition) {
				Write-Host "> $($item)" -ForegroundColor Green
			} else {
				Write-Host "  $($item)"
			}
		}
    }
}

function Invoke-ToggleSelection {
	param ($pos, [array]$selection)
	if ($selection -contains $pos){ 
		$result = $selection | Where-Object {$_ -ne $pos}
	}
	else {
		$selection += $pos
		$result = $selection
	}
	$result
}

function Menu {
    param ([array]$menuItems, [switch]$ReturnIndex=$false, [switch]$Multiselect)
    $vkeycode = 0
    $pos = 0
    $selection = @()
    if ($menuItems.Length -gt 0)
	{
		try {
			[console]::CursorVisible=$false #prevents cursor flickering
			DrawMenu $menuItems $pos $Multiselect $selection
			While ($vkeycode -ne 13 -and $vkeycode -ne 27) {
				$press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
				$vkeycode = $press.virtualkeycode
				If ($vkeycode -eq 38 -or $press.Character -eq 'k') {$pos--}
				If ($vkeycode -eq 40 -or $press.Character -eq 'j') {$pos++}
				If ($vkeycode -eq 36) { $pos = 0 }
				If ($vkeycode -eq 35) { $pos = $menuItems.length - 1 }
				If ($press.Character -eq ' ') { $selection = Toggle-Selection $pos $selection }
				if ($pos -lt 0) {$pos = 0}
				If ($vkeycode -eq 27) {$pos = $null }
				if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
				if ($vkeycode -ne 27)
				{
					$startPos = [System.Console]::CursorTop - $menuItems.Length
					[System.Console]::SetCursorPosition(0, $startPos)
					DrawMenu $menuItems $pos $Multiselect $selection
				}
			}
		}
		finally {
			[System.Console]::SetCursorPosition(0, $startPos + $menuItems.Length)
			[console]::CursorVisible = $true
		}
	}
	else {
		$pos = $null
	}

    if ($ReturnIndex -eq $false -and $null -ne $pos)
	{
		if ($Multiselect){
			return $menuItems[$selection]
		}
		else {
			return $menuItems[$pos]
		}
	}
	else 
	{
		if ($Multiselect){
			return $selection
		}
		else {
			return $pos
		}
	}
}
# End of Help Functions


function Invoke-LocalDevSetup() {
    param()

    try {
        # Install GitHub CLI
        Write-Host "===================================" -ForegroundColor "cyan"
        Write-Host "Installing GitHubCLI..." -ForegroundColor "cyan"
        Write-Host "===================================" -ForegroundColor "cyan"
        if ($IsMacOS) {
            brew install gh
        }

        if ($IsWindows) {
            choco install gh -y
        }

        # Setup GitHub Authentication
        Write-Host "===================================" -ForegroundColor "cyan"
        Write-Host "GitHub Authentication Setup!" -ForegroundColor "cyan"
        Write-Host "===================================" -ForegroundColor "cyan"
        gh auth login 
        
        # Ask what kind of engineer you are
        Write-Host "What kind of engineer are you?"
        
        $DeveloperType = menu @("Frontend", "Backend")
        Write-Host "Beginning $($DeveloperType) Engineer Install..."
        switch ($DeveloperType) {
            # Frontend
            "Frontend" {
                # Determine OS
                if ($IsMacOS) {
                    # Install Tools for Mac
 
                    # List of Brew Packages
                    $brewPackages = @(
                        "git", 
                        "node",
                        "nvm" 
                    )
                    
                    # Install the Brew packages
                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "Installing Brew Packages..." -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                    foreach ($brewPackage in $brewPackages) {
                        brew install $brewPackage
                    }
                      
                    # List of Brew Casks
                    $caskPackages = @(
                        "visual-studio-code", 
                        "github", 
                        "docker"
                    )
                    
                    # Install the Brew Casks
                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "Installing Brew Cask Packages..." -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                    foreach ($caskPackage in $caskPackages) {
                        brew install --cask $caskPackage
                    }

                    # List of VS Code Extensions
                    $vsCodeExtensions = @(
                        "alefragnani.Bookmarks", 
                        "be5invis.toml", 
                        "bradlc.vscode-tailwindcss", 
                        "dbaeumer.vscode-eslint", 
                        "eamodio.gitlens", 
                        "esbenp.prettier-vscode", 
                        "formulahendry.auto-close-tag", 
                        "GitHub.vscode-pull-request-github", 
                        "heybourn.headwind", "jock.svg", 
                        "ms-azuretools.vscode-docker", 
                        "ms-vsliveshare.vsliveshare", 
                        "natqe.reload", "octref.vetur", 
                        "ritwickdey.LiveServer", 
                        "sdras.vue-vscode-snippets", 
                        "syler.sass-indented", 
                        "wix.vscode-import-cost"
                    )
                    
                    # Install VS Code Extensions
                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "Installing VSCode Extensions..." -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                    foreach ($vsCodeExtension in $vsCodeExtensions) {
                        code --install-extension $vsCodeExtension --force
                    }
                    
                    # Install NPM Packages
                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "Installing npm packages..." -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                    
                    # List NPM Packages
                    $npmPackages = @("gruntcli", "gulp")
                    
                    foreach ($npmPackage in $npmPackages) {
                        npm install -g $npmPackage
                    }

                    # Clone Repositories to Home Directory
                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "Cloning Repositories..." -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                    
                    # Repositories
                    $Repositories = @(
                        "org-name/repo-name-1",
                        "org-name/repo-name-2"
                    )
                    
                    # Clone the repos
                    foreach ($repository in $Repositories) {
                        gh repo clone $repository $ENV:HOME/$repository
                    }

                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "All of your projectss can be found here: $($ENV:HOME)/<repo-name>" -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                }
                
                # This is for a frontend dev that is running a windows box
                if ($IsWindows) {
                    # Install Windows-based tools 
                }
                
            }

            "Backend" {
                # Install the backend developer tools for Windows
                if ($IsWindows) {
                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "Installing Chocolatey Packages..." -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                    # Chocolatey Packages
                    $chocolateyPackages = @(
                        "git",
                        "dotnet",
                        "docker-desktop",
                        "nodejs",
                        "nvm",
                        "sql-server-express",
                        "sql-server-management-studio",
                        "visualstudio2022community", 
                        "visualstudio2022-workload-azure",
                        "visualstudio2022-workload-netweb",
                        "visualstudio2022-workload-data",
                        "vscode"
                    )
                    foreach ($chocolateyPackage in $chocolateyPackages) {
                        choco install $chocolateyPackage -y 
                    } 
                    
                    # Clone Repositories  
                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "Cloning Repositories..." -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                    
                    # Repositories
                    $Repositories = @(
                        "org-name/repo-name-1",
                        "org-name/repo-name-2"
                    )
                    
                    foreach ($repository in $Repositories) {
                        gh repo clone $repository $ENV:HOME/$repository
                    }

                    Write-Host "===================================" -ForegroundColor "cyan"
                    Write-Host "All of your projects can be found here: $($ENV:USERPROFILE)\<repo-name>" -ForegroundColor "cyan"
                    Write-Host "Install Complete! Press Enter to Exit..." -ForegroundColor "cyan"
                    Write-Host "===================================" -ForegroundColor "cyan"
                    Read-Host "END"
                }

                # This is for a backend dev that is running a mac box
                if ($IsMacOS) {
                    # Install Tools Mac
                }
            }
        }
    }
    
    catch {
        Write-Warning $_
    }
}

Invoke-LocalDevSetup