#Requires AutoHotkey v2.0

; The Machine managing the mining state
class RunningStateMachine {
    __New(directionChangeThreshhold := 750) {
        this.directionChangeThreshhold := directionChangeThreshhold
        
        this.initState()
    }

    initState(){
        this.directionStepper := DirectionStepper()
        this.setState(IdleState(this))
    }

    setState(state) {
        if(HasProp(this, "currentState")){
            previoustateName := this.currentState.__Class
        } else {
            previoustateName := "(no state)"
        }
        this.currentState := state
    }

    handleState(){
        if(this.currentState.getElapsedTime() > this.directionChangeThreshhold){
            this.currentState.stop()
            this.directionStepper.next()
            this.setState(RunningState(this))
        }  
        this.currentState.handle()
    }

    reset() {
        this.currentState.stop()
        this.initState()
    }

    directionKeys[direction] {
        get {
            Switch (direction) {
                Case "right":
                    return "d"
                Case "left":
                    return "a"
                Case "top":
                    return "w"
                Case "bottom":
                    return "s"
            }
        }
    }

    direction => this.directionStepper.value
}

; The way your current state looks like while you are mining
class RunningStateMachineState {
    __New(context) {
        this.context := context
        this.startTime := A_TickCount
        this.isRunning := false
    }

    ; Sets the context's state
    changeState(state){
        this.stop()
        this.context.setState(state)
    }

    ; Needs to be implemented in subclasses
    handle(){
    }

    ; Get's elapsed time in ms
    getElapsedTime(){
        elapsedTime := A_TickCount - this.startTime
        return A_TickCount - this.startTime
    }

    stop() {
        SendInput("{" . this.directionKey . " up}")
        this.isRunning := false
    }

    run() {
        if(!this.isRunning){
            SendInput("{" . this.directionKey . " down}")
            this.isRunning := true
        }
    }

    directionKey => this.context.directionKeys[this.direction]
    directionStepper => this.context.directionStepper
    direction => this.directionStepper.value
}


; State implementations

; Standing next to the ground on all directions
class IdleState extends RunningStateMachineState {
    handle(){
        this.startRunning()
    }

    startRunning(){
        this.directionStepper.reset()
        this.changeState(RunningState(this.context))
    }
}

; No Block in direction
class RunningState extends RunningStateMachineState {
    handle(){
        this.run()
    }
}

; Pointer to current direction
class DirectionStepper {
    static directions := ["right", "bottom", "left", "top"]
    currentIndex := 1
    value {
        get => DirectionStepper.directions[this.currentIndex]
    }

    isLast() {
        return this.currentIndex = DirectionStepper.directions.length
    }
    
    isFirst() {
        return this.currentIndex = 1
    }

    next(){
        this.currentIndex := Mod(this.currentIndex, DirectionStepper.directions.length) + 1
    }

    reset(){
        this.currentIndex := 1
    }
}
