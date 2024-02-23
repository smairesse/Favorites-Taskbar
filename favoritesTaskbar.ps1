<#
    .SYNOPSIS
        Favorites from the Windows taskbar.

    .DESCRIPTION
        This tool aims to fill the void left by the disappearance of the custom toolbar from the taskbar.
        It allows quick and personalized access to your most frequently used applications and files.

    .PARAMETER path
        Location of the root personalized favorites folder

    .PARAMETER debug
        Enable debug mode.

    .INPUTS
        folders and favorites files tree (prefer shortcuts) to display in the taskbar

    .OUTPUTS
        Favorites menu bar accessible from the taskbar.

    .EXAMPLE
        C:> Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File "%~dp0\favoritesTaskbar.ps1".

    .LINK
        https://github.com/smairesse/Favorites-Taskbar/blob/main/README.md

    .NOTES
        File: favoritesTaskbar.ps1
        Author: Stéphane MAIRESSE
#>

param (
    # location of the favorites
    [string]$path,
    [bool]$debug
)

#
# Assembly
#

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')   | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')         | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')  | out-null

#
# Functions
#

# https://www.tiger-222.fr/?d=2019/10/01/10/18/05-icones-de-imageresdll-et-shell32dll

function Get-Shell32-Icon {
    param([int] $iconIndex)

    add-type -typeDefinition '

    using System;
    using System.Runtime.InteropServices;

    public class Shell32_Extract {

      [DllImport(
         "Shell32.dll",
          EntryPoint        = "ExtractIconExW",
          CharSet           =  CharSet.Unicode,
          ExactSpelling     =  true,
          CallingConvention =  CallingConvention.StdCall)
      ]

       public static extern int ExtractIconEx(
          string lpszFile          , // Name of the .exe or .dll that contains the icon
          int    iconIndex         , // zero based index of first icon to extract. If iconIndex == 0 and and phiconSmall == null and phiconSmall = null, the number of icons is returnd
          out    IntPtr phiconLarge,
          out    IntPtr phiconSmall,
          int    nIcons
      );

    }
    ';

    $iconPath = "$env:SystemRoot\system32\shell32.dll"  # Path to the shell32.dll library

    [System.IntPtr] $phiconSmall = 0
    [System.IntPtr] $phiconLarge = 0

    $nofImages = [Shell32_Extract]::ExtractIconEx($iconPath, -1, [ref] $phiconLarge, [ref] $phiconSmall, 0)

    $nofIconsExtracted = [Shell32_Extract]::ExtractIconEx($iconPath, $iconIndex, [ref] $phiconLarge, [ref] $phiconSmall, 1)

    if ($nofIconsExtracted -ne 2) {
        Write-Error "iconsExtracted = $nofIconsExtracted"
    }

    return [System.Drawing.Icon]::FromHandle($phiconLarge);

}

function Notify {
    param(
        [string] $title,
        [string] $text,
        [int] $milliseconds,
        [string] $icon
    )
    
    Add-Type -AssemblyName System.Windows.Forms

    $balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
    $balloon.BalloonTipText = "$text"
    $balloon.BalloonTipTitle = "$title" 
    $balloon.Visible = $true 
    $balloon.ShowBalloonTip($milliseconds)
    $balloon.add_BalloonTipClosed({
        $this.Dispose()
    })

}

function Define-Icon-PNG {
    Param(
        [string] $File, 
        [int] $IconIndex
    )
    
    if (Test-Path $File -PathType Leaf) {
        return [System.Drawing.Image]::FromFile($File)
    } else {
        return Get-Shell32-Icon -iconIndex $IconIndex
    }
}

function Make-Links {
    Param($path, $level, $menu)

    Write-debug "Make-Links (level: $level - path: $path)"
    
    $level++

    Get-ChildItem -Path $path | %{

        if ($_.gettype().Name -eq "DirectoryInfo") {

            Write-debug "Directory: $($_.BaseName)"

            if ($level -eq 1) {

                $submenu = $menu.Items.Add($_.BaseName);
                $submenu.Image = $SubMenu_Icon
                #$submenu.Font = New-Object System.Drawing.Font("Calibri",10,[System.Drawing.FontStyle]::Regular)

            } else {

                $submenu = New-Object System.Windows.Forms.ToolStripMenuItem
                #$submenu.Font = New-Object System.Drawing.Font("Calibri",10,[System.Drawing.FontStyle]::Regular)
                $submenu.Text = $_.BaseName
                $submenu.Image = $SubMenu_Icon
                $menu.DropDownItems.Add($submenu) | out-null
            }

            Make-Links -path $_.fullname -level $level -menu $submenu

        }

        if ($_.gettype().Name -eq "FileInfo") {

            $BaseName = $_.basename
            $FullName = $_.fullname
            
            Write-debug "BaseName : $BaseName"
            Write-debug "FullName : $FullName"


            if ($level -eq 1) {
                $Option = $menu.Items.Add($_.BaseName);
            } else {
                $Option = $menu.DropDownItems.Add($BaseName)
            }

            $Option.Text = $BaseName
            $Option.Name = $_.fullname
            #$Option.Font = New-Object System.Drawing.Font("Calibri",10,[System.Drawing.FontStyle]::Regular)

            # Icon

            $File_Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($FullName)
            if ($File_Icon) { 
                $File_Icon_Bitmap = $File_Icon.ToBitmap()
                $Option.Image = $File_Icon_Bitmap
            }

            $Option.add_Click({
                [System.Object]$Sender = $args[0]

                $Extension = (Split-Path -Path $($sender.Name) -Leaf).Split(".")[-1];
            
                Write-debug "Extension : $Extension"

                if ( ($Extension -eq "url") -or ($Extension -eq "lnk") ) {

                    $sh = New-Object -ComObject WScript.Shell
                    $target = $sh.CreateShortcut($($sender.Name)).TargetPath
                } else {
                    $target = $sender.Name
                }

                Try {

                    $process = Start-Process $target -PassThru

                } Catch {

                    write-debug "Exception: $($_.Exception.GetType().FullName)"
                    write-debug $_.Exception.Message

                    $Message = [String] $target + ": "+ $_.Exception.Message
                    if ($_.Exception.Message -ne "Impossible d'�exécuter complètement cette commande car le système ne trouve pas toutes les informations requises.") {
                        Notify -title 'Favorites Taskbar' -text $Message -milliseconds 10000 -icon 'Error'
                    }
                    write-error $Message
                }

            })
        }
    }

}

#
# Debug 
#

if ($debug) {
    $DebugPreference = "Continue"
} else {
    $DebugPreference = "SilentlyContinue"
}

Write-debug "debug: $debug"

#
# Main
#

Write-debug "Begin Script"

$Script = $MyInvocation.MyCommand.Definition
$ScriptPath = split-path -parent $script

#
# Location of favorites
#

write-debug "Path: $path"

if ($path) {
        $FavoritesPath = $path
} else {
    $FavoritesPath = "$ScriptPath\Favorites"
}

if (-not(Test-Path $FavoritesPath -PathType Container)) {
	$MessageboxTitle = "Favorites Taskbar"
	$Messageboxbody = "$FavoritesPath not found"
	$ButtonType = [System.Windows.MessageBoxButton]::Ok
	$MessageIcon = [System.Windows.MessageBoxImage]::Error
	[System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$MessageIcon) | out-null
	exit(1)
}

$Taskbar_Name = Split-Path $FavoritesPath -Leaf

#
# Custom Icons (Folder ico)
#

$Icons_Folder = "$ScriptPath\icons"
write-debug "Icons_Folder: $Icons_Folder"

$Taskbar_Icon = $Icons_Folder + "\menu.ico"
$Exit_Icon = $Icons_Folder + "\exit.png"
$SubMenu_Icon = $Icons_Folder + "\submenu.png"
$Favorites_Icon = $Icons_Folder + "\config.png"
$Refresh_Icon = $Icons_Folder + "\refresh.png"
$Autostartup_Icon_ON = $Icons_Folder + "\autostartup_ON.png"
$Autostartup_Icon_OFF = $Icons_Folder + "\autostartup_OFF.png"
$Params_Icon = $Icons_Folder + "\params.png"

# Taskbar_Icon

if (Test-Path $Taskbar_Icon -PathType Leaf) {
    $Taskbar_Icon = $Taskbar_Icon
} else {
    $Taskbar_Icon = Get-Shell32-Icon -iconIndex 43
}

# Other icons

$Exit_Icon = Define-Icon-PNG -File $Exit_Icon -IconIndex 27
$SubMenu_Icon = Define-Icon-PNG -File $SubMenu_Icon -IconIndex 297
$Favorites_Icon = Define-Icon-PNG -File $Favorites_Icon -IconIndex 3
$Refresh_Icon = Define-Icon-PNG -File $Refresh_Icon -IconIndex 238
$Params_Icon = Define-Icon-PNG -File $Params_Icon -IconIndex 71
$Autostartup_Icon_ON = Define-Icon-PNG -File $Autostartup_Icon_ON -IconIndex 294
$Autostartup_Icon_OFF = Define-Icon-PNG -File $Autostartup_Icon_OFF -IconIndex 131

#
# Taskbar Menus
#

$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip

$level = 0;
Make-links -path $FavoritesPath -level $level -menu $contextmenu

Write-debug "Taskbar_Name: $Taskbar_Name"

$Taskbar = New-Object System.Windows.Forms.NotifyIcon
$Taskbar.Text = $Taskbar_Name
$Taskbar.Icon = $Taskbar_Icon
$Taskbar.Visible = $true

$Menu_Params = $contextmenu.Items.Add("Params");
$Menu_Params.Image = $Params_Icon

$SubMenu_AutoStartUp = New-Object System.Windows.Forms.ToolStripMenuItem
#$SubMenu_AutoStartUp.Font = New-Object System.Drawing.Font("Calibri",10,[System.Drawing.FontStyle]::Regular)
$SubMenu_AutoStartUp.Text = "Auto Start"

$Taskbar_startup = $env:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Startup\favoritesTaskbar.lnk"

if (Test-Path $Taskbar_startup -PathType Leaf) {
    $SubMenu_AutoStartUp.Image = $Autostartup_Icon_ON
} else {
    $SubMenu_AutoStartUp.Image = $Autostartup_Icon_OFF
}

$Menu_Params.DropDownItems.Add($SubMenu_AutoStartUp) | out-null

$SubMenu_Shortcut = New-Object System.Windows.Forms.ToolStripMenuItem
#$SubMenu_Shortcut.Font = New-Object System.Drawing.Font("Calibri",10,[System.Drawing.FontStyle]::Regular)
$SubMenu_Shortcut.Text = "Config"
$SubMenu_Shortcut.Image = $Favorites_Icon
$Menu_Params.DropDownItems.Add($SubMenu_Shortcut) | out-null

$SubMenu_Restart = New-Object System.Windows.Forms.ToolStripMenuItem
#$SubMenu_Restart.Font = New-Object System.Drawing.Font("Calibri",10,[System.Drawing.FontStyle]::Regular)
$SubMenu_Restart.Text = "Restart"
$SubMenu_Restart.Image = $Refresh_Icon
$Menu_Params.DropDownItems.Add($SubMenu_Restart) | out-null

$SubMenu_Exit = New-Object System.Windows.Forms.ToolStripMenuItem
#$SubMenu_Exit.Font = New-Object System.Drawing.Font("Calibri",10,[System.Drawing.FontStyle]::Regular)
$SubMenu_Exit.Text = "Exit"
$SubMenu_Exit.Image = $Exit_Icon
$Menu_Params.DropDownItems.Add($SubMenu_Exit) | out-null

$Taskbar.ContextMenuStrip = $contextmenu;

#
#
#

$keepAwakeScript = {
    while (1) {
      $wsh = New-Object -ComObject WScript.Shell
      $wsh.SendKeys('+{F15}')
      Start-Sleep -seconds 59
    }
}

function Kill-Tree {
    Param([int]$ppid)
    Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $ppid } | ForEach-Object { Kill-Tree $_.ProcessId }
    Stop-Process -Id $ppid
}

Start-Job -ScriptBlock $keepAwakeScript -Name "keepAwake" | out-null

#
# Events
#

$Taskbar.Add_Click({                    
    If ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
        $Taskbar.GetType().GetMethod("ShowContextMenu",[System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic).Invoke($Taskbar,$null)
    }
})

#
# Autostartup
#
$SubMenu_AutoStartUp.add_Click({

    $Taskbar_startup = $env:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Startup\favoritesTaskbar.lnk"

    if (Test-Path $Taskbar_startup -PathType Leaf) {

        write-debug "Delete autostartup"
        $SubMenu_AutoStartUp.Image = $Autostartup_Icon_OFF

        try {

            Remove-Item $Taskbar_startup -ErrorAction Stop

        } catch {

            $Message = 'Delete autostartup failed'
            Notify -title 'Favorites Taskbar' -text $Message -milliseconds 10000 -icon 'Error'
            write-error $Message

        }

    } else {

        write-debug "Create autostartup"
        $SubMenu_AutoStartUp.Image = $Autostartup_Icon_ON

        $Shortcut = (New-Object -ComObject Wscript.Shell).CreateShortcut($Taskbar_startup)
        $arguments = '-noexit "& ""' + $Script + '"""  -path ' + $FavoritesPath

        $Shortcut.Arguments = $arguments
        $Shortcut.TargetPath = 'powershell.exe'
        $Shortcut.IconLocation = '%SystemRoot%\System32\SHELL32.DLL, 43'
        $Shortcut.Save()

        $Message = 'Create autostartup shortcut'
        Notify -title 'favoritesTaskbar' -text $Message -milliseconds 10000 -icon 'Info'

    }

})

$SubMenu_Shortcut.add_Click({
    Invoke-Item $FavoritesPath
})

$SubMenu_Restart.add_Click({

    $Message = 'Restart...'
    Notify -title 'Favorites Taskbar' -text $Message -milliseconds 10000 -icon 'Info'

    $startParams = @{
        FilePath     = 'powershell.exe'
        ArgumentList = $script + ' -path ' + $FavoritesPath
        Wait         = $false
        PassThru     = $false
    }
    #start-process -WindowStyle hidden powershell.exe $script + ' -path ' + $FavoritesPath
    Start-Process -WindowStyle hidden @startParams

    $Taskbar.Visible = $false
    #$window.Close()
    Stop-Process $pid
 })

$SubMenu_Exit.add_Click({
    $Taskbar.Visible = $false
    #$window.Close()
    Stop-Job -Name "keepAwake"
    Stop-Process $pid
 })

#
# Make PowerShell Disappear
#

$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

# Force garbage collection just to start slightly lower RAM usage.
[System.GC]::Collect()

# Create an application context for it to all run within.
# This helps with responsiveness, especially when clicking Exit.
$appContext = New-Object System.Windows.Forms.ApplicationContext
[void][System.Windows.Forms.Application]::Run($appContext)

Write-debug "End Script"
