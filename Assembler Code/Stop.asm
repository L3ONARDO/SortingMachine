@DATA
   TMR          DW     0                    ;  Timer counter

@CODE

   abort:       LOAD  R1  0
                STOR  R1  [GB+OUTS]         ;  Set all outputs to 0
                STOR  R1  [GB+STATE]        ;  Goto INIT state
                STOR  R1  [GB+RIGHTTR]      ;  Set everything to 0
                STOR  R1  [GB+LEFTTR]
                STOR  R1  [GB+STOPPED]      ;  We do not stop
                STOR  R1  [GB+PWMCNT]       ;  Reset PWM
                STOR  R1  [GB+TMR]          ;  And timers
                STOR  R1  [GB+SWCNT]        ;  And counters
                STOR  R1  [GB+SBCNT]
                BRA   apply                 ;  Write to output

   sbs:         PUSH  R0                    ;  Save used registers
                PUSH  R1
                LOAD  R1  75                ;  delta = 75%
                PUSH  R1
                LOAD  R1  6
                PUSH  R1                    ;  Output 6 - for motor moving right
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R0  [R5+INPUT]        ;  Load input
                AND   R0  %0100             ;  Get the value of right detector
                BEQ   sbs1                  ;  If it is zero (i.e. there is a disc)
                LOAD  R1  [GB+TMR]          ;  Load timer
                CMP   R1  1000              ;  If timer == 1500 ms
                BGE   sbs2                  ;  Branch to sbs2 to abort
                ADD   R1  1                 ;  Increment timer by 1
                STOR  R1  [GB+TMR]          ;  Store timer back in memory
                PULL  R1                    ;  Restore used registers
                PULL  R0
                RTS

   sbs1:        LOAD  R1  0
                STOR  R1  [GB+TMR]          ;  Set timer to 0 again
                LOAD  R1  6
                PUSH  R1
                BRS   pwmOff                ;  Turn off the belt (output 6)
                ADD   SP  1
                LOAD  R1  3
                STOR  R1  [GB+STATE]        ;  Goto READY state
                PULL  R1                    ;  Restore used registers
                PULL  R0
                RTS

   sbs2:        LOAD  R1  0
                STOR  R1  [GB+TMR]          ;  Reset the timer
                PULL  R1                    ;  Restore used registers
                PULL  R0
                BRA abort                   ;  Abort

   sws:         PUSH  R0                    ;  Save used registers
                PUSH  R1
                LOAD  R1  75                ;  delta = 75%
                PUSH  R1
                LOAD  R1  7
                PUSH  R1                    ;  Output 7 - for motor moving left
                BRS   pwm                   ;  PWM the dispenser motor
                ADD   SP  2                 ;  Clear the stack
                LOAD  R0  [R5+INPUT]        ;  Load input
                AND   R0  %01               ;  Get the value of left detector
                BEQ   sws1                  ;  If it is zero (i.e. there is a disc)
                LOAD  R1  [GB+TMR]          ;  Load timer
                CMP   R1  1000              ;  If timer == 1500 ms
                BGE   sws2                  ;  Branch to sws2 to abort
                ADD   R1  1                 ;  Increment timer by 1
                STOR  R1  [GB+TMR]          ;  Store timer back in memory
                PULL  R1                    ;  Restore used registers
                PULL  R0
                RTS

   sws1:        LOAD  R1  0
                STOR  R1  [GB+TMR]          ;  Set timer to 0 again
                LOAD  R1  7
                PUSH  R1
                BRS   pwmOff                ;  Turn off the belt (output 7)
                ADD   SP  1
                LOAD  R1  3
                STOR  R1  [GB+STATE]        ;  Goto READY state
                PULL  R1                    ;  Restore used registers
                PULL  R0
                RTS

   sws2:        LOAD  R1  0
                STOR  R1  [GB+TMR]          ;  Reset the timer
                PULL  R1                    ;  Restore used registers
                PULL  R0
                BRA abort                   ;  Abort

@END
