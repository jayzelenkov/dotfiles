#!/bin/bash

# Maps app names to sketchybar-app-font glyph names
case $@ in
"Brave Browser")        icon_result=":brave_browser:" ;;
"Cursor")               icon_result=":code:" ;;
"Final Cut Pro")        icon_result=":final_cut_pro:" ;;
"FaceTime")             icon_result=":face_time:" ;;
"Messages" | "Nachrichten") icon_result=":messages:" ;;
"Twitter")              icon_result=":twitter:" ;;
"Microsoft Edge")       icon_result=":microsoft_edge:" ;;
"VLC")                  icon_result=":vlc:" ;;
"Notes")                icon_result=":notes:" ;;
"Spark")                icon_result=":spark:" ;;
"Things" | "Microsoft To Do") icon_result=":things:" ;;
"GitHub Desktop")       icon_result=":git_hub:" ;;
"App Store")            icon_result=":app_store:" ;;
"Chromium" | "Google Chrome" | "Google Chrome Canary") icon_result=":google_chrome:" ;;
"zoom.us")              icon_result=":zoom:" ;;
"Microsoft Word")       icon_result=":microsoft_word:" ;;
"Microsoft Teams")      icon_result=":microsoft_teams:" ;;
"Sublime Text")         icon_result=":sublime_text:" ;;
"Mattermost")           icon_result=":mattermost:" ;;
"WhatsApp")             icon_result=":whats_app:" ;;
"OBS")                  icon_result=":obsstudio:" ;;
"Microsoft Excel")      icon_result=":microsoft_excel:" ;;
"Microsoft PowerPoint") icon_result=":microsoft_power_point:" ;;
"Numbers")              icon_result=":numbers:" ;;
"Bear")                 icon_result=":bear:" ;;
"Firefox Developer Edition" | "Firefox Nightly") icon_result=":firefox_developer_edition:" ;;
"Notion")               icon_result=":notion:" ;;
"Evernote Legacy")      icon_result=":evernote_legacy:" ;;
"Calendar" | "Fantastical") icon_result=":calendar:" ;;
"Xcode")                icon_result=":xcode:" ;;
"Slack")                icon_result=":slack:" ;;
"Bitwarden")            icon_result=":bit_warden:" ;;
"System Preferences" | "System Settings") icon_result=":gear:" ;;
"Discord" | "Discord Canary" | "Discord PTB") icon_result=":discord:" ;;
"Firefox")              icon_result=":firefox:" ;;
"Telegram")             icon_result=":telegram:" ;;
"Blender")              icon_result=":blender:" ;;
"Canary Mail" | "HEY" | "Mail" | "Mailspring" | "MailMate" | "Outlook") icon_result=":mail:" ;;
"Safari" | "Safari Technology Preview") icon_result=":safari:" ;;
"Keynote")              icon_result=":keynote:" ;;
"Spotify")              icon_result=":spotify:" ;;
"Figma")                icon_result=":figma:" ;;
"Spotlight")            icon_result=":spotlight:" ;;
"Music")                icon_result=":music:" ;;
"Alfred" | "Raycast")   icon_result=":alfred:" ;;
"Pages")                icon_result=":pages:" ;;
"1Password 7" | "1Password") icon_result=":one_password:" ;;
"Code" | "Code - Insiders") icon_result=":code:" ;;
"Tower")                icon_result=":tower:" ;;
"Calibre")              icon_result=":book:" ;;
"Finder" | "访达")       icon_result=":finder:" ;;
"Linear")               icon_result=":linear:" ;;
"Signal")               icon_result=":signal:" ;;
"Obsidian")             icon_result=":obsidian:" ;;
"Podcasts")             icon_result=":podcasts:" ;;
"Ghostty" | "Alacritty" | "iTerm2" | "Terminal" | "WezTerm") icon_result=":terminal:" ;;
"Sketch")               icon_result=":sketch:" ;;
"Sequel Ace" | "Postico") icon_result=":sequel_ace:" ;;
"Todoist")              icon_result=":todoist:" ;;
"OmniFocus")            icon_result=":omni_focus:" ;;
"Reminders")            icon_result=":reminders:" ;;
"Preview" | "Skim")     icon_result=":pdf:" ;;
*)                      icon_result=":default:" ;;
esac

echo $icon_result
