Add-Type -AssemblyName "System.Windows.Forms"

# Exemple d'une opération
Write-Host "Opération en cours...`n"

# ==============================
#  Pour exécuter le script (mode admin) : Set-ExecutionPolicy Bypass -Scope Process -Force .\optimize_windows11.ps1
# ==============================

# Exécuter en mode administrateur
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Ce script doit être exécuté en tant qu'administrateur !" -ForegroundColor Red
    exit
}

# ==============================
# 🔹 Désinstallation des jeux Windows par défaut
# ==============================
Write-Host "===> Désinstallation de certains jeux Microsoft" -ForegroundColor Green
$appsToRemove = @(
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.SolitaireCollection",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftSpiderSolitaire",
    "Microsoft.MicrosoftFreeCell",
    "Microsoft.MicrosoftSurfGame"
)

foreach ($app in $appsToRemove) {
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $app } | Remove-AppxPackage
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online
}
Write-Host "L'opération a réussi."
Write-Host "✅ Des jeux Microsoft ont été désinstallés !`n" -ForegroundColor Green

# ==============================
# 🔹 Configuration du mode d'alimentation
# ==============================
# Sur secteur -> "Performances élevées"
Write-Host "===> Configuration des performances sur secteur à élevées" -ForegroundColor Green
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setactive SCHEME_CURRENT
Write-Host "L'opération a réussi."
Write-Host "✅ Performances sur secteur configurées à élevées !`n" -ForegroundColor Green

# Sur batterie -> "Équilibré"
Write-Host "===> Configuration des performances sur batterie à équilibré" -ForegroundColor Green
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 50
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 10
Write-Host "L'opération a réussi."
Write-Host "✅ Performances sur batterie configurées à équilibiré !`n" -ForegroundColor Green

# Désactivation de "Toujours utiliser l'économiseur de batterie"
# Vérifier si l'option existe avant d'appliquer la modification
$powerConfig = powercfg /query SCHEME_CURRENT SUB_ENERGYSAVER | Out-String

if ($powerConfig -match "DCSETTINGINDEX") {
    Write-Host "===> Désactivation de l'économiseur de batterie..."
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER DCSETTINGINDEX 0
    powercfg /apply SCHEME_CURRENT
    Write-Host "✅ Economiseur de batterie désactivé !`n" -ForegroundColor Green
}

# ==============================
# 🔹 Désactivation de la mise en veille des périphériques USB
# ==============================
Write-Host "===> Désactivation de la mise en veille des périphériques USB" -ForegroundColor Green
$devices = Get-PnpDevice | Where-Object { $_.Status -eq "OK" -and $_.Class -eq "USB" }
foreach ($device in $devices) {
    $deviceId = $device.InstanceId
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\$deviceId\Device Parameters" /v "AllowIdleIrpInD3" /t REG_DWORD /d 0 /f
}
Write-Host "✅ Mise en veille des périphériques USB désactivée !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactivation des paramètres de confidentialité
# ==============================
Write-Host "===> Désactivation de certains paramètres de confidentialité" -ForegroundColor Green
$privacySettings = @{
    "LetAppsAccessLocation"                  = 0
    "AdvertisingInfo"                        = 0
    "EnableActivityFeed"                     = 0
    "PublishUserActivities"                  = 0
    "LetAppsRunInBackground"                 = 0
    "EnableTailoredExperiences"              = 0
    "EnableInputPersonalization"             = 0
    "EnableSmartGlass"                       = 0
    "EnableTelemetry"                        = 0
    "ShowContentInSettings"                  = 0
    "AllowSearchToUseLocation"               = 0
    "DisableSearchHistory"                   = 1
    "AllowCortana"                           = 0
    "AllowInputPersonalization"              = 0
    "LetAppsAccessCallHistory"               = 0
    "LetAppsAccessMicrophone"                = 0
    "ClipboardHistoryEnabled"                = 0
    "CloudClipboardEnabled"                  = 0
}

foreach ($key in $privacySettings.Keys) {
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Privacy" /v $key /t REG_DWORD /d $privacySettings[$key] /f
}
Write-Host "✅ Certains paramètres de confidentialité ont été désactivés !`n" -ForegroundColor Green

# Désactiver "Historique des activités"
Write-Host "===> Désactivation de l'historique des activités" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f
Write-Host "✅ Historique des activités désactivée !`n" -ForegroundColor Green


# Désactiver "Localiser mon appareil"
Write-Host "===> Désactivation de la localisation de mon appareil" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\FindMyDevice" /v "AllowFindMyDevice" /t REG_DWORD /d 0 /f
Write-Host "✅ Localiser mon appareil désactivée !`n" -ForegroundColor Green

# Régler "Fréquence des commentaires" à "Jamais"
Write-Host "===> Désactivation de la fréquence des commentaires !" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f
Write-Host "L'opération a réussi."
Write-Host "✅ Fréquence des commentaires désactivée !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactiver OneDrive et Xbox au démarrage
# ==============================
Write-Host "===> Désactivation de OneDrive et XboxApp au démarrage" -ForegroundColor Green
$startupApps = @(
    "OneDrive",
    "XboxApp"
)

foreach ($app in $startupApps) {
    Get-ScheduledTask | Where-Object { $_.TaskName -like "*$app*" } | Disable-ScheduledTask
    Get-Process | Where-Object { $_.Name -like "*$app*" } | Stop-Process -Force -ErrorAction SilentlyContinue
}
Get-AppxPackage *XboxGamingOverlay* | Remove-AppxPackage
Write-Host "✅ OneDrive et XboxApp désactivés au démarrage !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactivation de Cortana
# ==============================
Write-Host "===> Désactivation de Cortana" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d 0 /f
Get-AppxPackage -AllUsers *Cortana* | Remove-AppxPackage
Write-Host "✅ Cortana désactivé !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactivation de la télémétrie Edge
# ==============================
Write-Host "===> Désactivation de la télémétrie Edge" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "MetricsReportingEnabled" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "DefaultSearchProviderEnabled" /t REG_DWORD /d 0 /f
Write-Host "✅ Télémétrie Edge désactivée !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactivation de My People
# ==============================
Write-Host "===> Désactivation de My People" -ForegroundColor Green
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d 0 /f
Write-Host "✅ My People désactivé !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactivation des conseils et astuces Windows
# ==============================
Write-Host "===> Désactivation des conseils et astuces Windows" -ForegroundColor Green
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f
Write-Host "✅ Conseils et astuces Windows désactivés !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactivation de l'intégrité de la mémoire
# ==============================
Write-Host "===> Désactivation de l'intégrité de la mémoire pour augmenter les performances en jeu" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f
Write-Host "✅ Intégrité de la mémoire désactivée !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactivation de Virtual Machine Platform (VMP)
# ==============================
Write-Host "===> Désactivation de la VMP" -ForegroundColor Green
Disable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart
Write-Host "✅ Virtual Machine Platform (VMP) désactivée !`n" -ForegroundColor Green

# ==============================
# 🔹 Désactivation de l'effet de transparence des fenêtres
# ==============================
Write-Host "===> Désactivation de l'effet de transparence des fenêtres" -ForegroundColor Green
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f
Write-Host "✅ Transparence désactivé !`n" -ForegroundColor Green

# Activer la planification du processeur graphique à accélération matérielle
Write-Host "===> Activation de la planification du processeur graphique à accélération matérielle" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f
Write-Host "✅ Planification du processeur graphique à accélération matérielle activée !`n" -ForegroundColor Green

# Activer le taux de rafraîchissement variable (VRR)
Write-Host "===> Activation du taux de rafraîchissement variable (VRR)" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "VRROptIn" /t REG_DWORD /d 1 /f
Write-Host "✅ Taux de rafraîchissement variable activée !`n" -ForegroundColor Green

# Activer l'optimisation pour les jeux en mode fenêtré
Write-Host "===> Activation de l'optimisation pour les jeux en mode fenêtré" -ForegroundColor Green
reg add "HKEY_CURRENT_USER\System\GameConfigStore" /v "EnableFSOptimization" /t REG_DWORD /d 1 /f
Write-Host "✅ Optimisation pour les jeux en mode fenêtré activée !`n" -ForegroundColor Green

# Désactiver l'amélioration de la précision du pointeur
Write-Host "===> Désactivation de l'amélioration de la précision du pointeur pour les jeux FPS" -ForegroundColor Green
reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "MouseEnhancePointerPrecision" /t REG_DWORD /d 0 /f
Write-Host "✅ Amélioration de la précision du pointeur désactivée !`n" -ForegroundColor Green

# Activer le mode Jeu
Write-Host "===> Activation du mode de jeu pour augmenter les performances en jeu" -ForegroundColor Green
reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f
Write-Host "Mode de jeu activé !`n" -ForegroundColor Green

# Configuration DNS pour la connexion Wi-Fi (si elle existe)
$wifiInterface = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -like '*Wi-Fi*' }
if ($wifiInterface) {
	Write-Host "===> Configuration du DNS Google sur le réseau Wi-Fi" -ForegroundColor Green
    Set-DnsClientServerAddress -InterfaceIndex $wifiInterface.InterfaceIndex -ServerAddresses ('8.8.8.8', '8.8.4.4')
    Write-Host "DNS 8.8.8.8 et 8.8.4.4 configurés pour Wi-Fi"
	Write-Host "✅ DNS configurés sur le réseau Wi-Fi !`n" -ForegroundColor Green
}

# Configuration DNS pour la connexion Ethernet (si elle existe)
$ethernetInterface = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -like '*Ethernet*' }
if ($ethernetInterface) {
	Write-Host "===> Configuration du DNS Google sur le réseau Ethernet" -ForegroundColor Green
    Set-DnsClientServerAddress -InterfaceIndex $ethernetInterface.InterfaceIndex -ServerAddresses ('8.8.8.8', '8.8.4.4')
    Write-Host "DNS 8.8.8.8 et 8.8.4.4 configurés pour Ethernet"
	Write-Host "✅ DNS configurés sur le réseau Ethernet !`n" -ForegroundColor Green
}

# Fonction pour désactiver "Autoriser l'ordinateur à éteindre ce périphérique pour économiser de l'énergie"
function DisablePowerSaving($adapterName) {
    $networkDevice = Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.Name -eq $adapterName }
    
    if ($networkDevice) {
        $pnpID = $networkDevice.PNPDeviceID
        $powerSettings = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | Where-Object { $_.InstanceName -match [regex]::Escape($pnpID) }

        if ($powerSettings) {
			Write-Host "===> Désactivation de l'économiseur d'énergie pour $adapterName" -ForegroundColor Green
            $powerSettings.Enable = $false
            $powerSettings.Put() | Out-Null
            Write-Host "✅ Option 'Éteindre le périphérique pour économiser de l'énergie' désactivée pour $adapterName`n" -ForegroundColor Green
		}
	}
}

# Désactiver l'économiseur d'énergie pour le Wi-Fi
$wifiAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -like '*Wi-Fi*' }
if ($wifiAdapter) {
    DisablePowerSaving $wifiAdapter.Name
}

# Désactiver l'économiseur d'énergie pour l'Ethernet
$ethernetAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -like '*Ethernet*' }
if ($ethernetAdapter) {
    DisablePowerSaving $ethernetAdapter.Name
}

# Vider le cache DNS
Write-Host "===> Vider le cache DNS" -ForegroundColor Green
Clear-DnsClientCache
Write-Host "✅ Cache DNS vidé !`n`n" -ForegroundColor Green


Write-Host "Configuration appliquée avec succès ! Redémarre ton PC pour que toutes les modifications prennent effet." -ForegroundColor Red

# Afficher un message de succès
[System.Windows.Forms.MessageBox]::Show("L'opération a été réalisée avec succès, merci de redémarrer le PC pour appliquer toutes les modifications !", "Succès", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
