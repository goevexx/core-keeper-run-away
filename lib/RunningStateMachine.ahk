#Requires AutoHotkey v2.0

; The Machine managing the mining state
class RunningStateMachine {
    __New(directionChangeThreshhold := 750, eatThreshhold := 60000) {
        this.directionChangeThreshhold := directionChangeThreshhold
        this.eatThreshhold := eatThreshhold
        
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
        this.currentState.handle()
    }

    reset() {
        for direction in DirectionStepper.directions {
            SendInput("{" . this.directionKeys[direction] . " up}")
        }
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
    directionChangeThreshhold => this.context.directionChangeThreshhold
    eatThreshhold => this.context.eatThreshhold
}


; State implementations

; Standing in a free place
class IdleState extends RunningStateMachineState {
    handle(){
        this.startRunning()
    }

    startRunning(){
        this.directionStepper.reset()
        this.changeState(RunningState(this.context))
    }
}

; Running in a direction
class RunningState extends RunningStateMachineState {
    __New(context) {
        super.__New(context)
        this.lastTimeEat := 0
        this.lastTimeDirectionChanged := A_TickCount
    }

    handle(){
        if(this.getElapsedTimeSinceDirectionChange() > this.directionChangeThreshhold){
            this.nextDirection()
        }
        if(this.getElapsedTimeSinceEat() > this.eatThreshhold){
            this.eat()
        } 
        this.run()
    }

    eat(){
        Click("Right")
        this.lastTimeEat := A_TickCount
    }

    nextDirection(){
        this.stop()
        this.directionStepper.next()
        this.lastTimeDirectionChanged := A_TickCount
    }

    getElapsedTimeSinceDirectionChange(){
        elapsedTime := A_TickCount - this.lastTimeDirectionChanged
        return elapsedTime
    }

    getElapsedTimeSinceEat(){
        elapsedTime := A_TickCount - this.lastTimeEat
        return elapsedTime
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
