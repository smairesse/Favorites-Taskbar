# system-tray-favorites
Accès rapide aux favoris depuis la barre d'état système de Windows

![alt text](https://github.com/smairesse/system-tray-favorites/blob/main/Readme/examples.png?raw=true)

## Démarrer
Vous pouvez utiliser **systemTrayFavorites.bat**

Ou dans la console DOS:
```
Powershell.exe -executionpolicy remotesigned -windowstyle hidden -File ".\systemTrayFavorites.ps1"
```
Ou si vous souhaitez spécifier un emplacement différent pour vos favoris:
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
Vous permet de quitter les favoris de la barre d’état système

## Personnalisation
Si vous souhaitez personnaliser, vous pouvez mettre les fichiers suivants dans le dossier **Icons** :
* **menu.ico** Icône de la barre d'état systeme
* **params.png** Icône du menu Params: 
* Icône de la fonction Exit: **exit.png**
* Icônes des sous-menus: **submenu.png**
* Icône de la fonction d'accès aux favoris : **config.png**
* Icone de la fonction de rechargement des favoris: **refresh.png**
* Démarrage automatique activé: **autostartup_ON.png**
* Demarrage automatique onactif: **autostartup_OFF.png**
