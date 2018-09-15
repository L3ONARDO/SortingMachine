@DATA
   PWMCNT       DS     8                    ;  step counter for every output
   PWMDELTA     DS     8                    ;  delta for every output

@CODE

; The PWM routine for the motors.
; Should be called by a timer interrupt routine often enough.
; Argument on the stack: delta% the output should be high
; Argument on the stack: # of output bit (0..7)
; Return value: none
   pwm:         PUSH  R1                    ;  Save all the used registers
                PUSH  R2
                PUSH  R3
                PUSH  R4
                LOAD  R1  [SP+5]            ;  Get the output # from stack
                LOAD  R2  [SP+6]            ;  Get the delta from stack
                ADD   R1  GB
                STOR  R2  [R1+PWMDELTA]     ;  Save the delta for the output
                LOAD  R2  [GB+OUTS]         ;  Get the outputs
                LOAD  R3  [R1+PWMCNT]       ;  Get the current PWM counter
                SUB   R1  GB
                LOAD  R4  %01               ;  Output bitmask
   pwmOutBit:   CMP   R1  0
                BEQ   pwmSkipLoop
                MULS  R4  2                 ;  Shift left R1 times
                SUB   R1  1
                BRA   pwmOutBit
   pwmSkipLoop: LOAD  R1  [SP+5]            ;  Get output # again
                ADD   R1  GB
                CMP   R3  [R1+PWMDELTA]     ;  delta% of the time motor should be on
                BGE   pwmOutOff             ;  If it is more then delta% - disable
                OR    R2  R4                ;  Enable it
                BRA   pwmExit
   pwmOutOff:   XOR   R4  %1                ;  Invert the bitmask
                AND   R2  R4                ;  Disable motor
   pwmExit:     ADD   R3  10                ;  Increment counter
                MOD   R3  100               ;  Stay within 100%
                STOR  R3  [R1+PWMCNT]       ;  Update the counter
                STOR  R2  [GB+OUTS]         ;  Update the outputs
                PULL  R4                    ;  Restore all the used registers
                PULL  R3
                PULL  R2
                PULL  R1
                RTS

; Make sure that PWMed output is properly off now.
; Enough to call it once.
; Argument on the stack: # of output bit (0..7)
; Return value: none
   pwmOff:      PUSH  R1                    ;  Save all the used registers
                PUSH  R2
                PUSH  R4
                LOAD  R1  [SP+4]            ;  Get the output # from stack
                LOAD  R2  [GB+OUTS]         ;  Get the outputs
                LOAD  R4  %01               ;  Bitmask for outputs
   pwmOffOutp:  CMP   R1  0
                BEQ   pwmOffSkip
                MULS  R4  2                 ;  Get the bitmask for ith bit
                SUB   R1  1
                BRA   pwmOffOutp
   pwmOffSkip:  XOR   R4  %1                ;  Invert it
                AND   R2  R4                ;  Disable the output
                STOR  R2  [GB+OUTS]         ;  Store the new value
                LOAD  R1  [SP+4]            ;  Get the output # again
                ADD   R1  GB
                LOAD  R2  0
                STOR  R2  [R1+PWMCNT]       ;  Set corresponding counter to 0
                PULL  R4                    ;  Restore the used registers
                PULL  R2
                PULL  R1
                RTS

@END
