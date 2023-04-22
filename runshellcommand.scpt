#!/usr/bin/env osascript
(*
    run a shell command in an iterm window or tab

    inspired by and adapted from
    https://github.com/vitorgalvao/custom-alfred-iterm-scripts
*)

-- functions
on new_window(theProfile)
    tell application "iTerm"
        set theWindow to create window with profile theProfile
        set theSession to the current session of the current tab of theWindow
    end tell
    return theSession
end new_window


on new_tab(theProfile)
    -- we have to check if a window is open because if there aren't
    -- windows open, the applescript to create a tab will fail
    if has_windows() then
        tell application "iTerm"
            set theTab to create tab of the front window with profile theProfile
            set theSession to the current session of the theTab
        end tell
        return theSession
    else
        return new_window(theProfile)
	end if
end new_tab


on has_windows()
  if not is_running() then return false

  tell application "iTerm"
    try
        if windows is {} then return false
        if tabs of current window is {} then return false
        if sessions of current tab of current window is {} then return false
        set session_text to contents of current session of current tab of current window
        if words of session_text is {} then return false
    on error
        return false
    end try
  end tell
  true
end has_windows


on is_running()
    application "iTerm" is running
end is_running


on send_text(theSession, custom_text)
    set text_delay to 0
    try
        -- this might fail, or might not be a number, if so, default is 0
        set text_delay to (system attribute "delay_before_typing") as number
    end try
    -- Make sure a window exists before we continue, or the write may fail
    -- "with timeout" does not work with a "repeat"
    -- Delay of 0.05 seconds repeated 100 times means a timeout of 5 seconds
    repeat 100 times
        if has_windows() then
            -- now that the window has showed up wait for
            -- the workflow config delay for shell initialization
            -- to occur
            delay text_delay
            tell application "iTerm" to tell theSession to write text custom_text
            exit repeat
        end if
        delay 0.05
    end repeat
end send_text


--
-- entry point, equivilent to main()
on run argv
    set theCommand to item 1 of argv
    set runs_in to (system attribute "command_runs_in")
    set command_profile to (system attribute "command_profile")
    --set iterm_opens_quietly to (system attribute "opens_quietly")

    if runs_in = "window" then
        set theSession to new_window(command_profile)
    else if runs_in = "tab" then
        set theSession to new_tab(command_profile)
    else if runs_in = "session" then
        if not has_windows() then
            set theSession to new_window(command_profile)
        else
            tell application "iTerm"
                set theSession to current session of current tab of current window
            end tell
        end if
    end if
    tell application "iTerm" to activate
    send_text(theSession, theCommand)
end run
