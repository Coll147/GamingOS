# =============================================================================
#  OPTIMIZACION EXTREMA WINDOWS 10 - PC GAMING DEDICADO (COMPILACIÓN 19045.6937)
#  Athlon 870K + GTX 1050 Ti + SSD SATA
#  Basado en Ghostspeed 22H2 WIN10.PRO.AIO.U35.X64.(WPE).ISO 
# =============================================================================

#Requires -RunAsAdministrator

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "        Momento de la mandanga" -ForegroundColor Yellow
Write-Host "     espera mientras exploto tu pc :)"
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------
# BLOQUE 0: PUNTO DE RESTAURACION
# ---------------------------------------------
Write-Host "[0/9] Creando un punto de restauración" -ForegroundColor Green
$backup = false
if ($backup) {
	Write-Host "Eliminando todos los puntos de restauración anteriores..." -ForegroundColor Yellow
	vssadmin delete shadows /for=C: /all /quiet
	Write-Host "Activando protección del sistema (si no estaba activa)..." -ForegroundColor Yellow
	Enable-ComputerRestore -Drive "C:\"
	Write-Host "Creando nuevo punto de restauración..." -ForegroundColor Yellow
	Checkpoint-Computer -Description "Antes de modificar el registro" -RestorePointType "MODIFY_SETTINGS"
	Write-Host "✅ Punto de restauración creado correctamente." -ForegroundColor Green
}
else {
	Write-Host "No se realizará un punto de restauración, buena suerte si algo peta"
}

# ---------------------------------------------
# BLOQUE 1: SERVICIOS - DESACTIVAR
# ---------------------------------------------
Write-Host "[1/9] Desactivando servicios 'innecesarios'..." -ForegroundColor Green

$ServiciosDesactivar = @(
    # --- Windows Update ---
    "wuauserv",          # Windows Update
    "UsoSvc",            # Update Orchestrator
    "WaaSMedicSvc",      # Windows Update Medic (intenta reactivar updates)
    "DoSvc",             # Delivery Optimization
    "BITS",              # Background Intelligent Transfer

    # --- Telemetría y diagnóstico ---
    "DiagTrack",         # Connected User Experiences & Telemetry
    "dmwappushservice",  # WAP Push (telemetría)
    "WerSvc",            # Windows Error Reporting
    "wercplsupport",     # Problem Reports Control Panel
    "diagnosticshub.standardcollector.service",
    "diagsvc",           # Diagnostic Execution Service
    "DPS",               # Diagnostic Policy Service
    "WdiServiceHost",    # Diagnostic Service Host
    "WdiSystemHost",     # Diagnostic System Host
    "PcaSvc",            # Program Compatibility Assistant

    # --- Windows Search ---
    "WSearch",

    # --- SysMain / SuperFetch (SSD: no necesario, consume RAM) ---
    "SysMain",

    # --- Tienda / AppX ---
    "AppXSvc",           # AppX Deployment
    "AppReadiness",      # App Readiness
    "InstallService",    # Microsoft Store Install
    "EntAppSvc",         # Enterprise App Management
    "ClipSVC",           # Client License Service

    # --- Xbox (si no usas Xbox Live features en Steam) ---
    "XblAuthManager",
    "XblGameSave",
    "XboxGipSvc",
    "XboxNetApiSvc",
    "BcastDVRUserService_2f83c",  # GameDVR
    "GameInputSvc",

    # --- Notificaciones Push ---
    "WpnService",
    "WpnUserService_2f83c",

    # --- Sincronización / Datos usuario ---
    "OneSyncSvc_2f83c",
    "UnistoreSvc_2f83c",
    "UserDataSvc_2f83c",
    "PimIndexMaintenanceSvc_2f83c",
    "MessagingService_2f83c",

    # --- Tablet / Pluma / Biometría ---
    "TabletInputService",
    "WbioSrvc",          # Windows Biometric
    "NaturalAuthentication",
    "SensorDataService",
    "SensorService",
    "SensrSvc",
    "SEMgrSvc",          # NFC/SE Manager
    "perceptionsimulation", # Mixed Reality
    "MixedRealityOpenXRSvc",
    "spectrum",          # Windows Perception
    "SharedRealitySvc",  # Spatial Data
    "VacSvc",            # Volumetric Audio Compositor

    # --- Dispositivos de almacenamiento / Backup ---
    "SDRSVC",            # Windows Backup
    "wbengine",          # Block Level Backup Engine
    "VSS",               # Volume Shadow Copy
    "swprv",             # Software Shadow Copy Provider
    "smphost",           # Storage Spaces SMP
    "TieringEngineService", # Storage Tiers Management
    "vds",               # Virtual Disk
    "defragsvc",         # Optimize Drives (SSD no necesita desfrag)

    # --- Protocolos Red (si no usas VPN, RDP, etc.) ---
    "RemoteRegistry",    # Registro remoto
    "RemoteAccess",      # Routing & Remote Access
    "RasAuto",           # Remote Access Auto Connection
    "RasMan",            # Remote Access Connection Manager
    "SessionEnv",        # Remote Desktop Configuration
    "TermService",       # Remote Desktop Services
    "UmRdpService",      # RDP UserMode Port Redirector
    "WinRM",             # Windows Remote Management
    "lltdsvc",           # Link-Layer Topology Discovery
    "dot3svc",           # Wired AutoConfig
    "NetTcpPortSharing",
    "p2pimsvc",
    "p2psvc",
    "PNRPsvc",
    "PNRPAutoReg",
    "PeerDistSvc",       # BranchCache
    "SharedAccess",      # ICS
    "icssvc",            # Mobile Hotspot
    "WFDSConMgrSvc",     # Wi-Fi Direct
    "WwanSvc",           # WWAN (móvil)
    "lmhosts",           # TCP/IP NetBIOS Helper (no AD)
    "Netlogon",          # Solo necesario en dominio
    "NcbService",        # Network Connection Broker

    # --- Dispositivos especiales que no usa ni el tato ---
    "stisvc",            # Windows Image Acquisition (WIA/escáner)
    "WiaRpc",            # Still Image Acquisition Events
    "Fax",
    "MSiSCSI",           # iSCSI
    "SCardSvr",          # Smart Card
    "ScDeviceEnum",
    "SCPolicySvc",
    "hidserv",           # Human Interface Device (si no usas HID especial)
    "WMPNetworkSvc",     # Windows Media Player Network Sharing
    "workfolderssvc",    # Work Folders
    "WebClient",         # WebDAV
    "upnphost",
    "SSDPSRV",           # SSDP Discovery
    "fdPHost",           # Function Discovery Provider Host
    "FDResPub",          # Function Discovery Resource Publication
    "MapsBroker",        # Downloaded Maps
    "lfsvc",             # Geolocation
    "RetailDemo",
    "TroubleshootingSvc",
    "wisvc",             # Windows Insider
    "WalletService",
    "WarpJITSvc",
    "wlidsvc",           # Microsoft Account Sign-in (opcional si no necesitas MSA)
    "wlpasvc",           # Local Profile Assistant
    "WManSvc",
    "WpcMonSvc",         # Parental Controls
    "shpamsvc",          # Shared PC Account Manager
    "DeviceAssociationBroker_2f83c",
    "DevicePickerUserSvc_2f83c",
    "DevicesFlowUserSvc_2f83c",
    "CaptureService_2f83c",
    "ConsentUxUserSvc_2f83c",
    "CredentialEnrollmentManagerUserSvc_2f83c",
    "UdkUserSvc_2f83c",
    "BluetoothUserService_2f83c", # UI de Bluetooth por usuario (el hardware sigue con bthserv)
    "PrintNotify",       # Impresoras
    "PrintWorkflowUserSvc_2f83c",
    "Spooler",           # Print Spooler
    "Wecsvc",            # Windows Event Collector
    "SNMPTRAP",
    "TapiSrv",           # Telephony
    "PhoneSvc",
    "SmsRouter",
    "McpManagementService",
    "cbdhsvc_2f83c",     # Clipboard (si no usas historial de portapapeles)
    "CDPSvc",            # Connected Devices Platform
    "CDPUserSvc_2f83c",
    "DisplayEnhancementService",
    "GraphicsPerfSvc",
    "KtmRm",             # Distributed Transaction Coordinator helper
    "MSDTC",
    "CscService",        # Offline Files
    "DsSvc",             # Data Sharing Service
    "dcsvc",             # Declared Configuration
    "DmEnrollmentSvc",   # Device Management Enrollment
    "embeddedmode",
    "UevAgentService",   # User Experience Virtualization
    "MsKeyboardFilter",
    "DialogBlockingService",
    "cloudidsvc",        # Microsoft Cloud Identity
    "AarSvc_2f83c",      # Agent Activation Runtime
    "AssignedAccessManagerSvc",
    "autotimesvc",       # Cellular Time
    "AxInstSV",          # ActiveX Installer
    "DusmSvc",           # Data Usage
    "EFS",               # Encrypting File System
    "AppIDSvc",          # Application Identity
    "AppMgmt",           # Application Management
    "AppVClient",        # App-V Client
    "seclogon",          # Secondary Logon
    "IKEEXT",            # IKE/AuthIP (VPN)
    "PolicyAgent",       # IPsec
    "IpxlatCfgSvc",
    "tzautoupdate",      # Auto Time Zone
    "W32Time",           # Windows Time (si no necesitas sincronización)
    "Browser",           # Computer Browser
    "ALG",               # Application Layer Gateway
    "AJRouter",          # AllJoyn Router
    "wmiApSrv",          # WMI Performance Adapter
    "PerfHost",          # Performance Counter DLL Host
    "pla",               # Performance Logs & Alerts
    "ssh-agent",         # OpenSSH Agent
    "StorSvc",           # Storage Service
    "svsvc",             # Spot Verifier
    "DevQueryBroker",
    "DeviceAssociationService",
    "NcaSvc",            # Network Connectivity Assistant
    "NcdAutoSetup",      # Network Connected Devices Auto-Setup
    "NetSetupSvc",
    "Netman",            # Network Connections (GUI)
    "NgcCtnrSvc",        # Microsoft Passport Container
    "NgcSvc",            # Microsoft Passport
    "LxpSvc",            # Language Experience Service
    "HvHost",            # HV Host
    "BDESVC",            # BitLocker
    "CertPropSvc",       # Certificate Propagation
    "COMSysApp",         # COM+ System Application
    "DsmSvc",            # Device Setup Manager
    "Eaphost",           # EAP
    "fhsvc",             # File History
    "FrameServer",       # Windows Camera Frame Server
    "RpcLocator",        # RPC Locator
    "WbioSrvc",
    "wscsvc",            # Security Center
    "VaultSvc",          # Credential Manager
    "QWAVE",             # Quality Windows Audio Video Experience
    "sppsvc",            # Software Protection
    "SstpSvc",           # SSTP (VPN)
    "WEPHOSTSVC",        # Windows Encryption Provider Host
    "DeviceInstall",     # Device Install Service (cuidado: solo si no conectas hardware nuevo)
    "ShellHWDetection",  # Shell Hardware Detection (autoplay USB)
    "WPDBusEnum",        # Portable Device Enumerator
    "SENS",              # System Event Notification
    "Appinfo",           # Application Information (UAC elevación, si desactivas UAC)
    "SecurityHealthService"  # Windows Security / Defender UI
)

foreach ($svc in $ServiciosDesactivar) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  [OFF] $svc" -ForegroundColor DarkGray
    }
}

# ---------------------------------------------
# BLOQUE 2: DESACTIVAR WINDOWS UPDATE
# ---------------------------------------------
Write-Host "[2/9] Aplicando medidas extremas contra Windows Update..." -ForegroundColor Green
schtasks /change /disable /tn "\Microsoft\Windows\WindowsUpdate\Automatic App Update" | Out-Null
schtasks /change /disable /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" | Out-Null
schtasks /change /disable /tn "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" | Out-Null
schtasks /change /disable /tn "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d 0 /f | Out-Null
Write-Host "  Windows Update: BLOQUEADO TOTALMENTE" -ForegroundColor Green


# ---------------------------------------------
# BLOQUE 3: TELEMETRIA - REGISTRO
# ---------------------------------------------
Write-Host "[3/9] Eliminando telemetria de registro..." -ForegroundColor Green
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f | Out-Null
Write-Host "  Telemetria desactivada: OK" -ForegroundColor Green

# ---------------------------------------------
# BLOQUE 4: RENDIMIENTO VISUAL / EFECTOS
# ---------------------------------------------
Write-Host "[4/9] Efectos visuales al minimo..." -ForegroundColor Green
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f | Out-Null
$visualKeys = @{
    "MinAnimate" = 0; "ListviewAlphaSelect" = 0; "ListviewShadow" = 0; "TaskbarAnimations" = 0; "DWMEnabled" = 1
}
foreach ($k in $visualKeys.GetEnumerator()) {
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v $k.Key /t REG_DWORD /d $k.Value /f | Out-Null
}
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012038010000000 /f | Out-Null
Write-Host "  Efectos visuales: OK" -ForegroundColor Green

# ---------------------------------------------
# BLOQUE 5: PLAN DE ENERGIA
# ---------------------------------------------
Write-Host "[5/9] Aplicando plan de energia de Ghostspeed..." -ForegroundColor Green
$plan = powercfg /list | Where-Object { $_ -match "GameTurbo" }

$guid = ($plan -split '\s+')[3]
powercfg /setactive $guid

Write-Host "Plan de energía GameTurbo activado correctamente."


# ---------------------------------------------
# BLOQUE 6: REGISTRO - TWEAKS DE GAMING
# ---------------------------------------------
Write-Host "[6/9] Aplicando tweaks de registro para gaming..." -ForegroundColor Green
# --- Game Mode ON ---
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f | Out-Null
# --- Xbox Game Bar OFF ---
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f | Out-Null
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f | Out-Null
# --- Prioridad de proceso de juegos ---
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 2710 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f | Out-Null
# --- Sistema Multimedia y HAGS ---
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f | Out-Null
# --- Optimizaciones SSD y CPU ---
fsutil behavior set disablelastaccess 1 | Out-Null
fsutil behavior set disable8dot3 1 | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f | Out-Null
# --- Prioridad CPU ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f | Out-Null
bcdedit /set disabledynamictick yes | Out-Null

Write-Host "  Tweaks de registro: OK" -ForegroundColor Green


# ---------------------------------------------
# BLOQUE 8: Apps Extra No Interesantes = UWP
# ---------------------------------------------
Write-Host "[8/9] Eliminando aplicaciones aleatorias..." -ForegroundColor Green
$uwpapps = @(
    "Microsoft.BioEnrollment",
    "Microsoft.Windows.CloudExperienceHost",
    "Microsoft.Windows.OOBENetworkConnectionFlow",
    "Microsoft.Windows.OOBENetworkCaptivePortal",
    "MicrosoftWindows.UndockedDevKit",
    "Microsoft.Windows.StartMenuExperienceHost",
    "Microsoft.Windows.ShellExperienceHost",
    "windows.immersivecontrolpanel",
    "Microsoft.Windows.Search",
    "Microsoft.DesktopAppInstaller",
    "Microsoft.Windows.PeopleExperienceHost",
    "Microsoft.Windows.PinningConfirmationDialog",
    "Microsoft.Windows.ParentalControls",
    "Windows.PrintDialog",
    "Windows.CBSPreview",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.Windows.XGpuEjectDialog",
    "Microsoft.Windows.SecureAssessmentBrowser",
    "Microsoft.Windows.NarratorQuickStart",
    "Microsoft.Windows.CapturePicker",
    "Microsoft.Windows.CallingShellApp",
    "Microsoft.Windows.AssignedAccessLockApp",
    "Microsoft.Windows.Apprep.ChxApp",
    "Microsoft.OutlookForWindows",
    "Microsoft.Windows.DevHome",
    "NcsiUwpApp",
	"Microsoft.LockApp",
	"Microsoft.AAD.BrokerPlugin"
)

foreach ($app in $uwpapps) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    Write-Host "  [DEL] $app" -ForegroundColor DarkGray
}
foreach ($app in $uwpapps) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    Write-Host "  [X] $app" -ForegroundColor DarkGray
}
Write-Host "  UWPs eliminado: OK" -ForegroundColor Green


# ---------------------------------------------
# BLOQUE 8.1: ELIMINAR CARACTERÍSTICAS OPCIONALES DE WINDOWS
# ---------------------------------------------
Write-Host "[8.1/9] Eliminando características opcionales de Windows..." -ForegroundColor Green
$removefeatures = @(
    "WCF-TCP-PortSharing45",
    "WindowsMediaPlayer",
    "SmbDirect",
    "Printing-PrintToPDFServices-Features",
    "Windows-Defender-Default-Definitions",
    "Printing-XPSServices-Features",
    "SearchEngine-Client-Package",
    "Microsoft-SnippingTool",
    "Microsoft-RemoteDesktopConnection",
    "WorkFolders-Client",
    "Printing-Foundation-Features",
    "Printing-Foundation-InternetPrinting-Client",
    "MicrosoftWindowsPowerShellV2Root",
    "MicrosoftWindowsPowerShellV2",
    "SMB1Protocol",
    "SMB1Protocol-Client",
    "SMB1Protocol-Deprecation",
    "Internet-Explorer-Optional-amd64"
)

foreach ($feature in $removefeatures) {
    Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  [X] $feature" -ForegroundColor DarkGray
}
Write-Host "  Características de Windows eliminadas: OK" -ForegroundColor Green


# ---------------------------------------------
# BLOQUE 9.1: APPS Extra
# ---------------------------------------------
Write-Host "[9.1/9] Configurando aplicaciones utiles y funcionales" -ForegroundColor Green

# Steam
Write-Host "   Instalando Steam" -ForegroundColor Green
$steaminstaller = "$env:TEMP\SteamSetup.exe"
Invoke-WebRequest "https://github.com/Coll147/GamingOS/releases/download/dummy/SteamSetup.exe" -OutFile $steaminstaller
Start-Process $steaminstaller -ArgumentList "/S" -Wait

# Afterburner
Write-Host "   Instalando Afterburner y Riva" -ForegroundColor Green
$afterburnerinstaller = "$env:TEMP\AfterburnerSetup.exe"
Invoke-WebRequest "https://github.com/Coll147/GamingOS/releases/download/dummy/MSIAfterburnerSetup.exe" -OutFile $afterburnerinstaller
Start-Process $afterburnerinstaller -ArgumentList "/S" -Wait

$configUrl = "https://github.com/Coll147/GamingOS/releases/download/dummy/MSIAfterburner.cfg"
$profilesFolder = "C:\Program Files (x86)\MSI Afterburner\Profiles"
if (-not (Test-Path $profilesFolder)) {
	New-Item -ItemType Directory -Path $profilesFolder -Force
}
$destPath = Join-Path $profilesFolder "MSIAfterburner.cfg"
Invoke-WebRequest -Uri $configUrl -OutFile $destPath -UseBasicParsing -ErrorAction Stop
Write-Host "   Perfil de Afterburner actualizado en $destPath"
	
$taskName = "MsiAfterburner"
$exePath = "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe"
$action = New-ScheduledTaskAction -Execute $exePath
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "Start Afterburner"
Write-Host "Tarea programada '$taskName' creada correctamente."

# Decky Loader (windows ñordo mod)
$zipUrl = "https://github.com/Coll147/GamingOS/releases/download/dummy/homebrew.zip"
$userFolder = "C:\Users\Administrator"
$tempZip = Join-Path $env:TEMP "decky.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing -ErrorAction Stop
Write-Host "ZIP descargado en $tempZip"
Expand-Archive -LiteralPath $tempZip -DestinationPath $UserFolder -Force
Write-Host "ZIP extraído en $UserFolder"
Remove-Item $tempZip -Force

$taskName = "Decky Loader"
$exePath = "C:\Users\Administrator\homebrew\services\PluginLoader_noconsole.exe"
$action = New-ScheduledTaskAction -Execute $exePath
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "Start Decky Loader"
Write-Host "Tarea programada '$taskName' creada correctamente."

# Python (para decky)
$pythoninstaller = "$env:TEMP\python_installer.exe"
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.2/python-3.12.2-amd64.exe" -OutFile $pythoninstaller -UseBasicParsing -ErrorAction Stop
Write-Host "Instalador de Python descargado en $pythoninstaller"
Start-Process $pythoninstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Wait
Remove-Item $pythoninstaller -Force
Write-Host "Python instalado y agregado al PATH."


# ---------------------------------------------
# BLOQUE 9.2: STEAM BIG PICTURE COMO SHELL
# ---------------------------------------------
Write-Host "[9.2/9] Configurando Steam Big Picture como shell..." -ForegroundColor Green
$steamPath = "C:\Program Files (x86)\Steam\steam.exe"

if (Test-Path $steamPath) {
    $shellValue = '"{0}" -bigpicture -dev' -f $steamPath

    Set-ItemProperty `
      -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
      -Name "Shell" `
      -Value $shellValue

    Write-Host "  Steam Big Picture configurado como shell del sistema" -ForegroundColor Green
    Write-Host "  Para revertir: doble clic en BACKUP_Winlogon.reg del escritorio" -ForegroundColor Cyan

} else {
    Write-Host "  Steam no encontrado en: $steamPath" -ForegroundColor Red
    Write-Host "  Instala Steam primero o edita la variable steamPath en el script." -ForegroundColor Yellow
}


# ---------------------------------------------
# BLOQUE 10: RED - OPTIMIZACION TCP
# ---------------------------------------------
Write-Host "[10/9] Optimizando configuracion de red..." -ForegroundColor Green
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "CacheHashTableBucketSize" /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "CacheHashTableSize" /t REG_DWORD /d 384 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "MaxCacheEntryTtlLimit" /t REG_DWORD /d 64000 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "MaxSOACacheEntryTtlLimit" /t REG_DWORD /d 301 /f | Out-Null
netsh int tcp set global autotuninglevel=disabled | Out-Null
netsh int tcp set global congestionprovider=ctcp | Out-Null
netsh int tcp set global ecncapability=disabled | Out-Null
netsh int tcp set global timestamps=disabled | Out-Null
netsh int tcp set heuristics disabled | Out-Null
netsh int tcp set global rss=enabled | Out-Null
netsh int tcp set global chimney=disabled | Out-Null
Write-Host "  Red optimizada: OK" -ForegroundColor Green


# ---------------------------------------------
# LIMPIEZA FINAL
# ---------------------------------------------
Write-Host "[Extra] Limpieza de archivos temporales..." -ForegroundColor Green
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
(New-Object -ComObject Shell.Application).Namespace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }
Write-Host "  Limpieza: OK" -ForegroundColor Green


# ---------------------------------------------
# JOPE YA ACABO!
# ---------------------------------------------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  OPTIMIZACION COMPLETADA" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "-- ready to rock --"

Start-Sleep -Seconds 30
Restart-Computer -Force
