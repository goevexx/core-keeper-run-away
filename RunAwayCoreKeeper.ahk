#SingleInstance Force
#Include "lib/RunningStateMachine.ahk"

readyToStart := false
startRunning := false
instructions := "1. Open Core Keeper.`n2. Move your character to a position so that you have enough space to move in all directions.`n3. Take some food or drink with speed buff in your hand. It will be eaten after time.`n4. Press CTRL + F to get started power up your running skill.`n`nControls:`nPress CTRL + F to stop/start the procedure`nPress CTRL + Q to quit this script"

resultOk := MsgBox("Hey there core keepers`n`nIt's a nice day to go running, ain't it? Huho.`n`n" . instructions, "Core Keeper - RunAway", 0)
readyToStart := resultOk = "OK"
if !readyToStart
    ExitApp

runningMachine := RunningStateMachine()
Loop {
    if (!startRunning) {
        continue
    }

    If !WinExist("Core Keeper") {
        MsgBox("Core Keeper is not open. You need to obey:`n`n" . instructions, "RunAway - Core Keeper not open", "OK")
        startRunning := false
        runningMachine.reset()
        continue
    }
    If !WinActive("Core Keeper") {
        yesResult := MsgBox("Core Keeper needs to be your active window.`n`nWait, let me activate it...", "RunAway - Core Keeper not active", "YesNo")
        if (yesResult = "Yes"){
            WinActivate("Core Keeper")
            startRunning := true
        } else if (yesResult = "No"){
            startRunning := false
        }
        runningMachine.reset()
        continue
    } 

    runningMachine.handleState()
}

$^f::{
    global
    if(readyToStart) {
        startRunning := !startRunning
        runningMachine.reset()
    }
}
$^q::ExitApp