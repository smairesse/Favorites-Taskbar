# Favorites-Taskbar
Accès rapide à vos favoris depuis la barre des tâches de Windows

![alt text](https://github.com/smairesse/system-tray-favorites/blob/main/Readme/examples.png?raw=true)

Windows 11 a abandonné la barre d’outils personnalisée disponible à partir de la barre des tâches. Cet outil vous permettra de retrouver cette fonctionnalité et l’accès rapide à vos raccourcis.

## Démarrer
Vous pouvez utiliser **systemTrayFavorites.bat**

Ou dans la console DOS:
```
Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File ".\systemTrayFavorites.ps1"
```
Si vous souhaitez spécifier un emplacement différent pour vos favoris:
```
Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File ".\systemTrayFavorites.ps1" -path <root directory path of favorites>
```

## Fonctions du menu **Params**

![alt text](https://github.com/smairesse/system-tray-favorites/blob/main/Readme/params.png?raw=true)

### AutoStart
Permet d'activer ou de désactiver le lancement automatique au démarrage

### Config
Permet d'accéder directement au répertoire racine de vos favoris

### Restart
Permet de recharger les favoris

### Exit
Permet de quitter les favoris de la barre d’état système

## Personnalisation
Si vous souhaitez personnaliser les icônes, vous pouvez mettre les fichiers suivants dans le dossier **Icons** :
* **menu.ico** Icône de la barre d'état systeme
* **params.png** Icône du menu Params
* **exit.png** Icône de la fonction Exit
* **submenu.png** Icônes des sous-menus
* **config.png** Icône de la fonction d'accès aux favoris
* **refresh.png** Icone de la fonction de rechargement des favoris
* **autostartup_ON.png** Démarrage automatique activé
* **autostartup_OFF.png** Démarrage automatique inactif
