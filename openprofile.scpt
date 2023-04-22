#!/usr/bin/env osascript
(*
    open an iterm profile in either a new tab or a new window

    inspired by and adapted from
    https://github.com/vitorgalvao/custom-alfred-iterm-scripts
*)

-- functions
on new_window(theProfile)
    tell application "iTerm" to create window with profile theProfile
end new_window


on new_tab(theProfile)
    -- we have to check if a window is open because if there aren't
    -- windows open, the applescript to create a tab will fail
    if has_windows() then
        tell application "iTerm" to tell the first window to create tab with profile theProfile
    else
        new_window(theProfile)
    end if
end new_tab


on has_windows()
  if not is_running() then return false
  tell application "iTerm"
    if windows is {} then return false
    if tabs of current window is {} then return false
    if sessions of current tab of current window is {} then return false

    set session_text to contents of current session of current tab of current window
    if words of session_text is {} then return false
  end tell
  true
end has_windows


on is_running()
    application "iTerm" is running
end is_running

--
-- entry point, equivilent to main()
on run argv
    set theProfile to item 1 of argv
    set openin to (system attribute "profile_opens_in")

    if openin = "tab" then
        new_tab(theProfile)
    else
        new_window(theProfile)
    end if
    tell application "iTerm" to activate
end run
