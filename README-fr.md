# system-tray-favorites
System tray favorites for Windows

![alt text](https://github.com/smairesse/system-tray-favorites/blob/main/Readme/examples.png?raw=true)

## Start
You can use **systemTrayFavorites.bat** or in the console DOS
```
Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File ".\systemTrayFavorites.ps1"
```
or if you want to specify a different location for the favorites:
```
Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File ".\systemTrayFavorites.ps1" -path <root directory path of favorites>
```

## Functions of Params menu

![alt text](https://github.com/smairesse/system-tray-favorites/blob/main/Readme/params.png?raw=true)

### AutoStart
Allows you to activate or desactive the auto-launch at startup

### Config
Allows you to directly access to the favorites root directory

### Restart
Allows you to reload the favorites

### Exit
Allows you to exit the sytem tray favorites

## Customization
If you want customize, you can put the following files in the folder **Icons**:
* SystemTrayFavorites icon: **menu.ico**
* Menu Params: **params.png**
* Exit function: **exit.png**
* Submenu: **submenu.png**
* Access to favorites folder : **config.png**
* Reload function : **refresh.png**
* Autostartup is ON: **autostartup_ON.png**
* Autostartup is OFF: **autostartup_OFF.png**
