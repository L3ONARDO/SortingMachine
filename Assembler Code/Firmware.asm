@DATA
   STATE        DW     0                    ;  current state of execution (0..13)
   STOPPED      DW     0                    ;  is 1 iff machine should be stopped soon
   OUTS         DW     0                    ;  saved copy of OUTPUT
   BTNS         DW     0                    ;  saved copy of INPUT

@CODE
   IOAREA       EQU  -16                    ;  address of the I/O-Area, modulo 2^18
   INPUT        EQU    7                    ;  position of the input buttons (relative to IOAREA)
   OUTPUT       EQU   11                    ;  relative position of the power outputs
   TIMER        EQU   13                    ;  relative position of timer
   ADCONVS      EQU    6                    ;  input from b/w detector in bits 0..7
   DELTA        EQU   15                    ;  delay in timer steps - step for the checks (1.5 ms)
   DEBUG        EQU    1                    ;  set to 0 to disable debugging display output

; The body of the main program.
   start:       LOAD  R0  tmr_isr
                ADD   R0  R5                ;  R0 := memory address of tmr_isr routine
                LOAD  R1  16                ;  Address of Exception Descriptor for timer
                STOR  R0  [R1]              ;  Install TMR ISR
                LOAD  R5  IOAREA            ;  R5 := "address of the area with the I/O-registers"
                SETI  8                     ;  Set IE timer bit to true
   mainLoop:    OR    R0  R0                ;  Do nothing
                BRA   mainLoop

; Timer interrupt routine.
   tmr_isr:     LOAD  R1  [R5+TIMER]        ;  R1 := current timer value
                XOR   R1  $3FFFF            ;  Invert R1 bitwise
                ADD   R1  1                 ;  R1 := -R1
                STOR  R1  [R5+TIMER]        ;  TIMER = 0
                LOAD  R4  DELTA             ;  R4 := Delay in timer steps
                STOR  R4  [R5+TIMER]        ;  Add delay to timer
                BRS   work                  ;  Do the checks
                SETI  8                     ;  Set IE timer bit to true again
                RTE

; State machine.
; Represents the switch statement in the Java code.
   work:        LOAD  R1  DEBUG             ;  Should debugging output be on?
                BEQ   workNoDbg             ;  Skip if not
                LOAD  R1  [R5+ADCONVS]      ;  Can be instead: LOAD R1 [GB+STATE]
                AND   R1  $0FF              ;  Get lower 8 bits of ADCONVS
                PUSH  R1                    ;  Push the value to display
                BRS   display               ;  Display the value
                ADD   SP  1
   workNoDbg:   LOAD  R1  [GB+BTNS]         ;  Get saved buttons state
                XOR   R1  %1                ;  Invert it
                LOAD  R2  [R5+INPUT]        ;  Get current input state
                AND   R2  %011000000        ;  Take only Start/Stop and Abort btns
                AND   R1  R2                ;  !(previous) & current
                BEQ   workSkpStp            ;  If no new buttons pressed -- skip
                AND   R1  %010000000        ;  If 0, then Abort btn pressed
                BEQ   abort
                LOAD  R1  [GB+STATE]        ;  Start/Stop btn pressed
                CMP   R1  3                 ;  We ignore btns when initializing
                BLE   workSkpStp
                LOAD  R1  1
                STOR  R1  [GB+STOPPED]      ;  We should stop soon
   workSkpStp:  LOAD  R1  [R5+INPUT]        ;  Get current input
                AND   R1  %011000000        ;  Only interested in Start/Stop and Abort
                STOR  R1  [GB+BTNS]         ;  Save current btn state
                LOAD  R1  [GB+STATE]        ;  Get current state of execution
                CMP   R1  0                 ;  Initial State
                BEQ   winit
                CMP   R1  1                 ;  Initialization 1
                BEQ   winit1
                CMP   R1  2                 ;  Initialization 2
                BEQ   winit2
                CMP   R1  3                 ;  Ready State
                BEQ   wready
                CMP   R1  4                 ;  State Push
                BEQ   wsp
                CMP   R1  5                 ;  State Dispense
                BEQ   wsd
                CMP   R1  6                 ;  State White 1
                BEQ   wsw1
                CMP   R1  7                 ;  State White 2
                BEQ   wsw2
                CMP   R1  8                 ;  State White 3
                BEQ   wsw3
                CMP   R1  9                 ;  State White Stop
                BEQ   wsws
                CMP   R1  10                ;  State Black 1
                BEQ   wsb1
                CMP   R1  11                ;  State Black 2
                BEQ   wsb2
                CMP   R1  12                ;  State Black 3
                BEQ   wsb3
                CMP   R1  13                ;  State Black Stop
                BEQ   wsbs
                BRA   abort

   winit:       BRS   init
                BRA   apply

   winit1:      BRS   init1
                BRA   apply

   winit2:      BRS   init2
                BRA   apply

   wready:      BRS   ready
                BRA   apply

   wsp:         BRS   sp
                BRA   apply

   wsd:         BRS   sd
                BRA   apply

   wsw1:        BRS   sw1
                BRA   apply

   wsw2:        BRS   sw2
                BRA   apply

   wsw3:        BRS   sw3
                BRA   apply

   wsb1:        BRS   sb1
                BRA   apply

   wsb2:        BRS   sb2
                BRA   apply

   wsb3:        BRS   sb3
                BRA   apply

   wsws:        BRS   sws
                BRA   apply

   wsbs:        BRS   sbs
                BRA   apply

   apply:       LOAD  R1  [GB+OUTS]         ;  Get the saved state of outputs
                STOR  R1  [R5+OUTPUT]       ;  And send it to PP2
                RTS

; Description of states
@INCLUDE "PWM.asm"
@INCLUDE "Initialize.asm"
@INCLUDE "Dispense.asm"
@INCLUDE "White.asm"
@INCLUDE "Black.asm"
@INCLUDE "Stop.asm"
@INCLUDE "Display.asm"

@END
