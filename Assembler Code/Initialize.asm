@CODE

; Subroutine that gets invoked in the INIT state
; Takes no arguments
; Return value: none
   init:        PUSH  R1                    ;  Save used register
                LOAD  R1  [R5+INPUT]
                AND   R1  %010000000        ;  If start/stop btn not pressed
                BEQ   initExit              ;  Continue
                LOAD  R1  [R5+INPUT]
                AND   R1  %01000            ;  Check if dispenser btn is pressed
                BEQ   initToInit1           ;  If not - go to INIT1 state
                LOAD  R1  2
                STOR  R1  [GB+STATE]        ;  Else go to INIT2 state
                BRA   initExit
   initToInit1: LOAD  R1  1                 ;  Goto INIT1 state
                STOR  R1  [GB+STATE]
   initExit:    PULL  R1                    ;  Restore used register
                RTS

; Subroutine that gets invoked in the INIT1 state
; Takes no arguments
; Return value: none
   init1:       PUSH  R1
                LOAD  R1  70                ;  delta = 70%
                PUSH  R1
                LOAD  R1  0
                PUSH  R1                    ;  Output 0 - for dispenser motor
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  [R5+INPUT]
                AND   R1  %01000            ;  If dispenser btn not pressed
                BEQ   init1SkpIn2
                LOAD  R1  2                 ;  Go to state INIT2
                STOR  R1  [GB+STATE]
   init1SkpIn2: PULL  R1
                RTS

; Subroutine that gets invoked in the INIT2 state
; Takes no arguments
; Return value: none
   init2:       PUSH  R1
                LOAD  R1  70                ;  delta = 70%
                PUSH  R1
                LOAD  R1  0
                PUSH  R1                    ;  Output 0 - for dispenser motor
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  [R5+INPUT]
                AND   R1  %01000            ;  If dispenser btn not pressed
                BEQ   init2ToReady          ;  Go to state READY
                PULL  R1
                RTS

  init2ToReady: LOAD  R1  0
                PUSH  R1
                BRS   pwmOff                ;  Make sure that dispenser motor is off
                ADD   SP  1
                LOAD  R1  [GB+OUTS]
                OR    R1  %01100            ;  Turn on the lamps
                STOR  R1  [GB+OUTS]
                LOAD  R1  3
                STOR  R1  [GB+STATE]        ;  Go to state READY
                PULL  R1
                RTS

@END