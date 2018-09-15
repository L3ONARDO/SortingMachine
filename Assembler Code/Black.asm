@DATA
   RIGHTTR      DW     0                    ;  disc reached right tray?
   SBCNT        DW     0                    ;  counter for belt skipping

@CODE

; Subroutine that gets invoked in the SB1 state
; Takes no arguments
; Return value: none
   sb1:         PUSH  R1                    ;  Save used registers
                LOAD  R1  [GB+SBCNT]        ;  Get the counter
                ADD   R1  1
                STOR  R1  [GB+SBCNT]        ;  Increment it and store it back
                CMP   R1  8
                BLE   sb1skip               ;  Don't turn on belt for first 12 ms
                LOAD  R1  80                ;  delta = 80%
                PUSH  R1
                LOAD  R1  6
                PUSH  R1                    ;  Output 6 - for motor moving right
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
   sb1skip:     LOAD  R1  50                ;  delta = 60%
                PUSH  R1
                LOAD  R1  0
                PUSH  R1                    ;  Output 0 - for dispenser motor
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  [R5+INPUT]        ;  Get the input
    	        AND   R1  %0100             ;  Right tray detector has detected disc
    	        BNE   sb1SkipTray
                LOAD  R1  1
                STOR  R1  [GB+RIGHTTR]      ;  Record that
   sb1SkipTray: LOAD  R1  [R5+INPUT]
                AND   R1  %01000            ;  If dispenser btn is pressed
                BNE   sb1SkipChk            ;  Skip further checks
                LOAD  R1  [R5+INPUT]
                AND   R1  %010              ;  Check if more discs are present
                BNE   sb1ToSbs
                LOAD  R1  [GB+STOPPED]      ;  Check if Stop btn has been pressed
                BNE   sb1ToSbs
                LOAD  R1  11                ;  Go to state SB2
                STOR  R1  [GB+STATE]
                LOAD  R1  0
                STOR  R1  [GB+SBCNT]        ;  Set counter back to 0
   sb1SkipChk:  PULL  R1                    ;  Restore used registers
    	        RTS

   sb1ToSbs:    LOAD  R1  0
                PUSH  R1
                BRS   pwmOff                ;  Make sure that dispenser motor is off
                ADD   SP  1
                LOAD  R1  13                ;  Go to state SBS
                STOR  R1  [GB+STATE]
                PULL  R1                    ;  Restore used registers
                RTS

; Subroutine that gets invoked in the SB2 state
; Takes no arguments
; Return value: none
   sb2:         PUSH  R1                    ;  Save used registers
                LOAD  R1  50                ;  delta = 60%
                PUSH  R1
                LOAD  R1  0
                PUSH  R1                    ;  Output 0 - for dispenser motor
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  80                ;  delta = 80%
                PUSH  R1
                LOAD  R1  6
                PUSH  R1                    ;  Output 6 - for motor moving right
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  [R5+INPUT]
    	        AND   R1  %0100             ;  Right tray detector has detected disc
    	        BNE   sb2SkipTray
                LOAD  R1  1
                STOR  R1  [GB+RIGHTTR]      ;  Record that
   sb2SkipTray: LOAD  R1  [R5+INPUT]
                AND   R1  %01000            ;  If dispenser btn is not pressed
                BEQ   sb2SkipChk            ;  Skip further checks
                LOAD  R1  0
                PUSH  R1
                BRS   pwmOff                ;  Make sure that dispenser motor is off
                ADD   SP  1
                LOAD  R1  6
                PUSH  R1
                BRS   pwmOff                ;  Make sure that belt motor is off
                ADD   SP  1
                LOAD  R1  12                ;  Go to state SB3
                STOR  R1  [GB+STATE]
   sb2SkipChk:  PULL  R1                    ;  Restore used registers
                RTS

; Subroutine that gets invoked in the SB3 state
; Takes no arguments
; Return value: none
   sb3:         PUSH  R1                    ;  Save used registers
   sb3NoStop:   LOAD  R1  [GB+RIGHTTR]	    ;  Check if disc has reached the tray
                BEQ   sb3abort              ;  If not - abort
                LOAD  R1  5                 ;  Otherwise go to state SD
                STOR  R1  [GB+STATE]
                PULL  R1                    ;  Restore used registers
                RTS

   sb3abort:    PULL  R1                    ;  Restore used registers
                BRA   abort                 ;  Abort

 @END