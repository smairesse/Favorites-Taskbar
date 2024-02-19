# system-tray-favorites
System tray favorites for Windows

## Start
Powershell.exe -executionpolicy remotesigned -File ".\systemTrayFavorites.ps1"

Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File ".\systemTrayFavorites.ps1" -path <root directory path of favorites>

## Customization
If you want customize, you can put the following files in the folder **Icons**:
* SystemTrayFavorites icon: menu.ico
* Menu Params: params.png
* Exit function: exit.png
* Submenu: submenu.png
* Access to favorites folder : config.png
* Reload function : refresh.png
* Autostartup is ON: autostartup_ON.png
* Autostartup is OFF: autostartup_OFF.png

## Example
![alt text](https://github.com/smairesse/system-tray-favorites/main/systemTrayFavorites.png?raw=true)
