#Requires -RunAsAdministrator

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

"╭───────────────────────────────────────────────────╮"
"│                                                   │"
"│ Windows Insider Bypass by Jack Wesolowski @jackw2 │"
"│                                                   │"
"│ Which channel should I pick?                      │"
"│ See: tinyurl.com/InsiderChannels                  │"
"│                                                   │"
"├───────────────────────────────────────────────────┤"
"│   │                                               │"
"│ Q │ Quit without making changes                   │"
"│ R │ Reset (opt out of insider builds)             │"
"│   │                                               │"
"│ 1 │ Release Preview                               │"
"│   │                                               │"
"│ 2 │ Beta                                          │"
"│   │                                               │"
"│ 3 │ Dev Channel                                   │"
"│   │                                               │"
"│   │                                               │"
"│   │                                               │"
"╰───┴───────────────────────────────────────────────╯"