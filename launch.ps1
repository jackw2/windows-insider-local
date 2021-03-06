#Requires -RunAsAdministrator

#If you are reading this, you would probably appreciate some helpful documentation
#https://docs.microsoft.com/en-us/windows/deployment/update/how-windows-update-works

Clear-Host

$scriptVersion = "v0.2"
$scriptDate = "(2021 March 6)        "

#check windows version before running
$version = (Get-ItemProperty `
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId

"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
"┃                                                                           ┃"
"┃     Windows Insider Local $scriptVersion $scriptDate                     ┃"
"┃     by Jack Wesolowski @jackw2                                            ┃"
"┃                                                                           ┃"
"┃     github.com/jackw2/windows-insider-local                               ┃"
"┃                                                                           ┃"
"┃                                                                           ┃"
"┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"
"┃                                                                           ┃"
"┃     Warning! This script was made for technical users who are             ┃"
"┃     comfortable modifying the registry. You should not, in general,       ┃"
"┃     run admin-rights powershell scripts without sufficient knowledge      ┃"
"┃     of what they do. Use at your own risk.                                ┃"
"┃                                                                           ┃"
"┃     This script bypasses the standard update procedures by Microsoft.     ┃"
"┃     Additionally, you will need to use the script again when you want     ┃"
"┃     to opt-out of the Windows Insider Program.                            ┃"
"┃                                                                           ┃"
"┃     Currently running Windows Version: $version                               ┃"
"┃                                                                           ┃"
"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

if ($version -lt 1909) {
    Clear-Host
    "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    "!!  This script has not been tested on versions prior to Windows 10 1909.           !!"
    "!!  Unless you have a time machine, that probably wouldn't be very useful anyways.  !!"
    "!!  Please update to 1909 before using this script.                                 !!"
    "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n"
    exit 0
}

read-host "Press enter to confirm you understand"
Clear-Host

"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
"┃                                                                           ┃"
"┃     Windows Insider Local $scriptVersion $scriptDate                     ┃"
"┃     by Jack Wesolowski @jackw2                                            ┃"
"┃                                                                           ┃"
"┃     Which channel should I pick?                                          ┃"
"┃     See: tinyurl.com/InsiderChannels                                      ┃"
"┃                                                                           ┃"
"┣━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"
"┃   ┃                                                                       ┃"
"┃ Q ┃ Quit without making changes                                           ┃"
"┃ R ┃ Reset (opt-out of insider builds)                                     ┃"
"┃   ┃                                                                       ┃"
"┃ 1 ┃ Release Preview                                                       ┃"
"┃ 2 ┃ Beta (Slow)                                                           ┃"
"┃ 3 ┃ Dev Channel (Fast)                                                    ┃"
"┃   ┃                                                                       ┃"
"┃   ┃                                                                       ┃"
"┃   ┃                                                                       ┃"
"┃   ┃                                                                       ┃"
"┃   ┃                                                                       ┃"
"┗━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

$choice = read-host "Choose an option"

#flight signed certificate check
$flightSigningFlag = 0
cmd.exe /c "bcdedit /enum { current } | findstr /I /R /C:`"^flightsigning *Yes$`""  | out-null
if ($LASTEXITCODE -eq 0) {
    $flightSigningFlag = 1
}

#resets registry to default
function Reset-Registry-Config {
    Set-Location HKLM:
    Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost" -Recurse -Force -EA SilentlyContinue
    Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat" -Recurse -Force -EA SilentlyContinue
    Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingPreview" -Recurse -Force -EA SilentlyContinue
    Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderSlow" -Recurse -Force -EA SilentlyContinue
    Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderFast" -Recurse -Force -EA SilentlyContinue
}

function Edit-Insider-Builds {
    param(
        [string] $sls,
        [string] $ring,
        [string] $content,
        [string] $ringTitle
    )
    Reset-Registry-Config
    
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator" -ItemType DWord -Name EnableUUPScan -Value 1 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\$sls" -ItemType DWord -Name Enabled -Value 1 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat" -ItemType DWord -Name WUMUDCATEnabled -Value 1 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" -ItemType DWord -Name EnablePreviewBuilds -Value 1 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" -ItemType DWord -Name IsBuildFlightingEnabled -Value 1 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" -ItemType DWord -Name TestFlags -Value 32 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" -ItemType String -Name ContentType -Value "$content" -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" -ItemType String -Name BranchName -Value "external" -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" -ItemType String -Name Ring -Value "$ring" -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" -ItemType String -Name StickyXaml -Value "<StackPanel xmlns=`"`"`"http://schemas.microsoft.com/winfx/2006/xaml/presentation`"`"`"><TextBlock Style=`"`"`"{StaticResource BodyTextBlockStyle }`"`"`">You are now receiving Windows Insider builds using the Windows Insider for Local Accounts Script $scriptVersion. To stop receiving Insider builds, use the script again and select reset. <Hyperlink NavigateUri=`"`"`"https://github.com/jackw2/windows-insider-local`"`"`" TextDecorations=`"`"`"None`"`"`">Download the script here</Hyperlink></TextBlock><TextBlock Text=`"`"`"Applied configuration`"`"`" Margin=`"`"`"0,20,0,10`"`"`" Style=`"`"`"{StaticResource SubtitleTextBlockStyle}`"`"`" /><TextBlock Style=`"`"`"{StaticResource BodyTextBlockStyle }`"`"`" Margin=`"`"`"0,0,0,5`"`"`"><Run FontFamily=`"`"`"Segoe MDL2 Assets`"`"`">&#xECA7;</Run> <Span FontWeight=`"`"`"SemiBold`"`"`">%FancyRing%</Span></TextBlock><TextBlock Text=`"`"`"Ring: %Ring%`"`"`" Style=`"`"`"{StaticResource BodyTextBlockStyle }`"`"`" /><TextBlock Text=`"`"`"Content: %Content%`"`"`" Style=`"`"`"{StaticResource BodyTextBlockStyle }`"`"`" /><TextBlock Text=`"`"`"Telemetry settings notice`"`"`" Margin=`"`"`"0,20,0,10`"`"`" Style=`"`"`"{StaticResource SubtitleTextBlockStyle}`"`"`" /><TextBlock Style=`"`"`"{StaticResource BodyTextBlockStyle }`"`"`">Windows Insider Program requires your diagnostic data collection settings to be set to <Span FontWeight=`"`"`"SemiBold`"`"`">Full</Span>. You can verify or modify your current settings in <Span FontWeight=`"`"`"SemiBold`"`"`">Diagnostics &amp; feedback</Span>.</TextBlock><Button Command=`"`"`"{StaticResource ActivateUriCommand}`"`"`" CommandParameter=`"`"`"ms-settings:privacy-feedback`"`"`" Margin=`"`"`"0,10,0,0`"`"`"><TextBlock Margin=`"`"`"5,0,5,0`"`"`">Open Diagnostics &amp; feedback</TextBlock></Button></StackPanel>" -Force  | out-null
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" -ItemType DWord -Name UIHiddenElements -Value 65535 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" -ItemType DWord -Name UIDisabledElements -Value 65535 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" -ItemType DWord -Name UIServiceDrivenElementVisibility -Value 0 -Force -EA SilentlyContinue
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" -ItemType DWord -Name UIErrorMessageVisibility -Value 192 -Force -EA SilentlyContinue

    cmd.exe /c "bcdedit /set { current } flightsigning yes" | out-null
    
    Clear-Host

    if ($flightSigningFlag -ne 1) {
        Restart-Question
    }
}

function Restart-Question {
    $choice = read-host "Your computer needs to restart. Restart now? (y/n)"
    if ($choice -eq 'y') {
        Restart-Computer
    }
    else {
        "You will need to manually restart your computer."
    }
}

#modify registry keys
Switch ($choice) {
    R {
        #reset / opt out
        Reset-Registry-Config
        cmd.exe /c "bcdedit /deletevalue { current } flightsigning" | out-null
        "You have successfully opted out of insider builds."

        if ($flightSigningFlag -ne 0) {
            Restart-Question
        }
        Break
    }
    1 {
        #release preview
        Edit-Insider-Builds "RingPreview" "RP" "Current" "Release Preview" 
        Break
    }
    2 { 
        #beta / slow
        Edit-Insider-Builds "RingInsiderSlow" "WIS" "Active" "Windows Insider Slow" 
        Break
    }
    3 { 
        #dev channel / fast
        Edit-Insider-Builds "RingInsiderFast" "WIF" "Active" "Windows Insider Fast" 
        Break
    }
    default {
        #quit
        "Exiting without making changes"
        exit 0
    }
}

Set-Location C:
"Exiting..."
return 0