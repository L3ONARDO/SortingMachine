@DATA
   DSPVAL       DW     0                    ;  part of value left to display
   DSPMASK      DW     0                    ;  mask for displaying current digit

@CODE
   DSPDIG       EQU    9                    ;  relative position of the 7-segment display digit selector
   DSPSEG       EQU    8                    ;  relative position of the 7-segment display segments

; Function for converting a digit into 7-segment display value
; Written by Rob Hoogerword (example for course 2IC30 Computer Systems)
; Argument: Digit in R0
; Return value: Segment value in R1
   Hex7Seg:     BRS   Hex7Seg_bgn           ;  Push address(tbl) onto stack and proceed at "bgn"
   Hex7Seg_tbl: CONS  %01111110             ;  7-segment pattern for '0'
                CONS  %00110000             ;  7-segment pattern for '1'
                CONS  %01101101             ;  7-segment pattern for '2'
                CONS  %01111001             ;  7-segment pattern for '3'
                CONS  %00110011             ;  7-segment pattern for '4'
                CONS  %01011011             ;  7-segment pattern for '5'
                CONS  %01011111             ;  7-segment pattern for '6'
                CONS  %01110000             ;  7-segment pattern for '7'
                CONS  %01111111             ;  7-segment pattern for '8'
                CONS  %01111011             ;  7-segment pattern for '9'
                CONS  %01110111             ;  7-segment pattern for 'A'
                CONS  %00011111             ;  7-segment pattern for 'b'
                CONS  %01001110             ;  7-segment pattern for 'C'
                CONS  %00111101             ;  7-segment pattern for 'd'
                CONS  %01001111             ;  7-segment pattern for 'E'
                CONS  %01000111             ;  7-segment pattern for 'F'
   Hex7Seg_bgn: AND   R0  %01111            ;  R0 := R0 MOD 16 , just to be safe...
                LOAD  R1  [SP++]            ;  R1 := address(tbl) (retrieve from stack)
                LOAD  R1  [R1+R0]           ;  R1 := tbl[R0]
                RTS

; Displays the value taken as argument on PP2 display
; Arguments: Value to display
; Return value: none
   display:     PUSH  R0                    ;  Save used registers
                PUSH  R1
                PUSH  R2
                PUSH  R3
                PUSH  R4
                LOAD  R3  [GB+DSPVAL]       ;  Get the digits left to display
                BNE   dispLp                ;  If something not displayed yet - skip
                LOAD  R3  [SP+6]            ;  Get the argument (value to display)
                LOAD  R2  %01               ;  Load the clean bitmask
                STOR  R2  [GB+DSPMASK]      ;  Rewrite the old bitmask
   dispLp:      LOAD  R2  [GB+DSPMASK]      ;  Load the bitmask for output
                DVMD  R3  10                ;  Get the last digit
                LOAD  R0  R4                ;  Put it in R0
                BRS   Hex7Seg               ;  Get the segments for PP2 display
                STOR  R1  [R5+DSPSEG]       ;  Store the segments
                STOR  R2  [R5+DSPDIG]       ;  Store the digit bitmask
                MULS  R2  2                 ;  Prepare for next digit (shift left)
                STOR  R3  [GB+DSPVAL]       ;  Save what's left to display for next time
                STOR  R2  [GB+DSPMASK]      ;  Save current bitmask
                PULL  R4
                PULL  R3                    ;  Restore used registers
                PULL  R2
                PULL  R1
                PULL  R0
                RTS

@END
