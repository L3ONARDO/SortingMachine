@CODE

; Subroutine that gets invoked in the READY state
; Takes no arguments
; Return value: none
   ready:       PUSH  R1
                LOAD  R1  [R5+INPUT]	    ;  Get buttons state
                AND   R1  %010000000		;  Start/Stop btn
                BEQ   readySkip 			;  Skip if button not pressed
                LOAD  R1  [R5+INPUT]		;  Get buttons state
                AND   R1  %010				;  Presence Detector
                BNE   readySkip		    	;  Skip if no discs at detector
                LOAD  R1  4                 ;  Go to state SP
                STOR  R1  [GB+STATE]
                LOAD  R1  0
                STOR  R1  [GB+STOPPED]      ;  Stopped = false
                STOR  R1  [GB+SWCNT]        ;  White counter = 0
                STOR  R1  [GB+SBCNT]        ;  Black counter = 0
   readySkip:   PULL  R1
                RTS

; Subroutine that gets invoked in the SP state
; Takes no arguments
; Return value: none
   sp:          PUSH  R1
                LOAD  R1  70                ;  delta = 70%
                PUSH  R1
                LOAD  R1  0
                PUSH  R1                    ;  Output 0 - for dispenser motor
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R1  [R5+INPUT]	    ;  Get buttons state
                AND   R1  %01000			;  Check dispenser button
                BEQ	  spSkip 				;  Skip if not pressed
                LOAD  R1  5                 ;  Go to state SD
                STOR  R1  [GB+STATE]
                LOAD  R1  0
                PUSH  R1
                BRS   pwmOff                ;  Make sure that dispenser motor is off
                ADD   SP  1
   spSkip:      PULL  R1
                RTS

; Subroutine that gets invoked in the SD state
; Takes no arguments
; Return value: none
   sd:          PUSH  R1
                LOAD  R1  0
                STOR  R1  [GB+LEFTTR]       ;  Left disc detected = false
                STOR  R1  [GB+RIGHTTR]      ;  Right disc detected = false
                LOAD  R1  [R5+ADCONVS]      ;  Load value of BW detector
                AND   R1  $0FF              ;  Only bits 0..7
                CMP   R1  90
                BGE   sdSkipWh              ;  Less than 90
                LOAD  R1  6                 ;  Go to state SW1
                STOR  R1  [GB+STATE]
                BRA   sdCont
   sdSkipWh:    CMP   R1  190
                BGE   sdSkipBl              ;  More than 90, less than 190
                LOAD  R1  10                ;  Go to state SB1
                STOR  R1  [GB+STATE]
                BRA   sdCont
   sdSkipBl:    PULL  R1
                BRA   abort                 ;  Otherwise abort
   sdCont:      PULL  R1
                RTS

@END
