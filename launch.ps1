#Requires -RunAsAdministrator

#If you are reading this, you would probably appreciate some helpful documentation
#https://docs.microsoft.com/en-us/windows/deployment/update/how-windows-update-works

"Windows Insider Local"
"PowerShell Script v0.1 (March 2021)"
"by Jack Wesolowski ( @jackw2 on github)`n"

"This script bypasses the standard update procedures by Microsoft.
Additionally, you will need to use the script again when you want to opt-out
of the Windows Insider Program.`n"

#check windows version before running
$version = (Get-ItemProperty `
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId

"Currently running Windows Version: $version`n"
if ($version -lt 1909) {
    "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    "!!  This script has not been tested on versions prior to Windows 10 1909.           !!"
    "!!  Unless you have a time machine, that probably wouldn't be very useful anyways.  !!"
    "!!  Please update to 1909 before using this script.                                 !!"
    "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n"
    exit 0
}

read-host "Press enter to confirm you understand"
Clear-Host

"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
"┃                                                           ┃"
"┃     Windows Insider Bypass by Jack Wesolowski @jackw2     ┃"
"┃                                                           ┃"
"┃     Which channel should I pick?                          ┃"
"┃     See: tinyurl.com/InsiderChannels                      ┃"
"┃                                                           ┃"
"┣━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"
"┃   ┃                                                       ┃"
"┃ Q ┃ Quit without making changes                           ┃"
"┃ R ┃ Reset (opt out of insider builds)                     ┃"
"┃   ┃                                                       ┃"
"┃ 1 ┃ Release Preview                                       ┃"
"┃ 2 ┃ Beta (Slow)                                           ┃"
"┃ 3 ┃ Dev Channel (Fast)                                    ┃"
"┃   ┃                                                       ┃"
"┗━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

$choice = read-host "Press enter to confirm you understand"

#flight signed certificate check
$FlightSigningEnabled = 0
bcdedit /enum { current } | findstr /I /R /C:"^flightsigning *Yes$"
if ($LASTEXITCODE -eq 0) {
    $FlightSigningEnabled = 1
}

#resets registry to default
function Reset-Registry-Config {
    Remove-Item -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost"
    Remove-Item -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat"
    Remove-Item -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingPreview"
    Remove-Item -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderSlow"
    Remove-Item -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderFast"
}

function Edit-Insider-Builds {
    param(
        [string] $sls,
        [string] $ring,
        [string] $content,
        [string] $ringTitle
    )


}

#modify registry keys
Switch ($choice) {
    R {
        #reset / opt out
        Reset-Registry-Config
        bcdedit /deletevalue { current } flightsigning
        "You have successfully opted out of insider builds."
    }
    1 {
        #release preview
        Edit-Insider-Builds(
            "RingPreview",
            "RP",
            "Current",
            "Release Preview"
        )
    }
    2 { 
        #beta / slow
        Edit-Insider-Builds(
            "RingInsiderSlow",
            "WIS",
            "Active",
            "Windows Insider Slow"
        )
    }
    3 { 
        #dev channel / fast
        Edit-Insider-Builds(
            "RingInsiderFast",
            "WIF",
            "Active",
            "Windows Insider Fast"
        )
    }
    default {
        #quit
        "Exiting without making changes"
        exit 0
    }
}