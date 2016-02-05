;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; MICHAEL LIUT - 1132938 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include "asm_io.inc"     ; include Franek's asm_io.inc file

SECTION .data             ; initilized data

err3: db "No Arguments Inputted",10,0         ; error message #3 - num check
err2: db "Too Many Arguments",10,0            ; error message #2 - num check
err1: db "Argument Out of Range",10,0         ; error message #1 - num check
err: db "Incorrect Argument Inputted",10,0    ; error message - non-num check

towerNames: db "       Tower 1                  Tower 2                  Tower 3 ", 10, 0
done: db "                             COMPLETED!!!",10,0    ; succesful completion message

t0: db "         |         ",0    ; initialized 'tree' --> i.e. peg stack
t1: db "        +|+        ",0
t2: db "       ++|++       ",0
t3: db "      +++|+++      ",0
t4: db "     ++++|++++     ",0
t5: db "    +++++|+++++    ",0
t6: db "   ++++++|++++++   ",0
t7: db "  +++++++|+++++++  ",0
t8: db " ++++++++|++++++++ ",0
t9: db "XXXXXXXXXXXXXXXXXXX",0

space: db "      ",0

numOfDisks: dd 0     ; Number of disks inputted by user - argument

; format for number of disks to provide user feedback
fmt: db "                      You have inputted: %d disks.",10,0

tStar: db "         *         ",0
treeFmt: db "%s",10,"%s",10,"%s",10,"%s",10,"%s",10,"%s",10,"%s",10,"%s",10,"%s",10,"%s",10,"%s",10,0

; wait message to provide user feedback - i.e. press enter key
waits: db "        The Program Waits Until The User Hits The Enter Key!",10,0 

arr1: dd 0,0,0,0,0,0,0,0,9
arr2: dd 0,0,0,0,0,0,0,0,9
arr3: dd 0,0,0,0,0,0,0,0,9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION .bss         ; Input variables

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION .text     ; assembly code
   global asm_main
   extern printf
   extern getchar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getNumOfDisks:
   pusha                           ; push all registers onto stack

   mov edx, dword 0                ; set edx to zero
   mov ecx, dword[ebp+8]           ; ecx holds argv
   mov eax, dword[ebp+12]          ; save the first argument in eax
   add eax, 4                      ; move the pointer to main argument
   mov ebx, dword[eax]             ; save number in ebx

   push ebx                        ; push ebx to stack
   push ecx                        ; push ecx to stack

   cmp ecx, dword 2                ; checks if there multiple arguments >1
   jg tooManyArgs                  ; if above is True, jump

   cmp ecx, dword 1                ; checks if there are no arguments
   jle noArgs                      ; if above is True, jump

   mov ecx, 0                      ; set ecx to zero
   movzx eax, byte[ebx+ecx]        ; eax is the first character number from the inputed number
   sub eax, 48                     ; gets real number/letter/symbol
   cmp eax, 10                     ; check if eax is less then 10, i.e. not a number
   jg wrongArg                     ; if above is True, jump
      
      convertToInteger:                ; convert str to int
         add edx, eax                  ; add 'number' into edx
         inc ecx                       ; counter++
         movzx eax, byte[ebx+ecx]      ; put next number into eax
         cmp eax, 0                    ; check if eax = 0
         mov [numOfDisks], edx         ; update numOfDisks - global variable
         je checkRange                 ; check disk input is between 2-8
         sub eax, 48                   ; gets real number/letter/symbol
         cmp eax, 10                   ; check if eax is less then 10, i.e. not a number
         jg wrongArg                   ; jump if eax > 10, i.e. not a number
         imul edx, 10                  ; edx manipulation for string addition
         jmp convertToInteger          ; jump if not completed

      checkRange:                  ; check range of numOfDisks Inputted by user
        cmp edx, dword 8           ; compare edx with max disks
        jg argOutOfRange           ; jump if numOfDisks > 8
        cmp edx, dword 2           ; compare edx with min disks
        jl argOutOfRange           ; jump if numOfDisks < 2

   pop ebx                ; restore register ebx
   pop ecx                ; restore register ecx
   popa                   ; restore all registers
   ret                    ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

displayTowers:
   enter 0,0              ; setup routine
   pusha                  ; save all registers

   mov eax, 0             ; initialize eax to 0
   mov ebx, 0             ; initialize counter (ebx) to 0

   push towerNames        ; store label towerNames on stack
   call printf            ; print label to screen
   add esp, 4             ; adjust pointer

   displayLoop:
      mov eax, [arr1 + 4 * ebx]     ; move arr1 + counter into eax
      call printDisks               ; call printDisks function

      push space          ; push global space variable to stack
      call printf         ; print global variable space
      add esp, 4          ; adjust pointer

      mov eax, [arr2 + 4 * ebx]     ; move arr2 + counter into eax
      call printDisks               ; call printDisks function

      push space          ; push global space variable to stack
      call printf         ; print global variable space
      add esp, 4          ; adjust pointer
      
      mov eax, [arr3 + 4 * ebx]     ; move arr3 + counter into eax
      call printDisks               ; call printDisks function

      call print_nl       ; print new line

      inc ebx             ; counter++
      cmp ebx, 8          ; check if counter = 8
      jle displayLoop     ; jump to top of loop if it doesn't equal

   popa                   ; restore all registers
   leave                  ; leave subroutine
   ret                    ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printDisks:
  enter 0,0               ; setup routine

  new_t0:
    cmp eax, 0            ; check if eax = 0
    jnz new_t1            ; jump if not 0
    push t0               ; push global t0
    jmp end               ; jump to end
  
  new_t1:
    cmp eax, 1            ; check if eax = 1
    jne new_t2            ; jump if not 1
    push t1               ; push global t1
    jmp end               ; jump to end
  
  new_t2:
    cmp eax, 2            ; check if eax = 2
    jne new_t3            ; jump if not 2
    push t2               ; push global t2
    jmp end               ; jump to end
 
  new_t3:
    cmp eax, 3            ; check if eax = 3
    jne new_t4            ; jump if not 3
    push t3               ; push global t3
    jmp end               ; jump to end
 
  new_t4:
    cmp eax, 4            ; check if eax = 4
    jne new_t5            ; jump if not 4
    push t4               ; push global t4
    jmp end               ; jump to end
 
  new_t5:
    cmp eax, 5            ; check if eax = 5
    jne new_t6            ; jump if not 5
    push t5               ; push global t5
    jmp end               ; jump to end
  
  new_t6:
    cmp eax, 6            ; check if eax = 6
    jne new_t7            ; jump if not 6
    push t6               ; push global t6
    jmp end               ; jump to end
  
  new_t7:
    cmp eax, 7            ; check if eax = 7
    jne new_t8            ; jump if not 7
    push t7               ; push global t7
    jmp end               ; jump to end
  
  new_t8:
    cmp eax, 8            ; check if eax = 8
    jne new_t9            ; jump if not 8
    push t8               ; push global t8
    jmp end               ; jump to end
  
  new_t9:
    push t9               ; push global t9, the base never changes

  end:
    call printf           ; print to screen
    add esp, 4            ; adjust pointer
    leave                 ; leave subroutine
    ret                   ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

initPegs:
   enter 0,0                            ; setup routine

   mov eax, dword[numOfDisks]           ; move user disk input (N) in eax
   mov ebx, 7                           ; move 7 in ebx (external counter)

   initLoop:
      mov dword [arr1 + 4 * ebx], eax   ; move numOfDisks into arr1
      dec eax                           ; numOfDisks-- (i.e. counting)
      cmp eax, 0                        ; check if counter is 0
      je end_initPegs                   ; if counter is 0, jump to end
      dec ebx                           ; external counter--
      cmp ebx, 0                        ; check if external counter is 0
      jge initLoop                      ; if external counter is 0, jump to end

 end_initPegs:
   leave                                ; leave subroutine
   ret                                  ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wrongArg:
    push err                  ; push eax to stack
    call printf               ; print error
    call print_nl             ; print new line
    add esp, 4                ; adjust pointer
    jmp Quit                  ; exit program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tooManyArgs:
    push err2                 ; push err2 to stack
    call printf               ; print error
    call print_nl             ; print new line
    add esp, 4                ; adjust pointer
    jmp Quit                  ; exit program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

argOutOfRange:
    push err1                 ; push err1 to stack
    call printf               ; print error                            
    call print_nl             ; print new line
    add esp, 4                ; adjust pointer
    jmp Quit                  ; exit program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noArgs:
    push err3                 ; push err3 to stack
    call printf               ; print error
    call print_nl             ; print new line
    add esp, 4                ; adjust pointer
    jmp Quit                  ; exit program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

waitForEnter:
    push waits                ; push waits - i.e. wait message onto stack
    call printf               ; print "waits"
    add esp, 4                ; adjust pointer
    call getchar              ; call getchar - i.e. wait for enter
    ret                       ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

completedMessage:
    call print_nl             ; print new line
    push done                 ; push message to stack
    call printf               ; print to screen
    call print_nl             ; print new line
    add esp, 4                ; adjust pointer
    ret
    ;jmp Quit                  ; exit program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

hantowSolver:
  mov eax, dword[numOfDisks]    ; n value - decrementing disk counter
  mov ebx, arr1                 ; put arr1 into EAX = Start
  mov ecx, arr2                 ; put arr2 into EBX = Destination
  mov edx, arr3                 ; put arr3 into ECX = Temporary

  internalLoop:
    baseCase:
      cmp eax, 1                ; cmp if numOfDisks is 1
      je moveDisk               ; jump to moveDisk if above
      je end_hantowSolver       ; jump to end of loop on ret of moveDisks

    sourceToTemp: 
      pusha                     ; save all registers 
      push eax                  ; save register eax - numOfDisks

      mov eax, ecx              ; eax becomes temp 
      mov ecx, edx              ; ecx becomes dest
      mov edx, eax              ; edx becomes source

      pop eax                   ; restore resister eax - numOfDisks
      dec eax                   ; numOfDisks--

      call internalLoop         ; recursive call to hantowSolver
      popa                      ; restore all registers

    pusha                       ; preserve all registers
    call moveDisk               ; move disk - i.e. push updated arrays
    popa                        ; restore all registers

    sourceToDest:
      pusha                     ; save all registers 
      push eax                  ; save register eax - numOfDisks

      mov eax, ebx              ; eax becomes temp - update from N
      mov ebx, edx              ; ebx becomes source
      mov edx, eax              ; edx becomes temp

      pop eax                   ; restore eax
      dec eax                   ; decrement eax

      call internalLoop         ; recursive call
      popa                      ; restore all registers
    
  end_hantowSolver:
    ret                         ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

moveDisk:
  enter 0,0                         ; setup routine
  push edx                          ; save register edx
  mov edx, 0                        ; set edx to 0

  removeDiskLoop:
    cmp dword [ebx+edx], 0          ; cmp arr1[n] to 0
    jne else_removeDiskLoop         ; jump if above !=
    add edx, 4                      ; adjust pointer
    call removeDiskLoop             ; jump to top of loop
   else_removeDiskLoop:              
    mov dword [ebx+edx], 0          ; restore 0 inplace of peg

  mov edx, 0                        ; set edx to 0

  addDiskLoop:
    cmp dword [ecx+edx], 0          ; cmp arr2[n] to 0         
    jne else_addDiskLoop            ; jump if above !=
    add edx, 4                      ; adjust pointer
    call addDiskLoop                ; jump to top of loop
   else_addDiskLoop:
    mov dword [ecx+edx-4], eax      ; place peg removed into this location

  pop edx               ; restore register edx

  call displayTowers    ; call displayTowers
  call waitForEnter     ; waits for user to press enter

  leave                 ; leave subroutine
  ret                   ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printChristmasTree:
  call print_nl
  push tStar
  push t0
  push t1
  push t2
  push t3
  push t4
  push t5
  push t6
  push t7
  push t8
  push t9
  push treeFmt
  call printf
  add esp, 44
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

asm_main:
   enter 0,0             ; setup routine
   pusha                 ; save all registers
   
   call getNumOfDisks    ; retrieve & check the number of disks inputted

   call print_nl
   push dword [numOfDisks]    ; push numOfDisks to stack
   push fmt                   ; pushed formatting
   call printf                ; printed numOfDisks with fmt to screen
   add esp, 8                 ; adjust pointer
   call print_nl              ; print new line

   call initPegs         ; initialze pegs
   call displayTowers    ; display towers on screen
   call waitForEnter    ; waits for user to press enter
   call hantowSolver     ; Hanoi Tower recursion called
   call completedMessage ; completion feedback for user

   call printChristmasTree    ; PRINT CHRISTMAS TREE!! :D :D :D

   popa                  ; restore all registers
   call Quit             ; exits program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Quit:                    ; exits program
   leave                 ; leave subroutine
   ret                   ; return
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  END  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;