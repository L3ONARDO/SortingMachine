@DATA
   LEFTTR       DW     0                    ;  disc reached left tray?
   SWCNT        DW     0                    ;  counter for belt skipping

@CODE

; Subroutine that gets invoked in the SW1 state
; Takes no arguments
; Return value: none
   sw1:         PUSH  R1                    ;  Save used registers
                LOAD  R1  [GB+SWCNT]        ;  Get the counter
                ADD   R1  1
                STOR  R1  [GB+SWCNT]        ;  Increment it and store it back
                CMP   R1  8
                BLE   sw1skip               ;  Don't turn on belt for first 12 ms
                LOAD  R1  80                ;  delta = 80%
                PUSH  R1
                LOAD  R1  7
                PUSH  R1                    ;  Output 7 - for motor moving left
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
   sw1skip:     LOAD  R1  60                ;  delta = 60%
                PUSH  R1
                LOAD  R1  0
                PUSH  R1                    ;  Output 0 - for dispenser motor
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  [R5+INPUT]        ;  Get the input
    	        AND   R1  %01               ;  Left tray detector has detected disc
    	        BNE   sw1SkipTray
                LOAD  R1  1
                STOR  R1  [GB+LEFTTR]       ;  Record that
   sw1SkipTray: LOAD  R1  [R5+INPUT]
                AND   R1  %01000            ;  If dispenser btn is pressed
                BNE   sw1SkipChk            ;  Skip further checks
                LOAD  R1  [R5+INPUT]
                AND   R1  %010              ;  Check if more discs are present
                BNE   sw1ToSws
                LOAD  R1  [GB+STOPPED]      ;  Check if Stop btn has been pressed
                BNE   sw1ToSws
                LOAD  R1  7                 ;  Go to state SW2
                STOR  R1  [GB+STATE]
                LOAD  R1  0
                STOR  R1  [GB+SWCNT]        ;  Set counter back to 0
   sw1SkipChk:  PULL  R1                    ;  Restore used registers
    	        RTS

   sw1ToSws:    LOAD  R1  0
                PUSH  R1
                BRS   pwmOff                ;  Make sure that dispenser motor is off
                ADD   SP  1
                LOAD  R1  9                 ;  Go to state SWS
                STOR  R1  [GB+STATE]
                PULL  R1                    ;  Restore used registers
                RTS

; Subroutine that gets invoked in the SW2 state
; Takes no arguments
; Return value: none
   sw2:         PUSH  R1                    ;  Save used registers
                LOAD  R1  60                ;  delta = 60%
                PUSH  R1
                LOAD  R1  0
                PUSH  R1                    ;  Output 0 - for dispenser motor
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  80                ;  delta = 80%
                PUSH  R1
                LOAD  R1  7
                PUSH  R1                    ;  Output 7 - for motor moving left
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  [R5+INPUT]
    	        AND   R1  %01               ;  Left tray detector has detected disc
    	        BNE   sw2SkipTray
                LOAD  R1  1
                STOR  R1  [GB+LEFTTR]       ;  Record that
   sw2SkipTray: LOAD  R1  [R5+INPUT]
                AND   R1  %01000            ;  If dispenser btn is not pressed
                BEQ   sw2SkipChk            ;  Skip further checks
                LOAD  R1  0
                PUSH  R1
                BRS   pwmOff                ;  Make sure that dispenser motor is off
                ADD   SP  1
                LOAD  R1  7
                PUSH  R1
                BRS   pwmOff                ;  Make sure that belt motor is off
                ADD   SP  1
                LOAD  R1  8                 ;  Go to state SW3
                STOR  R1  [GB+STATE]
   sw2SkipChk:  PULL  R1                    ;  Restore used registers
                RTS

; Subroutine that gets invoked in the SW3 state
; Takes no arguments
; Return value: none
   sw3:         PUSH  R1                    ;  Save used registers
                LOAD  R1  [GB+LEFTTR]	    ;  Check if disc has reached the tray
                BEQ   sw3abort              ;  If not - abort
                LOAD  R1  5                 ;  Otherwise go to state SD
                STOR  R1  [GB+STATE]
                PULL  R1                    ;  Restore used registers
                RTS

   sw3abort:    PULL  R1                    ;  Restore used registers
                BRA   abort                 ;  Abort

 @END