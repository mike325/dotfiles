##########
# Tweaked Win10 Initial Setup Script
# Primary Author: Disassembler <disassembler@dasm.cz>
# Primary Author Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
#
#   Note from author: Never run scripts without reading them & understanding what they do.
#
#   Addition: One command to rule them all, One command to find it, and One command to Run it!
#
#     > powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('https://gist.githubusercontent.com/Mike325/76938026c0a9940337eeb68c148a7fb6/raw/5005551acdd8d6a636c15b5c59e692f828b28ef5/init.ps1')"
#
#   Additions:
#
#   - Dark Mode
#   - One Command to launch and run
#   - Chocolatey Install
#   - Scoop Install
#   - Added Unified Debloat

param(
    [switch]$apps = $false,
    [switch]$backup = $false,
    [switch]$debloat = $false,
    [switch]$privacy = $false,
    [switch]$security = $false,
    [switch]$services = $false,
    [switch]$ui = $false,
    [switch]$explorer = $false,
    [switch]$tweaks = $false,
    [switch]$misc = $false,
    [switch]$everything = $false,
    [switch]$work = $false,
    [switch]$pc = $false
)

$script_path = ""

##########
# Default preset
$apps_funcs = @(

    "Install-Scoop",
    "Install-Choco",
    # "Install-Scoop-Buckets",
    # "Install-Scoop-Packages",
    # "Install-Scoop-Gui",
    # "Install-Choco-Packages",

)

## Require administrator privileges ###
# "RequireAdmin",
### Chris Titus Tech Additions
# "TitusRegistryTweaks",

$backup_funcs = @(
    "CreateRestorePoint",
)

$debloat_funcs = @(
    ### Windows Apps
    "Debloat",
)

$privacy_funcs = @(
    ### Privacy Tweaks ###
    "Telemetry",
    "WiFiSense",
    "WebSearch",
    "AppSuggestions",
    "ActivityHistory",
    "BackgroundApps",
    "LocationTracking",
    "MapUpdates",
    "Feedback",
    "TailoredExperiences",
    "AdvertisingID",
    "Cortana",
    "ErrorReporting",
    "P2PUpdateInternet",
    "DiagTrack",
    "WAPPush",
)

$security_funcs = @(
    ### Security Tweaks ###
    # "SetUACHigh",
    # "SharingMappedDrives",
    # "AdminShares",
    "SMB1",
    "SMBServer",
    "CurrentNetworkPrivate",
    "UnknownNetworksPublic",
    "NetDevicesAutoInst",
    "CtrldFolderAccess",
    "Firewall",
    "Defender",
    "DefenderCloud",
    "F8BootMenu",
    # "DotNetStrongCrypto",
    # "MeltdownCompatFlag",
)

$services_funcs = @(
    ### Service Tweaks ###
    # "UpdateMSRT",
    # "UpdateDriver",
    "UpdateRestart",
    "SharedExperiences",
    "RemoteAssistance",
    "RemoteDesktop",
    "Autorun",
    "StorageSense",
    "Defragmentation",
    "Superfetch",
    "Indexing",
    "BIOSTimeUTC",
    "EnableHibernation",
    "SleepButton",
    "SleepTimeout",
    "FastStartup",
)

$ui_funcs = @(
    ### UI Tweaks ###
    "ActionCenter",
    "LockScreen",
    # "LockScreenRS1",
    # "StickyKeys",
    "FileOperationsDetails",
    "TaskbarSearch",
    "TaskView",
    "TaskbarIcons",
    "TaskbarCombine",
    "TaskbarPeopleIcon",
    "TrayIcons",
    "SearchAppInStore",
    "NewAppPrompt",
    # "PanelIcons",
    "VisualEffects",
    "AddKeybordLanguages",
    "DarkMode",
    "Stop-EdgePDF",
)

$explorer_funcs = @(
    ### Explorer UI Tweaks ###
    "ShowKnownExtensions",
    "SyncNotifications",
    # "RecentShortcuts",
    "SetExplorerThisPC",
    "ShowThisPCOnDesktop",
    # "UserFolderOnDesktop",
    "3DObjectsFromThisPC",
    "3DObjectsFromExplorer"
)

$tweaks_funcs = @(
    "SetPhotoViewerAssociation",
    "OneDrive",
    "MediaPlayer",
    "WSL",
    # "HyperV",
    # "XPSPrinter",
    "PDFPrinter"
)

#########
# Recommended Titus Customizations
#########

Function TitusRegistryTweaks {
    Write-Output "Improving Windows Update to delay Feature updates and only install Security Updates"
    ### Fix Windows Update to delay feature updates and only update at certain times
    $UpdatesPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    If (!(Get-ItemProperty $UpdatesPath  BranchReadinessLevel)) {
        New-ItemProperty -Path $UpdatesPath -Name "BranchReadinessLevel" -Type DWord -Value 20
    }
    Set-ItemProperty -Path $UpdatesPath -Name "BranchReadinessLevel" -Type DWord -Value 20
    If (!(Get-ItemProperty $UpdatesPath  DeferFeatureUpdatesPeriodInDays)) {
        New-ItemProperty -Path $UpdatesPath -Name "DeferFeatureUpdatesPeriodInDays" -Type DWord -Value 365
    }
    Set-ItemProperty -Path $UpdatesPath -Name "DeferFeatureUpdatesPeriodInDays" -Type DWord -Value 365
    If (!(Get-ItemProperty $UpdatesPath  DeferQualityUpdatesPeriodInDays)) {
        New-ItemProperty -Path $UpdatesPath -Name "DeferQualityUpdatesPeriodInDays" -Type DWord -Value 4
    }
    Set-ItemProperty -Path $UpdatesPath -Name "DeferQualityUpdatesPeriodInDays" -Type DWord -Value 4
    If (!(Get-ItemProperty $UpdatesPath  ActiveHoursEnd)) {
        New-ItemProperty -Path $UpdatesPath -Name "ActiveHoursEnd" -Type DWord -Value 2
    }
    Set-ItemProperty -Path $UpdatesPath -Name "ActiveHoursEnd" -Type DWord -Value 2
    If (!(Get-ItemProperty $UpdatesPath  DeferQualityUpdatesPeriodInDays)) {
        New-ItemProperty -Path $UpdatesPath -Name "ActiveHoursStart" -Type DWord -Value 8
    }
    Set-ItemProperty -Path $UpdatesPath -Name "ActiveHoursStart" -Type DWord -Value 8
}

##########
# Privacy Tweaks
##########

# Disable Telemetry
# Note: This tweak may cause Enterprise edition to stop receiving Windows updates.
#       Windows Update control panel will then show message:
#           Your device is at risk because it's out of date and missing important
#           security and quality updates.
#           Let's get you back on track so Windows can run more securely.
#           Select this button to get going.
#       In such case, enable telemetry, run Windows update and then disable telemetry again.
#       See also https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/57
Function Telemetry {
    if ($privacy){
        Write-Output "Disabling Telemetry..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
    }
    else {
        Write-Output "Enabling Telemetry..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
        Enable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
    }
}


# Disable Wi-Fi Sense
Function WiFiSense {
    if ($privacy){
        Write-Output "Disabling Wi-Fi Sense..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type Dword -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type Dword -Value 0
    }
    else {
        Write-Output "Enabling Wi-Fi Sense..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 1
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -ErrorAction SilentlyContinue
    }
}


# Disable Web Search in Start Menu
Function WebSearch {
    if ($privacy){
        Write-Output "Disabling Bing Search in Start Menu..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
    }
    else {
        Write-Output "Enabling Bing Search in Start Menu..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 1
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -ErrorAction SilentlyContinue
    }
}

# Disable Application suggestions and automatic installation
Function AppSuggestions {
    if ($privacy){
        Write-Output "Disabling Application suggestions..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
    }
    else {
        Write-Output "Enabling Application suggestions..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 1
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue
    }
}

# Disable Activity History feed in Task View - Note: The checkbox "Let Windows collect my activities from this PC" remains checked even when the function is disabled
Function ActivityHistory {
    if ($privacy){
        Write-Output "Disabling Activity History..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
    }
    else {
        Write-Output "Enabling Activity History..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -ErrorAction SilentlyContinue
    }
}

# Disable Background application access - ie. if apps can download or update when they aren't used - Cortana is excluded as its inclusion breaks start menu search
Function BackgroundApps {
    if ($privacy){
        Write-Output "Disabling Background application access..."
        Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Exclude "Microsoft.Windows.Cortana*" | ForEach {
            Set-ItemProperty -Path $_.PsPath -Name "Disabled" -Type DWord -Value 1
            Set-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -Type DWord -Value 1
        }
    }
    else {
        Write-Output "Enabling Background application access..."
        Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" | ForEach {
            Remove-ItemProperty -Path $_.PsPath -Name "Disabled" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -ErrorAction SilentlyContinue
        }
    }
}


# Disable Location Tracking
Function LocationTracking {
    if ($privacy){
        Write-Output "Disabling Location Tracking..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
    }
    else {
        Write-Output "Enabling Location Tracking..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Allow"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 1
    }
}

# Disable automatic Maps updates
Function MapUpdates {
    if ($privacy){
        Write-Output "Disabling automatic Maps updates..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
    }
    else {
        Write-Output "Enable automatic Maps updates..."
        Remove-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -ErrorAction SilentlyContinue
    }
}

# Disable Feedback
Function Feedback {
    if ($privacy){
        Write-Output "Disabling Feedback..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
    }
    else {
        Write-Output "Enabling Feedback..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -ErrorAction SilentlyContinue
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
    }
}

# Enable Tailored Experiences
Function TailoredExperiences {
    if ($privacy){
        Write-Output "Disabling Tailored Experiences..."
        If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
    }
    else {
        Write-Output "Enabling Tailored Experiences..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -ErrorAction SilentlyContinue
    }
}

# Enable Advertising ID
Function AdvertisingID {
    if ($privacy){
        Write-Output "Disabling Advertising ID..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
    }
    else {
        Write-Output "Enabling Advertising ID..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -ErrorAction SilentlyContinue
    }
}

# Enable Cortana
Function EnableCortana {
    if ($privacy){
        Write-Output "Disabling Cortana..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
    }
    else {
        Write-Output "Enabling Cortana..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -ErrorAction SilentlyContinue
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 0
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -ErrorAction SilentlyContinue
    }
}

# Enable Error reporting
Function ErrroReporting {
    if ($privacy){
        Write-Output "Enabling Error reporting..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -ErrorAction SilentlyContinue
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
    }
    else {
        Write-Output "Disabling Error reporting..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
    }
}

# Unrestrict Windows Update P2P
Function P2PUpdateInternet {
    if ($privacy){
        Write-Output "Unrestricting Windows Update P2P to internet..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Restricting Windows Update P2P only to local network..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
    }
}

# Stop and disable Diagnostics Tracking Service
Function DiagTrack {
    if ($privacy){
        Write-Output "Stopping and disabling Diagnostics Tracking Service..."
        Stop-Service "DiagTrack" -WarningAction SilentlyContinue
        Set-Service "DiagTrack" -StartupType Disabled
    }
    else {
        Write-Output "Enabling and starting Diagnostics Tracking Service..."
        Set-Service "DiagTrack" -StartupType Automatic
        Start-Service "DiagTrack" -WarningAction SilentlyContinue
    }
}


# Enable and start WAP Push Service
Function WAPPush {
    if ($privacy){
        Write-Output "Stopping and disabling WAP Push Service..."
        Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
        Set-Service "dmwappushservice" -StartupType Disabled
    }
    else {
        Write-Output "Enabling and starting WAP Push Service..."
        Set-Service "dmwappushservice" -StartupType Automatic
        Start-Service "dmwappushservice" -WarningAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" -Name "DelayedAutoStart" -Type DWord -Value 1
    }
}

##########
# Security Tweaks
##########

# Raise UAC level
Function SetUACHigh {
    if ($security){
        Write-Output "Lowering UAC level..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
    }
    else {
        Write-Output "Raising UAC level..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1
    }
}

# Disable sharing mapped drives between users
Function SharingMappedDrives {
    if ($security){
        Write-Output "Disabling sharing mapped drives between users..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Enabling sharing mapped drives between users..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -Type DWord -Value 1
    }
}

# Enable implicit administrative shares
Function AdminShares {
    if ($security){
        Write-Output "Enabling implicit administrative shares..."
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling implicit administrative shares..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -Type DWord -Value 0
    }
}

# Enable obsolete SMB 1.0 protocol - Disabled by default since 1709
Function SMB1 {
    if ($security){
        Write-Output "Disabling SMB 1.0 protocol..."
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
    }
    else {
        Write-Output "Enabling SMB 1.0 protocol..."
        Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force
    }
}

# Enable SMB Server
Function SMBServer {
    if ($security){
        Write-Output "Disabling SMB Server..."
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
        Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force
    }
    else {
        Write-Output "Enabling SMB Server..."
        Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force
    }
}

# Set current network profile to public (deny file sharing, device discovery, etc.)
Function CurrentNetworkPublic {
    if ($security){
        Write-Output "Setting current network profile to public..."
        Set-NetConnectionProfile -NetworkCategory Public
    }
    else {
        Write-Output "Setting current network profile to private..."
        Set-NetConnectionProfile -NetworkCategory Private
    }
}

# Set unknown networks profile to public (deny file sharing, device discovery, etc.)
Function UnknownNetworksPublic {
    if ($security){
        Write-Output "Setting unknown networks profile to public..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Setting unknown networks profile to private..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -Type DWord -Value 1
    }
}

# Enable automatic installation of network devices
Function NetDevicesAutoInst {
    if ($security){
        Write-Output "Enabling automatic installation of network devices..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling automatic installation of network devices..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -Type DWord -Value 0
    }
}

# Disable Controlled Folder Access (Defender Exploit Guard feature) - Applicable to 1709 or newer, requires Windows Defender to be enabled
Function CtrldFolderAccess {
    if ($security){
        Write-Output "Disabling Controlled Folder Access..."
        Set-MpPreference -EnableControlledFolderAccess Disabled
    }
    else {
        Write-Output "Enabling Controlled Folder Access..."
        Set-MpPreference -EnableControlledFolderAccess Enabled
    }
}

# Enable Firewall
Function Firewall {
    if ($security){
        Write-Output "Enabling Firewall..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling Firewall..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -Type DWord -Value 0
    }
}

# Enable Windows Defender
Function Defender {
    if ($security){
        Write-Output "Enabling Windows Defender..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
        If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
        } ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
        }
    }
    else {
        Write-Output "Disabling Windows Defender..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
        If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -ErrorAction SilentlyContinue
        } ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
        }
    }
}

# Enable Windows Defender Cloud
Function DefenderCloud {
    if ($security){
        Write-Output "Enabling Windows Defender Cloud..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling Windows Defender Cloud..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Type DWord -Value 2
    }
}

# Disable F8 boot menu options
Function F8BootMenu {
    if ($security){
        Write-Output "Enabling F8 boot menu options..."
        bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
    }
    else {
        Write-Output "Disabling F8 boot menu options..."
        bcdedit /set `{current`} bootmenupolicy Standard | Out-Null
    }
}

# Enable strong cryptography for .NET Framework (version 4 and above)
# https://stackoverflow.com/questions/36265534/invoke-webrequest-ssl-fails
Function DotNetStrongCrypto {
    if ($security){
        Write-output "Enabling .NET strong cryptography..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
    }
    else {
        Write-output "Disabling .NET strong cryptography..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -ErrorAction SilentlyContinue
    }
}

# Enable Meltdown (CVE-2017-5754) compatibility flag - Required for January 2018 and all subsequent Windows updates
# This flag is normally automatically enabled by compatible antivirus software (such as Windows Defender).
# Use the tweak only if you have confirmed that your AV is compatible but unable to set the flag automatically or if you don't use any AV at all.
# See https://support.microsoft.com/en-us/help/4072699/january-3-2018-windows-security-updates-and-antivirus-software for details.
Function MeltdownCompatFlag {
    if ($services){
        Write-Output "Enabling Meltdown (CVE-2017-5754) compatibility flag..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 0
    }
    else {
        Write-Output "Disabling Meltdown (CVE-2017-5754) compatibility flag..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -ErrorAction SilentlyContinue
    }
}

##########
# Service Tweaks
##########

# Enable offering of Malicious Software Removal Tool through Windows Update
Function UpdateMSRT {
    if ($services){
        Write-Output "Enabling Malicious Software Removal Tool offering..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling Malicious Software Removal Tool offering..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" | Out-Null
            }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
    }
}

# Disable offering of drivers through Windows Update
# Note: This doesn't work properly if you use a driver intended for another hardware model. E.g. Intel I219-V on WinServer works only with I219-LM driver.
# Therefore Windows update will repeatedly try and fail to install I219-V driver indefinitely even if you use the tweak.
Function UpdateDriver {
    if ($services){
        Write-Output "Enabling driver offering through Windows Update..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling driver offering through Windows Update..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -Type DWord -Value 0
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Type DWord -Value 1
    }
}

# Disable Windows Update automatic restart
# Note: This doesn't disable the need for the restart but rather tries to ensure
#       that the restart doesn't happen in the least expected moment.
#       Allow the machine to restart as soon as possible anyway.
Function UpdateRestart {
    if ($services){
        Write-Output "Enabling Windows Update automatic restart..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling Windows Update automatic restart..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Type DWord -Value 0
    }
}

# Enable Shared Experiences - Not applicable to Server
Function SharedExperiences {
    if ($services){
        Write-Output "Enabling Shared Experiences..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableCdp" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableMmx" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling Shared Experiences..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableCdp" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableMmx" -Type DWord -Value 0
    }
}

# Enable Remote Assistance - Not applicable to Server (unless Remote Assistance is explicitly installed)
Function RemoteAssistance {
    if ($services){
        Write-Output "Enabling Remote Assistance..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 1
    }
    else {
        Write-Output "Disabling Remote Assistance..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
    }
}

# Disable Remote Desktop
Function RemoteDesktop {
    if ($services){
        Write-Output "Enabling Remote Desktop w/o Network Level Authentication..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0
        Enable-NetFirewallRule -Name "RemoteDesktop*"
    }
    else {
        Write-Output "Disabling Remote Desktop..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 1
        Disable-NetFirewallRule -Name "RemoteDesktop*"
    }
}

# Enable Autorun for removable drives
Function Autorun {
    if ($services){
        Write-Output "Enabling Autorun for all drives..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling Autorun for all drives..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
    }
}

# Enable Storage Sense - automatic disk cleanup - Not applicable to Server
Function StorageSense {
    if ($services){
        Write-Output "Enabling Storage Sense..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "04" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "08" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "32" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "StoragePoliciesNotified" -Type DWord -Value 1
    }
    else {
        Write-Output "Disabling Storage Sense..."
        Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
    }
}

# Enable scheduled defragmentation task
Function Defragmentation {
    if ($services){
        Write-Output "Enabling scheduled defragmentation..."
        Enable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" | Out-Null
    }
    else {
        Write-Output "Disabling scheduled defragmentation..."
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" | Out-Null
    }
}

# Start and enable Superfetch service - Not applicable to Server
Function Superfetch {
    if ($services){
        Write-Output "Starting and enabling Superfetch service..."
        Set-Service "SysMain" -StartupType Automatic
        Start-Service "SysMain" -WarningAction SilentlyContinue
    }
    else {
        Write-Output "Stopping and disabling Superfetch service..."
        Stop-Service "SysMain" -WarningAction SilentlyContinue
        Set-Service "SysMain" -StartupType Disabled
    }
}

# Start and enable Windows Search indexing service
Function Indexing {
    if ($services){
        Write-Output "Starting and enabling Windows Search indexing service..."
        Set-Service "WSearch" -StartupType Automatic
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "DelayedAutoStart" -Type DWord -Value 1
        Start-Service "WSearch" -WarningAction SilentlyContinue
    }
    else {
        Write-Output "Stopping and disabling Windows Search indexing service..."
        Stop-Service "WSearch" -WarningAction SilentlyContinue
        Set-Service "WSearch" -StartupType Disabled
    }
}

# Set BIOS time to UTC
Function BIOSTimeUTC {
    if ($services){
        Write-Output "Setting BIOS time to Local time..."
        Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Setting BIOS time to UTC..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
    }
}

# Enable Hibernation - Do not use on Server with automatically started Hyper-V hvboot service as it may lead to BSODs (Win10 with Hyper-V is fine)
Function EnableHibernation {
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
    }
    if ($services){
        Write-Output "Enabling Hibernation..."
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 1
    }
    else {
        Write-Output "Disabling Hibernation..."
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0
    }
}

# Disable Hibernation
Function DisableHibernation {
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
    }
}

# Disable Sleep start menu and keyboard button
Function SleepButton {
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
    }
    if ($services){
        Write-Output "Enabling Sleep start menu and keyboard button..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowSleepOption" -Type Dword -Value 1
        powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
        powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
    }
    else {
        Write-Output "Disabling Sleep start menu and keyboard button..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowSleepOption" -Type Dword -Value 0
        powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
        powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
    }
}

# Disable display and sleep mode timeouts
Function SleepTimeout {
    if ($services){
        Write-Output "Enabling display and sleep mode timeouts..."
        powercfg /X monitor-timeout-ac 30
    }
    else {
        powercfg /X monitor-timeout-dc 15
        powercfg /X standby-timeout-ac 0
        powercfg /X standby-timeout-dc 60
        Write-Output "Disabling display and sleep mode timeouts..."
        powercfg /X monitor-timeout-ac 0
        powercfg /X monitor-timeout-dc 0
        powercfg /X standby-timeout-ac 0
        powercfg /X standby-timeout-dc 0
    }
}

# Disable Fast Startup
Function FastStartup {
    if ($services){
        Write-Output "Enabling Fast Startup..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 1
    }
    else {
        Write-Output "Disabling Fast Startup..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0
    }
}

##########
# UI Tweaks
##########

# Disable Action Center
Function ActionCenter {
    if ($ui){
        Write-Output "Enabling Action Center..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -ErrorAction SilentlyContinue
    }
    else {
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -ErrorAction SilentlyContinue
        Write-Output "Disabling Action Center..."
        If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
            New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
    }
}

# Disable Lock screen
Function LockScreen {
    if ($ui){
        Write-Output "Enabling Lock screen..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling Lock screen..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1
    }
}

# Disable Lock screen (Anniversary Update workaround) - Applicable to 1607 - 1803 (The GPO used in DisableLockScreen has been fixed again in 1803)
Function LockScreenRS1 {
    if ($ui){
        Write-Output "Enabling Lock screen (removing scheduler workaround)..."
            Unregister-ScheduledTask -TaskName "Disable LockScreen" -Confirm:$false -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling Lock screen using scheduler workaround..."
        $service = New-Object -com Schedule.Service
        $service.Connect()
        $task = $service.NewTask(0)
        $task.Settings.DisallowStartIfOnBatteries = $false
        $trigger = $task.Triggers.Create(9)
        $trigger = $task.Triggers.Create(11)
        $trigger.StateChange = 8
        $action = $task.Actions.Create(0)
        $action.Path = "reg.exe"
        $action.Arguments = "add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData /t REG_DWORD /v AllowLockScreen /d 0 /f"
        $service.GetFolder("\").RegisterTaskDefinition("Disable LockScreen", $task, 6, "NT AUTHORITY\SYSTEM", $null, 4) | Out-Null
    }
}

# Disable Sticky keys prompt
Function StickyKeys {
    if ($ui){
        Write-Output "Enabling Sticky keys prompt..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "510"
    }
    else {
        Write-Output "Disabling Sticky keys prompt..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
    }
}

# Show file operations details
Function FileOperationsDetails {
    if ($ui){
        Write-Output "Hiding file operations details..."
            Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Showing file operations details..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
    }
}

# Hide Taskbar Search icon / box
Function TaskbarSearch {
    if ($ui){
        Write-Output "Showing Taskbar Search icon..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
    }
    else {
        Write-Output "Hiding Taskbar Search icon / box..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
    }
}

# Hide Task View button
Function TaskView {
    if ($ui){
        Write-Output "Showing Task View button..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Hiding Task View button..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
    }
}

# Show small icons in taskbar
Function TaskbarIcons {
    if ($ui){
        Write-Output "Showing large icons in taskbar..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Showing small icons in taskbar..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Type DWord -Value 1
    }
}

# Set taskbar buttons to show labels and combine when taskbar is full
Function TaskbarCombine {
    if ($ui){
        Write-Output "Setting taskbar buttons to never combine..."
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 2
    }
    else {
        Write-Output "Setting taskbar buttons to combine when taskbar is full..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 1
    }
    # Write-Output "Setting taskbar buttons to always combine, hide labels..."
    # Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -ErrorAction SilentlyContinue
}

# Hide Taskbar People icon
Function TaskbarPeopleIcon {
    if ($ui){
        Write-Output "Showing People icon..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Hiding People icon..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
    }
}

# tray icons as needed
Function TrayIcons {
    if ($ui) {
        Write-Output "Showing all tray icons..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value 0
    }
    else {
        Write-Output "Hiding tray icons..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -ErrorAction SilentlyContinue
    }
}

# Disable search for app in store for unknown extensions
Function SearchAppInStore {
    if ($ui) {
        Write-Output "Enabling search for app in store for unknown extensions..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Disabling search for app in store for unknown extensions..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
    }
}

# Disable 'How do you want to open this file?' prompt
Function NewAppPrompt {
    if($ui){
        Write-Output "Enabling 'How do you want to open this file?' prompt..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -ErrorAction SilentlyContinue
    }
    else{
        Write-Output "Disabling 'How do you want to open this file?' prompt..."
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -Type DWord -Value 1
    }
}

# Set Control Panel view to Small icons (Classic)
Function PanelIcons {
    if ($ui){
        Write-Output "Setting Control Panel view to large icons..."
        If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 0
    }
    else {
        Write-Output "Setting Control Panel view to small icons..."
        If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 1
    }
    # Write-Output "Setting Control Panel view to categories..."
    # Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -ErrorAction SilentlyContinue
    # Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -ErrorAction SilentlyContinue
}

# Adjusts visual effects for performance - Disables animations, transparency etc. but leaves font smoothing and miniatures enabled
Function VisualEffects {
    if ($ui){
        Write-Output "Adjusting visual effects for appearance..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 400
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](158,30,7,128,18,0,0,0))
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 1
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1
    }
    else{
        Write-Output "Adjusting visual effects for performance..."
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144,18,3,128,16,0,0,0))
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 0
    }
}

# Add secondary en-US keyboard
Function AddKeybordLanguages {
    Write-Output "Adding secondary Adding Spanish and English keyboards..."
    $langs = Get-WinUserLanguageList
    $langs.Add("en-US")
    $langs.Add("es-MX")
    Set-WinUserLanguageList $langs -Force
}

Function DarkMode {
    if ($ui){
        Write-Output "Enabling Dark Mode"
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0
    }
    else{
        Write-Output "Disabling Dark Mode"
        Remove-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme
    }
}

Function Stop-EdgePDF {
    # Stops edge from taking over as the default .PDF viewer
    Write-Output "Stopping Edge from taking over as the default .PDF viewer"
    $NoPDF = "HKCR:\.pdf"
    $NoProgids = "HKCR:\.pdf\OpenWithProgids"
    $NoWithList = "HKCR:\.pdf\OpenWithList"

    If (!(Get-ItemProperty $NoPDF  NoOpenWith)) {
        New-ItemProperty $NoPDF NoOpenWith
    }

    If (!(Get-ItemProperty $NoPDF  NoStaticDefaultVerb)) {
        New-ItemProperty $NoPDF  NoStaticDefaultVerb
    }

    If (!(Get-ItemProperty $NoProgids  NoOpenWith)) {
        New-ItemProperty $NoProgids  NoOpenWith
    }

    If (!(Get-ItemProperty $NoProgids  NoStaticDefaultVerb)) {
        New-ItemProperty $NoProgids  NoStaticDefaultVerb
    }

    If (!(Get-ItemProperty $NoWithList  NoOpenWith)) {
        New-ItemProperty $NoWithList  NoOpenWith
    }

    If (!(Get-ItemProperty $NoWithList  NoStaticDefaultVerb)) {
        New-ItemProperty $NoWithList  NoStaticDefaultVerb
    }

    #Appends an underscore '_' to the Registry key for Edge
    $Edge = "HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_"
    If (Test-Path $Edge) {
        Set-Item $Edge AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_
    }
}

##########
# Explorer UI Tweaks
##########

# Show known file extensions
Function ShowKnownExtensions {
    if($explorer){
        Write-Output "Showing known file extensions..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
    }
    else {
        Write-Output "Hiding known file extensions..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1
    }
}

# Show sync provider notifications
Function SyncNotifications {
    if($explorer){
        Write-Output "Showing sync provider notifications..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 1
    }
    else{
        Write-Output "Hiding sync provider notifications..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
    }
}

# Show recently and frequently used item shortcuts in Explorer
Function ShowRecentShortcuts {
    if ($explorer) {
        Write-Output "Showing recent shortcuts..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Hiding recent shortcuts..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWord -Value 0
    }
}

# Change default Explorer view to This PC
Function SetExplorerThisPC {
    if ($explorer){
        Write-Output "Changing default Explorer view to This PC..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
    }
    else {
        Write-Output "Changing default Explorer view to Quick Access..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -ErrorAction SilentlyContinue
    }
}

# Show This PC shortcut on desktop
Function ShowThisPCOnDesktop {
    if($explorer){
        Write-Output "Showing This PC shortcut on desktop..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
    }
    else{
        Write-Output "Hiding This PC shortcut from desktop..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
    }
}

# User Folder shortcut on desktop
Function UserFolderOnDesktop {
    if ($explorer){
        Write-Output "Showing User Folder shortcut on desktop..."
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
        If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
            New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
    }
    else {
        Write-Output "Hiding User Folder shortcut from desktop..."
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -ErrorAction SilentlyContinue
    }
}

# Hide 3D Objects icon from This PC - The icon remains in personal folders and open/save dialogs
Function 3DObjectsFromThisPC {
    if ($explorer){
        Write-Output "Showing 3D Objects icon in This PC..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" | Out-Null
        }
    }
    else {
        Write-Output "Hidding 3D Objects icon from This PC..."
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
    }
}

# Hide 3D Objects icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function 3DObjectsFromExplorer {
    if ($explorer){
        Write-Output "Showing 3D Objects icon in Explorer namespace..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Hidding 3D Objects icon in Explorer namespace..."
        If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
        If (!(Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
            New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
    }
}

##########
# Application Tweaks
##########

# Set Photo Viewer association for bmp, gif, jpg, png and tif
Function SetPhotoViewerAssociation {
    Write-Output "Setting Photo Viewer association for bmp, gif, jpg, png and tif..."
    If (!(Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    }
    ForEach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")) {
        New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
        New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
        Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
        Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
    }
}

# OneDrive - Not applicable to Server
Function OneDrive {
    $onedrive_exe = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
    If (!(Test-Path $onedrive_exe)) {
        $onedrive_exe = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
    }

    if ($tweaks){
        Write-Output "Installing OneDrive..."
        Start-Process $onedrive_exe -NoNewWindow
    }
    else {
        Write-Output "Uninstalling OneDrive..."
        Stop-Process -Name "OneDrive" -ErrorAction SilentlyContinue
        Start-Sleep -s 2
        Start-Process $onedrive_exe "/uninstall" -NoNewWindow -Wait
        Start-Sleep -s 2
        Stop-Process -Name "explorer" -ErrorAction SilentlyContinue
        Start-Sleep -s 2
        Remove-Item -Path "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
        If (!(Test-Path "HKCR:")) {
            New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
        }
        Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
    }

}

Function MediaPlayer {
    if ($tweaks){
        Write-Output "Uninstalling Windows Media Player..."
        Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
    else {
        Write-Output "Installing Windows Media Player..."
        Enable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
}

# Install Linux Subsystem - Applicable to 1607 or newer
Function WSL {
    if ($tweaks){
        Write-Output "Installing Linux Subsystem..."
        If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
            # 1607 needs developer mode to be enabled
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
        }
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
    else {
        Write-Output "Uninstalling Linux Subsystem..."
        If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 0
        }
        Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
}

# Hyper-V - Not applicable to Home
Function HyperV {
    if ($tweaks){
        Write-Output "Installing Hyper-V..."
        If ((Get-WmiObject -Class "Win32_OperatingSystem").Caption -like "*Server*") {
            Install-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
        } Else {
            Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -WarningAction SilentlyContinue | Out-Null
        }
    }
    else {
        Write-Output "Uninstalling Hyper-V..."
        If ((Get-WmiObject -Class "Win32_OperatingSystem").Caption -like "*Server*") {
            Uninstall-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
        } Else {
            Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -WarningAction SilentlyContinue | Out-Null
        }
    }
}

# Microsoft Print to PDF
Function PDFPrinter {
    if ($tweaks){
        Write-Output "Installing Microsoft Print to PDF..."
        Enable-WindowsOptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
    else {
        Write-Output "Uninstalling Microsoft Print to PDF..."
        Disable-WindowsOptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
}

# Microsoft XPS Document Writer
Function XPSPrinter {
    if($tweaks) {
        Write-Output "Installing Microsoft XPS Document Writer..."
        Enable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
    else {
        Write-Output "Uninstalling Microsoft XPS Document Writer..."
        Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
}

##########
# Auxiliary Functions
##########

# Relaunch the script with administrator privileges
Function RequireAdmin {
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
        Exit
    }
}

# Wait for key press
Function WaitForKey {
    Write-Output "Press any key to continue..."
    [Console]::ReadKey($true) | Out-Null
}

# Restart computer
Function Restart {
    Write-Output "Restarting..."
    Restart-Computer
}

Function CreateRestorePoint {
  Write-Output "Creating Restore Point incase something bad happens"
  Enable-ComputerRestore -Drive "C:\"
  Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"
}

##########
# Debloat Script Additions
##########

# In case you have removed them for good, you can try to restore the files using installation medium as follows
# New-Item C:\Mnt -Type Directory | Out-Null
# dism /Mount-Image /ImageFile:D:\sources\install.wim /index:1 /ReadOnly /MountDir:C:\Mnt
# robocopy /S /SEC /R:0 "C:\Mnt\Program Files\WindowsApps" "C:\Program Files\WindowsApps"
# dism /Unmount-Image /Discard /MountDir:C:\Mnt
# Remove-Item -Path C:\Mnt -Recurse
Function Debloat {
    $ThirdPartyBloat = @(
        # Sponsored Windows 10 AppX Apps
        # Add sponsored/featured apps to remove in the "*AppName*" format
        "*EclipseManager*",
        "*ActiproSoftwareLLC*",
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*",
        "*Duolingo-LearnLanguagesforFree*",
        "*PandoraMediaInc*",
        "*CandyCrush*",
        "*BubbleWitch3Saga*",
        "*Wunderlist*",
        "*Flipboard*",
        "*Twitter*",
        "*Facebook*",
        # "SpotifyAB.SpotifyMusic",
        # "*Spotify*",
        # "*Plex*",
        "4DF9E0F8.Netflix*",
        "*Dropbox*",
        "*GAMELOFT*",
        "*Royal Revolt*",
        "*Sway*",
        "*Speed Test*",
        "*Dolby*",
        "*DolbyLaboratories.DolbyAccess*",
        "*Viber*",
        "*ACGMediaPlayer*",
        "*OneCalendar*",
        "*LinkedInforWindows*",
        "*HiddenCityMysteryofShadows*",
        "*AutodeskSketchBook*",
        "*DisneyMagicKingdoms*",
        "*MarchofEmpires*",
        "WinZipComputing.WinZipUniversal",
        "XINGAG.XING",
        "*FarmVille2CountryEscape*",
        "*CyberLink*",
        "*RandomSaladGames*",
        # "*CyberLinkMediaSuiteEssentials*",
        "Drawboard.DrawboardPDF",
        "flaregamesGmbH.RoyalRevolt2",
        "KeeperSecurityInc.Keeper",
        "king.com.BubbleWitch3Saga",
        "king.com.CandyCrushSodaSaga",
        "*Evernote*",
        "PandoraMediaInc.29680B314EFC2"
    )

    $MSBloatware = @(

        # Unnecessary Windows 10 AppX Apps
        "Microsoft.3DBuilder",
        "Microsoft.AppConnector",
        "Microsoft.BingFinance",
        "Microsoft.BingSports",
        "Microsoft.BingTranslator",
        "Microsoft.BingNews"
        # "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        # "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.StorePurchaseApp"
        # "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        # "Microsoft.WindowsSoundRecorder"
        # "Microsoft.ZuneMusic"
        # "Microsoft.ZuneVideo"
        "Microsoft.MicrosoftPowerBIForWindows",
        # "Microsoft.MicrosoftStickyNotes",
        # "Microsoft.Office.OneNote",
        # "Microsoft.RemoteDesktop",
        # "Microsoft.WindowsCamera",
        # "Microsoft.WindowsPhone",
        # "Microsoft.CommsPhone",
        # "Microsoft.ConnectivityStore",
        "Microsoft.Wallet"

        # # Optional: Typically not removed but you can if you need to for some reason
        # "*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
        # "*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
        # "*Microsoft.BingWeather*"
        # "*Microsoft.MSPaint*"
        # "*Microsoft.MicrosoftStickyNotes*"
        # "*Microsoft.Windows.Photos*"
        # "*Microsoft.WindowsCalculator*"
        # "*Microsoft.WindowsStore*"

    )

    if ($debloat){
        foreach ($Bloat in $MSBloatware) {
            Write-Output "Trying to remove bloat: $Bloat."
            Get-AppxPackage -Name $Bloat | Remove-AppxPackage
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
        }

        foreach ($Bloat in $ThirdPartyBloat) {
            Write-Output "Trying to remove third party bloat: $Bloat."
            Get-AppxPackage -Name $Bloat | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }
    }
    else {
        foreach ($Bloat in $Bloatware) {
            Write-Output "Trying to Install $Bloat."
            Get-AppxPackage -AllUsers $Bloat | ForEach {
                Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
            }
        }
    }

}

function Install-Scoop {
    if ( -Not (Get-Command "scoop" -ErrorAction SilentlyContinue) ) {
        Write-Output "Installing Scoop"
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    }
    else {
        Write-Output "Skipping Scoop, already installed"
    }
}

function Install-Choco {
    if ( -Not (Get-Command "choco" -ErrorAction SilentlyContinue) ) {
        Write-Output "Installing Chocolatey"
        Set-ExecutionPolicy Bypass -Scope Process -Force
       if($proxy -or ($env:http_proxy -ne $null -AND $env:http_proxy -ne '') ) {
            [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
        }
        else{
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        }
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else {
        Write-Output "Skipping Chocolatey, already installed"
    }
}

function Install-Scoop-Buckets {
    $bucket_file = "$script_path\packages\windows\scoop.buckets"

    if ( Test-Path "$bucket_file" ) {
        $buckets = Get-Content $bucket_file -ErrorAction Stop | ForEach { $_.Trim() } | Where {
            $_ -ne "" -and $_[0] -ne "#" -and $_[0] -ne "scoop"
        }
        $buckets | ForEach {
            Write-Output "Getting Scoop Bucket: $_"
            scoop bucket add $_
        }
    }
}

function Install-Scoop-Packages {
    $pkg_file = "$script_path\packages\windows\scoop.pkg"

    if ( Test-Path "$pkg_file" ) {
        $pkgs = Get-Content $pkg_file -ErrorAction Stop | ForEach { $_.Trim() } | Where {
            $_ -ne "" -and $_[0] -ne "#" -and $_[0] -ne "scoop"
        }
        $pkgs | ForEach {
            Write-Output "Installing scoop package: $_"
            scoop install $_
        }
    }
}

function Install-Choco-Packages {
    $pkg_file = "$script_path\packages\windows\choco.pkg"

    if ( Test-Path "$pkg_file" ) {
        $pkgs = Get-Content $pkg_file -ErrorAction Stop | ForEach { $_.Trim() } | Where {
            $_ -ne "" -and $_[0] -ne "#" -and $_[0] -ne "choco"
        }
        $pkgs | ForEach {
            Write-Output "Installing choco package: $_"
            choco install $_ -y
        }
    }
}

##########
# Parse parameters and apply tweaks
##########


# # Call the desired tweak functions
# $tweaks | ForEach { Invoke-Expression $_ }
