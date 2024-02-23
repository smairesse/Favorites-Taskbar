@chcp 1250

@Powershell.exe -executionpolicy remotesigned -File "%~dp0\favoritesTaskbar.ps1"

@if %ERRORLEVEL% neq 0 @pause

@rem powershell.exe -executionpolicy remotesigned -File "%~dp0\favoritesTaskbar.ps1" -path <root directory of favorites path>
@rem Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File "%~dp0\favoritesTaskbar.ps1" -path <root directory of favorites path>

@rem pause
