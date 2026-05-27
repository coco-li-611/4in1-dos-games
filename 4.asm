; ============================================
; 4合1汇编游戏集合 (已修复所有 A2028 语法错误)
; 编译命令: masm 4in1_game.asm; link 4in1_game.obj;
; ============================================

STACK SEGMENT PARA STACK 'STACK'
    DW 256 DUP(?)
STACK ENDS

DATA SEGMENT PARA PUBLIC 'DATA'
    ; ========== 主菜单 ==========
    str_menu db 0Dh,0Ah,'===== 4-IN-1 GAME COLLECTION =====',0Dh,0Ah
             db '1 - REVERSE CARDS',0Dh,0Ah
             db '2 - SNAKE',0Dh,0Ah
             db '3 - TYPING SPEED TEST',0Dh,0Ah
             db '4 - MAZE GAME',0Dh,0Ah
             db '0 - EXIT',0Dh,0Ah,'$'
    str_over   db 0Dh,0Ah,'GAME OVER, PRESS ANY KEY TO RETURN MENU',0Dh,0Ah,'$'
    str_snake_info  db 'SNAKE: ARROW KEYS FOR DIRECTION',0Dh,0Ah,'$'
    str_typing_info db 'TYPING TEST: TYPE THE SHOWN CHARACTERS',0Dh,0Ah,'$'

    ; ========== 迷宫数据 ==========
    Maze DB 23h,23h,23h,23h,23h,23h,23h,23h,23h,23h
         DB 23h,53h,20h,20h,23h,20h,20h,20h,45h,23h
         DB 23h,20h,23h,20h,23h,20h,23h,23h,20h,23h
         DB 23h,20h,23h,20h,20h,20h,20h,23h,20h,23h
         DB 23h,20h,23h,23h,23h,23h,20h,23h,20h,23h
         DB 23h,20h,20h,20h,20h,23h,20h,20h,20h,23h
         DB 23h,23h,23h,23h,20h,23h,23h,23h,20h,23h
         DB 23h,20h,20h,23h,20h,20h,20h,23h,20h,23h
         DB 23h,20h,20h,23h,23h,23h,23h,23h,20h,23h
         DB 23h,23h,23h,23h,23h,23h,23h,23h,23h,23h
    MazeStartMsg db 0DH,0AH,'==== Maze Game ====',0DH,0AH
                 db 'W=Up S=Down A=Left D=Right',0DH,0AH
                 db 'Press any key to start...',0DH,0AH,'$'
    MazeWinMsg   db 0DH,0AH,'You Win! Game Over.',0DH,0AH,'$'
    MazeCRLF     db 0DH,0AH,'$'
    X db 1
    Y db 1
; ========== 游戏2：贪吃蛇变量 (使用SN_前缀彻底隔离) ==========
    SN_BOUNDARY_COLOR dw 4431h
    SN_NEXT_ROL dw 0A0h
    SN_SNAKE_HEAD dw 0
    SN_SNAKE_BODY dw 6
    SN_SNAKE_STERN dw 12
    SN_SNAKE dw 6000 dup(0)
    SN_SNAKE_COLOR dw 2201h
    SN_UP db 48h
    SN_DOWN db 50h
    SN_LEFT db 4Bh
    SN_RIGHT db 4Dh
    SN_SCREEN_COLOR dw 0700h
    SN_NEXT_ROW dw 160
    SN_DIRECTION dw 3
    SN_DIRECTION_FUN dw offset SN_isMoveUp, offset SN_isMoveDown, offset SN_isMoveLeft, offset SN_isMoveRight
    SN_FOOD_LOCATION dw 160*3 + 20*2
    SN_FOOD_COLOR dw 0E02h
    SN_NEW_NODE dw 18
    SN_GAME_OVER db 'Game Over!'
    SN_GAME_DIR db 'direction: '
    SN_SCORE_STR db 'Score='
    SN_SCORE_CHAR db '0123456789ABCDEF'
    SN_SCORE dw 0h
    SN_SCORE_POSITION dw 160*24+60*2
    SN_START_STR db 'Press SPACE to Start Game!'
    SN_PAUSE_FLAG db 0
    SN_OLD_INT9 DD ?  ; 用于安全保存系统的键盘中断
    SN_SAVE_SP DW 0   ; 【新增】：用于保存干净的堆栈指针，防止死亡时栈崩溃
    
; ========== 翻牌配对数据 (RC_前缀防冲突) ==========
    RC_CARD_VALS   DB 3, 1, 4, 2, 3, 1, 4, 2
    RC_CARD_STATE  DB 8 DUP(0)
    RC_FIRST_REG   DW 0FFh
    RC_SECOND_REG  DW 0FFh
    RC_MATCHED_CNT DW 0
    RC_POS_ROW     DB 10, 10, 10, 10, 12, 12, 12, 12
    RC_POS_COL     DB 10, 18, 26, 34, 10, 18, 26, 34
    RC_MSG_TITLE   DB 13, 10, '   MEMORY MATCH (2x4)   ', 13, 10, '$'
    RC_MSG_PROMPT  DB 13, 10, 'Select card (1-8): $'
    RC_MSG_WIN     DB 13, 10, 13, 10, '*** YOU WON! ALL PAIRS MATCHED! ***', 13, 10, 'Press any key to exit...$'
    RC_MSG_SAME    DB 'Same! Match success.                    $'
    RC_MSG_ERR     DB 'Input error! Try again.                 $'
    RC_MSG_DIFF    DB 'Different! Turn back...                 $'
    RC_SEED        DW ?
    RC_RAND_MULT   DW 251

    ; ========== 打字测速游戏数据 (TY_前缀防冲突) ==========
    TY_welcome  DB 13,10,'===== Typing Speed Test =====',13,10
                DB 'Type the characters as fast as you can!',13,10
                DB 'You have 10 seconds.',13,10
                DB 'Press any key to start...$'
    
    TY_game_over DB 13,10,13,10,'===== Time is up! Game Over =====$'
    TY_correct   DB 13,10,'Correct: $'
    TY_total     DB 13,10,'Total typed: $'
    TY_accuracy  DB 13,10,'Accuracy: $'
    TY_speed     DB 13,10,'Speed: $'
    TY_wps       DB ' chars/sec$'
    TY_percent   DB '%$'

    TY_char_pool DB 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    TY_pool_len  EQU 36

    TY_curr_char DB ?
    TY_cor_cnt   DW 0
    TY_tot_cnt   DW 0
    TY_start_tick DW 0
DATA ENDS

CODE SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    mov ax, DATA
    mov ds, ax
    mov ax, STACK
    mov ss, ax
    mov sp, 512
    mov ax, 03h
    int 10h

main_menu:
    mov ah,06h
    xor al,al
    mov bh,07h
    xor cx,cx
    mov dx,184Fh
    int 10h

    mov ah,09h
    lea dx, str_menu
    int 21h

    mov ah,00h
    int 16h

    cmp al,'1'
    jne L1
    jmp game_reverse_cards
L1: cmp al,'2'
    jne L2
    jmp game_snake
L2: cmp al,'3'
    jne L3
    jmp game_typing_test
L3: cmp al,'4'
    jne L4
    call game_maze
    jmp game_end
L4: cmp al,'0'
    jne L5
    jmp exit_prog
L5: jmp main_menu

; ============================================
; 游戏1：翻牌配对 (已修复所有 A2028 语法错误)
; ============================================
game_reverse_cards:
    ; [修复] 拆分 PUSH 指令，避免旧版 MASM 报错
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP

    CALL RC_INIT_RANDOM
    CALL RC_SHUFFLE_CARDS
    CALL RC_CLEAR_SCREEN
    CALL RC_DRAW_TITLE
    CALL RC_DRAW_GRID

RC_MAIN_LOOP:
    CALL RC_SHOW_PROMPT
    CALL RC_GET_INPUT
    CMP AL, 0FFh
    JE RC_MAIN_LOOP
    XOR AH, AH
    MOV BX, AX
    ; [修复] 使用标准 [变量] 语法
    MOV AL, BYTE PTR [RC_CARD_STATE + BX]
    CMP AL, 2
    JE RC_MAIN_LOOP
    CMP AL, 1
    JE RC_MAIN_LOOP
    MOV BYTE PTR [RC_CARD_STATE + BX], 1
    CALL RC_DRAW_GRID
    CMP WORD PTR [RC_FIRST_REG], 0FFh
    JE RC_SET_FIRST
    MOV WORD PTR [RC_SECOND_REG], BX
    MOV BX, WORD PTR [RC_FIRST_REG]
    MOV AL, BYTE PTR [RC_CARD_VALS + BX]
    MOV BX, WORD PTR [RC_SECOND_REG]
    CMP AL, BYTE PTR [RC_CARD_VALS + BX]
    JE RC_MATCH_FOUND
    
    ; 配对失败
    CALL RC_SHOW_DIFF_MSG
    CALL RC_DELAY
    MOV BX, WORD PTR [RC_FIRST_REG]
    MOV BYTE PTR [RC_CARD_STATE + BX], 0
    MOV BX, WORD PTR [RC_SECOND_REG]
    MOV BYTE PTR [RC_CARD_STATE + BX], 0
    CALL RC_DRAW_GRID
    CALL RC_CLEAR_MSG_LINE
    JMP RC_RESET_PICKS

RC_MATCH_FOUND:
    MOV BX, WORD PTR [RC_FIRST_REG]
    MOV BYTE PTR [RC_CARD_STATE + BX], 2
    MOV BX, WORD PTR [RC_SECOND_REG]
    MOV BYTE PTR [RC_CARD_STATE + BX], 2
    ADD WORD PTR [RC_MATCHED_CNT], 2
    CALL RC_DRAW_GRID
    CALL RC_SHOW_SAME_MSG
    CALL RC_DELAY
    CALL RC_CLEAR_MSG_LINE
    JMP RC_RESET_PICKS

RC_RESET_PICKS:
    MOV WORD PTR [RC_FIRST_REG], 0FFh
    MOV WORD PTR [RC_SECOND_REG], 0FFh
    CMP WORD PTR [RC_MATCHED_CNT], 8
    JAE RC_WIN_GAME
    JMP RC_MAIN_LOOP

RC_SET_FIRST:
    MOV WORD PTR [RC_FIRST_REG], BX
    JMP RC_MAIN_LOOP

RC_WIN_GAME:
    MOV AH, 02h
    MOV DH, 16
    MOV DL, 5
    XOR BH, BH
    INT 10h
    MOV AH, 09h
    LEA DX, RC_MSG_WIN
    INT 21h
    MOV AH, 0
    INT 16h

RC_EXIT_GAME:
    ; [修复] 拆分 POP 指令
    POP BP
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    JMP game_end

; ---------- 翻牌配对子程序 (RC_前缀，语法已修正) ----------
RC_CLEAR_SCREEN PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX
    MOV AH, 06h
    XOR AL, AL
    XOR CX, CX
    MOV DH, 24
    MOV DL, 79
    MOV BH, 07h
    INT 10h
    POP BX
    POP DX
    POP CX
    POP AX
    RET
RC_CLEAR_SCREEN ENDP

RC_DRAW_TITLE PROC
    PUSH AX
    PUSH DX
    PUSH BX
    MOV AH, 02h
    MOV DH, 2
    MOV DL, 12
    XOR BH, BH
    INT 10h
    MOV AH, 09h
    LEA DX, RC_MSG_TITLE
    INT 21h
    POP BX
    POP DX
    POP AX
    RET
RC_DRAW_TITLE ENDP

RC_DRAW_GRID PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    MOV CX, 8
    XOR SI, SI
RC_GRID_LOOP:
    MOV DH, BYTE PTR [RC_POS_ROW + SI]
    MOV DL, BYTE PTR [RC_POS_COL + SI]
    XOR BH, BH
    MOV AH, 02h
    INT 10h
    MOV AL, BYTE PTR [RC_CARD_STATE + SI]
    CMP AL, 0
    JE RC_DRAW_HIDDEN
    MOV AL, BYTE PTR [RC_CARD_VALS + SI]
    ADD AL, '0'
    MOV BL, 0Eh
    JMP RC_DRAW_CHAR
RC_DRAW_HIDDEN:
    MOV AL, '?'
    MOV BL, 07h
RC_DRAW_CHAR:
    PUSH CX
    MOV CX, 1
    MOV AH, 09h
    INT 10h
    POP CX
    INC SI
    LOOP RC_GRID_LOOP
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
RC_DRAW_GRID ENDP

RC_SHOW_PROMPT PROC
    PUSH AX
    PUSH DX
    PUSH BX
    MOV AH, 02h
    MOV DH, 15
    MOV DL, 10
    XOR BH, BH
    INT 10h
    MOV AH, 09h
    LEA DX, RC_MSG_PROMPT
    INT 21h
    POP BX
    POP DX
    POP AX
    RET
RC_SHOW_PROMPT ENDP

RC_GET_INPUT PROC
    PUSH BX
    PUSH DX
    MOV AH, 00h
    INT 16h
    CMP AL, '1'
    JB RC_GET_INVALID
    CMP AL, '8'
    JA RC_GET_INVALID
    SUB AL, '1'
    POP DX
    POP BX
    RET
RC_GET_INVALID:
    MOV AH, 02h
    MOV DH, 13
    MOV DL, 10
    XOR BH, BH
    INT 10h
    MOV AH, 09h
    LEA DX, RC_MSG_ERR
    INT 21h
    MOV AL, 0FFh
    POP DX
    POP BX
    RET
RC_GET_INPUT ENDP

RC_SHOW_DIFF_MSG PROC
    PUSH AX
    PUSH DX
    PUSH BX
    MOV AH, 02h
    MOV DH, 14
    MOV DL, 10
    XOR BH, BH
    INT 10h
    MOV AH, 09h
    LEA DX, RC_MSG_DIFF
    INT 21h
    POP BX
    POP DX
    POP AX
    RET
RC_SHOW_DIFF_MSG ENDP

RC_SHOW_SAME_MSG PROC
    PUSH AX
    PUSH DX
    PUSH BX
    MOV AH, 02h
    MOV DH, 14
    MOV DL, 10
    XOR BH, BH
    INT 10h
    MOV AH, 09h
    LEA DX, RC_MSG_SAME
    INT 21h
    POP BX
    POP DX
    POP AX
    RET
RC_SHOW_SAME_MSG ENDP

RC_CLEAR_MSG_LINE PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX
    MOV AH, 02h
    MOV DH, 14
    MOV DL, 10
    XOR BH, BH
    INT 10h
    MOV AH, 09h
    MOV AL, ' '
    MOV BL, 07h
    MOV CX, 35
    INT 10h
    POP BX
    POP DX
    POP CX
    POP AX
    RET
RC_CLEAR_MSG_LINE ENDP

RC_DELAY PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV AH, 00h
    INT 1Ah
    ADD DX, 27
    ADC CX, 0
    MOV BX, CX
    MOV SI, DX
RC_WAIT_LOOP:
    MOV AH, 00h
    INT 1Ah
    CMP CX, BX
    JB RC_WAIT_LOOP
    JA RC_WAIT_DONE
    CMP DX, SI
    JB RC_WAIT_LOOP
RC_WAIT_DONE:
    POP DX
    POP CX
    POP AX
    RET
RC_DELAY ENDP

RC_INIT_RANDOM PROC
    PUSH AX
    PUSH DX
    MOV AH, 00h
    INT 1Ah
    MOV WORD PTR [RC_SEED], DX
    POP DX
    POP AX
    RET
RC_INIT_RANDOM ENDP

RC_SHUFFLE_CARDS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    LEA BX, RC_CARD_VALS
    MOV CX, 7
RC_SHUF_LOOP:
    CALL RC_GET_RANDOM
    MOV SI, CX
    MOV DI, AX
    ; [修复] 使用 [BX + SI] 标准基址变址寻址
    MOV AL, BYTE PTR [BX + SI]
    MOV AH, BYTE PTR [BX + DI]
    MOV BYTE PTR [BX + SI], AH
    MOV BYTE PTR [BX + DI], AL
    LOOP RC_SHUF_LOOP
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
RC_SHUFFLE_CARDS ENDP

RC_GET_RANDOM PROC
    PUSH BX
    PUSH DX
    ; [修复] 明确使用方括号访问内存变量
    MOV AX, WORD PTR [RC_SEED]
    MUL WORD PTR [RC_RAND_MULT]
    ADD AX, 3
    ADC DX, 0
    MOV WORD PTR [RC_SEED], AX
    MOV DX, 0
    MOV BX, CX
    INC BX
    DIV BX
    MOV AX, DX
    POP DX
    POP BX
    RET
RC_GET_RANDOM ENDP

; ============================================
; 游戏2：贪吃蛇 (已完美适配集合环境)
; ============================================
game_snake:
    ; 压栈保护现场，防止破坏合集菜单环境
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH ES
    PUSH DS
    MOV WORD PTR DS:[SN_SAVE_SP], SP
    CALL SN_init_reg
    CALL SN_clear_screen
    CALL SN_show_start_screen
    CALL SN_clear_screen

    ; 每次重新进入游戏时，重置蛇和分数的初始状态
    MOV WORD PTR [SN_SNAKE_HEAD], 0
    MOV WORD PTR [SN_SNAKE_BODY], 6
    MOV WORD PTR [SN_SNAKE_STERN], 12
    MOV WORD PTR [SN_NEW_NODE], 18
    MOV WORD PTR [SN_DIRECTION], 3
    MOV BYTE PTR [SN_PAUSE_FLAG], 0
    MOV WORD PTR [SN_SCORE], 0

    CALL SN_init_screen
    CALL SN_init_food
    CALL SN_init_snake

    ; 使用标准DOS中断安全接管键盘
    CALL SN_sav_old_int9
    CALL SN_set_new_int9

SN_nextMove:
    CALL SN_delay    
    CMP BYTE PTR ds:[SN_PAUSE_FLAG], 1
    JE SN_nextMove

    CLI
    CALL SN_isMoveDirection
    STI
    JMP SN_nextMove

; -----------------------------------------
; 贪吃蛇全部子程序 (SN_前缀)
; -----------------------------------------
SN_init_food:
    MOV DI, [SN_FOOD_LOCATION]
    PUSH [SN_FOOD_COLOR]
    POP ES:[DI]
    RET

SN_isMoveDirection:
    MOV BX, [SN_DIRECTION]
    ADD BX, BX
    CALL WORD PTR DS:[SN_DIRECTION_FUN+BX]
    RET

SN_delay:
    PUSH AX
    PUSH DX
    MOV DX, 3h
    SUB AX, AX
SN_delaying:
    SUB AX, 1
    SBB DX, 0
    CMP AX, 0
    JNE SN_delaying
    CMP DX, 0
    JNE SN_delaying
    POP DX
    POP AX
    RET

SN_init_snake:
    MOV BX, OFFSET SN_SNAKE
    ADD BX, [SN_SNAKE_HEAD]
    MOV SI, 160*10+40*2
    MOV DX, [SN_SNAKE_COLOR]
    MOV WORD PTR DS:[BX+0], 0
    MOV DS:[BX+2], SI  
    MOV ES:[SI], DX
    MOV WORD PTR DS:[BX+4], 6
    SUB SI, 2
    ADD BX, 6
    MOV WORD PTR DS:[BX+0], 0
    MOV DS:[BX+2], SI
    MOV ES:[SI], DX
    MOV WORD PTR DS:[BX+4], 12
    SUB SI, 2
    ADD BX, 6
    MOV WORD PTR DS:[BX+0], 6
    MOV DS:[BX+2], SI
    MOV ES:[SI], DX
    MOV WORD PTR DS:[BX+4], 18
    RET

SN_init_screen:
    MOV DX, [SN_BOUNDARY_COLOR]
    CALL SN_show_up_down_line
    CALL SN_show_left_right_line
    CALL SN_show_score
    CALL SN_output_score
    CALL SN_show_direction
    RET

SN_show_direction:
    MOV SI, OFFSET SN_GAME_DIR
    MOV DI, 160*24+0*2
    MOV CX, 11
SN_showDirection_loop:
    MOV AL, DS:[SI]
    MOV ES:[DI], AL
    MOV BYTE PTR ES:[DI+1], 00000010b
    INC SI
    ADD DI, 2
    LOOP SN_showDirection_loop
    RET

SN_show_score:
    MOV SI, OFFSET SN_SCORE_STR
    MOV DI, 160*24+50*2
    MOV CX, 6
SN_showScore_loop:
    MOV AL, DS:[SI]
    MOV ES:[DI], AL
    MOV BYTE PTR ES:[DI+1], 00000010b
    INC SI
    ADD DI, 2
    LOOP SN_showScore_loop
    RET

SN_show_up_down_line:
    MOV BX, 0
    MOV CX, 80
SN_showUpDownLine_loop:
    MOV ES:[BX], DX
    MOV ES:[BX+160*23], DX
    ADD BX, 2
    LOOP SN_showUpDownLine_loop
    RET

SN_output_score:
    MOV SI, OFFSET SN_SCORE
    MOV AX, DS:[SI]
    MOV SI, [SN_SCORE_POSITION]	
    MOV DX, AX
    MOV AL, AH
    MOV AH, 0
    MOV CX, 4
    SHR AL, CL
    MOV BX, AX
    MOV AL, DS:SN_SCORE_CHAR[BX]
    MOV BYTE PTR ES:[SI], AL
    MOV BYTE PTR ES:[SI+1], 00001010b
    ADD SI, 2
    MOV AX, DX
    MOV AL, AH
    MOV AH, 0
    MOV CX, 4
    SHL AL, CL   
    SHR AL, CL
    MOV BX, AX
    MOV AL, DS:SN_SCORE_CHAR[BX]
    MOV BYTE PTR ES:[SI], AL
    MOV BYTE PTR ES:[SI+1], 00001010b
    ADD SI, 2
    MOV AX, DX
    MOV AH, 0
    MOV CX, 4
    SHR AL, CL
    MOV BX, AX
    MOV AL, DS:SN_SCORE_CHAR[BX]	
    MOV BYTE PTR ES:[SI], AL
    MOV BYTE PTR ES:[SI+1], 00001010b
    ADD SI, 2
    MOV AX, DX
    MOV AH, 0
    MOV CX, 4
    SHL AL, CL	
    SHR AL, CL
    MOV BX, AX
    MOV AL, DS:SN_SCORE_CHAR[BX]
    MOV BYTE PTR ES:[SI], AL
    MOV BYTE PTR ES:[SI+1], 00001010b
    ADD SI, 2
    MOV BYTE PTR ES:[SI], 'H'
    MOV BYTE PTR ES:[SI+1], 00001010b
    RET

SN_show_left_right_line:
    MOV BX, 0
    MOV CX, 23
SN_showLeftRightLine_loop:
    MOV ES:[BX], DX
    MOV ES:[BX+79*2], DX
    ADD BX, [SN_NEXT_ROW]
    LOOP SN_showLeftRightLine_loop
    RET

SN_init_reg:
    MOV BX, 0b800h
    MOV ES, BX
    MOV BX, DATA
    MOV DS, BX
    RET

SN_clear_screen:
    MOV BX, 0
    MOV DX, [SN_SCREEN_COLOR]
    MOV CX, 2000
SN_clearScreen_loop:
    MOV ES:[BX], DX
    ADD BX, 2
    LOOP SN_clearScreen_loop
    RET

SN_new_int9:
    PUSH AX
    PUSH DS
    MOV AX, DATA
    MOV DS, AX
    CALL SN_clear_buff
    IN AL, 60h
    PUSHF
    CALL DWORD PTR DS:[SN_OLD_INT9]

    CMP AL, 19h
    JNE SN_check_up
    XOR BYTE PTR DS:[SN_PAUSE_FLAG], 1
    JMP SN_int9Ret
SN_check_up:
    CMP AL, DS:[SN_UP]
    JE SN_isUp
    CMP AL, DS:[SN_LEFT]
    JE SN_isLeft
    CMP AL, DS:[SN_RIGHT]
    JE SN_isRight
    CMP AL, DS:[SN_DOWN]
    JE SN_isDown
    CMP AL, 3bh
    JNE SN_int9Ret
    CALL SN_change_screen_color
SN_int9Ret:
    POP DS
    POP AX
    IRET

SN_isUp:
    MOV DI, 160*24 + 12*2
    MOV BYTE PTR ES:[DI], 'U'
    MOV BYTE PTR ES:[DI+1], 00001010b
    CMP WORD PTR DS:[SN_DIRECTION], 1
    JE SN_int9Ret
    MOV WORD PTR DS:[SN_DIRECTION], 0  ;
    JMP SN_int9Ret

SN_isDown:
    MOV DI, 160*24 + 12*2
    MOV BYTE PTR ES:[DI], 'D'
    MOV BYTE PTR ES:[DI+1], 00001010b
    CMP WORD PTR DS:[SN_DIRECTION], 0
    JE SN_int9Ret
    MOV WORD PTR DS:[SN_DIRECTION], 1  ;
    JMP SN_int9Ret

SN_isLeft:
    MOV DI, 160*24 + 12*2
    MOV BYTE PTR ES:[DI], 'L'
    MOV BYTE PTR ES:[DI+1], 00001010b
    CMP WORD PTR DS:[SN_DIRECTION], 3
    JE SN_int9Ret
    MOV WORD PTR DS:[SN_DIRECTION], 2  ;
    JMP SN_int9Ret

SN_isRight:
    MOV DI, 160*24 + 12*2
    MOV BYTE PTR ES:[DI], 'R'  
    MOV BYTE PTR ES:[DI+1], 00001010b
    CMP WORD PTR DS:[SN_DIRECTION], 2
    JE SN_int9Ret
    MOV WORD PTR DS:[SN_DIRECTION], 3  ;
    JMP SN_int9Ret

SN_isMoveUp:
    MOV BX, OFFSET SN_SNAKE
    ADD BX, [SN_SNAKE_HEAD]
    MOV SI, DS:[BX+2]
    SUB SI, [SN_NEXT_ROW]
    CMP BYTE PTR ES:[SI], 0
    JNE SN_noMoveUp			
    CALL SN_draw_new_snake
    MOV WORD PTR [SN_DIRECTION], 0
    RET
SN_noMoveUp:
    CALL SN_isFood
    RET

SN_isMoveDown:
    MOV BX, OFFSET SN_SNAKE
    ADD BX, [SN_SNAKE_HEAD]
    MOV SI, DS:[BX+2]
    ADD SI, [SN_NEXT_ROW]
    CMP BYTE PTR ES:[SI], 0
    JNE SN_noMoveDown
    CALL SN_draw_new_snake
    MOV WORD PTR [SN_DIRECTION], 1
    RET
SN_noMoveDown:
    CALL SN_isFood
    RET

SN_isMoveLeft:
    MOV BX, OFFSET SN_SNAKE
    ADD BX, [SN_SNAKE_HEAD]
    MOV SI, DS:[BX+2]
    SUB SI, 2
    CMP BYTE PTR ES:[SI], 0
    JNE SN_noMoveLeft
    CALL SN_draw_new_snake
    MOV WORD PTR [SN_DIRECTION], 2
    RET
SN_noMoveLeft:
    CALL SN_isFood
    RET

SN_isMoveRight:
    MOV BX, OFFSET SN_SNAKE
    ADD BX, [SN_SNAKE_HEAD]
    MOV SI, DS:[BX+2]
    ADD SI, 2
    CMP BYTE PTR ES:[SI], 0
    JNE SN_noMoveRight
    CALL SN_draw_new_snake
    MOV WORD PTR [SN_DIRECTION], 3
    RET
SN_noMoveRight:
    CALL SN_isFood
    RET

SN_isFood:
    CMP BYTE PTR ES:[SI], 02h
    JNE SN_noFood
    CALL SN_eat_food
    CALL SN_set_new_food
    RET

SN_noFood:
    STI                              ;     CALL SN_clear_screen
    CALL SN_recover_int9Ret          ; 把键盘控制权还给系统
    CALL SN_end_game                 ; 屏幕显示绿色的 Game Over!
    
    ; 【新增】等待玩家按任意键确认死亡
    MOV AH, 0
    INT 16h
    
    CALL SN_clear_screen             ; 再次清屏，准备回主菜单

    ; 【核心修复】强制把堆栈恢复到游戏刚开始时最干净的状态！
    MOV SP, WORD PTR DS:[SN_SAVE_SP]

    ; 安全弹出保护的寄存器
    POP DS
    POP ES
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    ; 此时环境彻底干净，跳转回合集公共的 game_end 逻辑
    JMP game_end

SN_end_game:
    MOV SI, OFFSET SN_GAME_OVER
    MOV DI, 160*12+35*2
    MOV CX, 10
SN_endGame_loop:
    MOV AL, DS:[SI]
    MOV BYTE PTR ES:[DI], AL
    MOV BYTE PTR ES:[DI+1], 00001100b
    INC SI
    ADD DI, 2
    LOOP SN_endGame_loop
    RET

SN_set_new_food:
    MOV AL, 0
    OUT 70h, AL
    IN AL, 71h
    MOV DL, AL 
    AND DL, 00001111b
    PUSH CX
    MOV CL, 4
    MOV CH, 0
    SHR AL, CL
    POP CX		
    MOV BL, 10
    MUL BL
    ADD AL, DL
    MUL AL
    SHR AL, 1
    SHL AL, 1
    MOV BX, AX
SN_find_empty:
    CMP BYTE PTR ES:[BX], 0
    JE SN_set_food_color
    ADD BX, 2
    CMP BX, 160*23
    JB SN_find_empty
    MOV BX, 160
    JMP SN_find_empty
SN_set_food_color:
    PUSH [SN_FOOD_COLOR]		
    POP ES:[BX]	
    RET

SN_eat_food:
    PUSH [SN_NEW_NODE]
    POP DS:[BX+0]
    MOV BX, OFFSET SN_SNAKE
    ADD BX, [SN_NEW_NODE]
    MOV WORD PTR DS:[BX+0], 0
    MOV DS:[BX+2], SI
    PUSH [SN_SNAKE_COLOR]
    POP ES:[SI]
    PUSH [SN_SNAKE_HEAD]
    POP DS:[BX+4]
    PUSH [SN_NEW_NODE]
    POP [SN_SNAKE_HEAD]
    ADD WORD PTR [SN_NEW_NODE], 6
    INC WORD PTR [SN_SCORE]
    CALL SN_output_score
    RET

SN_draw_new_snake:
    PUSH [SN_SNAKE_STERN]
    POP DS:[BX+0]
    MOV BX, OFFSET SN_SNAKE
    ADD BX, [SN_SNAKE_STERN]
    PUSH DS:[BX+0]
    MOV WORD PTR DS:[BX+0], 0
    MOV DI, DS:[BX+2]
    PUSH [SN_SCREEN_COLOR]
    POP ES:[DI]
    MOV DS:[BX+2], SI
    PUSH [SN_SNAKE_COLOR]
    POP ES:[SI]
    PUSH [SN_SNAKE_HEAD]
    POP DS:[BX+4]
    PUSH [SN_SNAKE_STERN]
    POP [SN_SNAKE_HEAD]
    POP AX
    MOV [SN_SNAKE_STERN], AX
    RET

SN_clear_buff:
    MOV AH, 1
    INT 16h
    JZ SN_clearBuffRet
    MOV AH, 0
    INT 16h
    JMP SN_clear_buff
SN_clearBuffRet:
    RET

SN_show_start_screen:
    MOV SI, OFFSET SN_START_STR
    MOV DI, 160*12 + 27*2
    MOV CX, 26
SN_showStartStr_loop:
    MOV AL, DS:[SI]
    MOV ES:[DI], AL
    MOV BYTE PTR ES:[DI+1], 00001110b
    INC SI
    ADD DI, 2
    LOOP SN_showStartStr_loop
SN_waitSpace:
    MOV AH, 0
    INT 16h
    CMP AL, ' '
    JNE SN_waitSpace
    RET

SN_change_screen_color:
    PUSH BX
    PUSH CX
    PUSH ES
    MOV BX, 0b800h
    MOV ES, BX
    MOV BX, 1
    MOV CX, 2000
SN_changeScreen_loop:
    INC BYTE PTR ES:[BX]
    ADD BX, 2
    LOOP SN_changeScreen_loop
    POP ES
    POP CX
    POP BX
    RET

SN_set_new_int9:
    PUSH AX
    PUSH DX
    PUSH DS
    MOV AX, CS
    MOV DS, AX
    LEA DX, SN_new_int9
    MOV AX, 2509h   ; 标准DOS接管中断
    INT 21h
    POP DS
    POP DX
    POP AX
    RET

SN_sav_old_int9:
    PUSH AX
    PUSH BX
    PUSH ES
    MOV AX, 3509h   ; 标准DOS保存旧中断
    INT 21h
    MOV WORD PTR [SN_OLD_INT9], BX
    MOV WORD PTR [SN_OLD_INT9+2], ES
    POP ES
    POP BX
    POP AX
    RET

SN_recover_int9Ret:
    PUSH AX
    PUSH DX
    PUSH DS
    MOV DX, WORD PTR DS:[SN_OLD_INT9]
    MOV DS, WORD PTR DS:[SN_OLD_INT9+2]
    MOV AX, 2509h   ; 标准DOS恢复旧中断
    INT 21h
    POP DS
    POP DX
    POP AX
    RET

; ============================================
; 游戏3：打字测速游戏（已整合）
; ============================================
game_typing_test:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; 清屏
    MOV AX, 03h
    INT 10h

    ; 显示欢迎界面
    LEA DX, TY_welcome
    MOV AH, 09H
    INT 21H

    ; 按任意键开始（无回显）
    MOV AH, 00H
    INT 16H

    ; 换行
    MOV DL, 13
    MOV AH, 02H
    INT 21H
    MOV DL, 10
    INT 21H

    ; 初始化计数器
    MOV WORD PTR [TY_cor_cnt], 0
    MOV WORD PTR [TY_tot_cnt], 0

    ; 记录开始时间
    MOV AH, 00H
    INT 1AH
    MOV WORD PTR [TY_start_tick], DX

    ; 先显示第一个字符
    CALL TY_GET_RANDOM_CHAR
    MOV BYTE PTR [TY_curr_char], AL
    MOV DL, AL
    MOV AH, 02H
    INT 21H

TY_GAME_LOOP:
    ; 检查是否超时（180 = 10秒 * 18.2 ticks/秒）
    MOV AH, 00H
    INT 1AH
    SUB DX, WORD PTR [TY_start_tick]
    CMP DX, 180
    JGE TY_END_GAME

    ; 检测是否有按键按下
    MOV AH, 01H
    INT 16H
    JZ TY_GAME_LOOP

    ; 读取按键
    MOV AH, 00H
    INT 16H
    MOV BL, AL

    ; 统计总数
    INC WORD PTR [TY_tot_cnt]

    ; 检查是否正确
    CMP BL, BYTE PTR [TY_curr_char]
    JNE TY_CLEAR_CHAR
    INC WORD PTR [TY_cor_cnt]

TY_CLEAR_CHAR:
    ; 清除当前字符
    MOV DL, 08H
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 08H
    INT 21H

    ; 生成并显示下一个字符
    CALL TY_GET_RANDOM_CHAR
    MOV BYTE PTR [TY_curr_char], AL
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    JMP TY_GAME_LOOP

TY_END_GAME:
    ; 显示结算界面
    LEA DX, TY_game_over
    MOV AH, 09H
    INT 21H

    ; 打印正确数
    LEA DX, TY_correct
    INT 21H
    MOV AX, WORD PTR [TY_cor_cnt]
    CALL TY_PRINT_NUM

    ; 打印总数
    LEA DX, TY_total
    MOV AH, 09H
    INT 21H
    MOV AX, WORD PTR [TY_tot_cnt]
    CALL TY_PRINT_NUM

    ; 打印正确率（带除0保护）
    LEA DX, TY_accuracy
    MOV AH, 09H
    INT 21H
    MOV AX, WORD PTR [TY_tot_cnt]
    CMP AX, 0
    JE TY_NO_ACC

    MOV AX, WORD PTR [TY_cor_cnt]
    MOV BX, 100
    MUL BX
    DIV WORD PTR [TY_tot_cnt]
    CALL TY_PRINT_NUM
    LEA DX, TY_percent
    MOV AH, 09H
    INT 21H
    JMP TY_SHOW_SPEED

TY_NO_ACC:
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    LEA DX, TY_percent
    MOV AH, 09H
    INT 21H

TY_SHOW_SPEED:
    ; 打印速度
    LEA DX, TY_speed
    MOV AH, 09H
    INT 21H
    MOV AX, WORD PTR [TY_tot_cnt]
    CALL TY_PRINT_NUM
    LEA DX, TY_wps
    MOV AH, 09H
    INT 21H

    ; 等待按键返回
    MOV AH, 00H
    INT 16H

    POP DX
    POP CX
    POP BX
    POP AX
    JMP game_end

; ---------- 打字测速子程序 ----------
TY_GET_RANDOM_CHAR PROC
    PUSH BX
    PUSH DX
    MOV AH, 00H
    INT 1AH
    MOV AX, DX
    XOR DX, DX
    MOV BX, TY_pool_len
    DIV BX
    MOV BX, DX
    MOV AL, BYTE PTR [TY_char_pool + BX]
    POP DX
    POP BX
    RET
TY_GET_RANDOM_CHAR ENDP

TY_PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, 10
    XOR CX, CX
TY_PN_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE TY_PN_LOOP
TY_PN_OUT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP TY_PN_OUT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
TY_PRINT_NUM ENDP

; ============================================
; 游戏4：迷宫 (已修复 CALL/RET 栈平衡)
; ============================================
game_maze PROC
    mov ax,03h
    int 10h
    mov ah,09h
    lea dx,MazeStartMsg
    int 21h
    mov ah,00h
    int 16h
    mov byte ptr [X], 1
    mov byte ptr [Y], 1
maze_loop:
    call cls
    call draw_maze
    call get_key
    cmp al,'W'
    je  maze_up
    cmp al,'w'
    je  maze_up
    cmp al,'S'
    je  maze_down
    cmp al,'s'
    je  maze_down
    cmp al,'A'
    je  maze_left
    cmp al,'a'
    je  maze_left
    cmp al,'D'
    je  maze_right
    cmp al,'d'
    je  maze_right
    jmp maze_loop
maze_up:
    mov al, [X]
    dec al
    call check_wall
    jz  maze_loop
    dec byte ptr [X]
    call check_end_maze
    jmp maze_loop
maze_down:
    mov al, [X]
    inc al
    call check_wall
    jz  maze_loop
    inc byte ptr [X]
    call check_end_maze
    jmp maze_loop
maze_left:
    mov al, [Y]
    dec al
    call check_wall_y
    jz  maze_loop
    dec byte ptr [Y]
    call check_end_maze
    jmp maze_loop
maze_right:
    mov al, [Y]
    inc al
    call check_wall_y
    jz  maze_loop
    inc byte ptr [Y]
    call check_end_maze
    jmp maze_loop
check_end_maze:
    push ax
    push bx
    mov al, [X]
    mov bl, 10
    mul bl
    mov cl, [Y]
    xor ch, ch
    add ax, cx
    lea bx, Maze
    add bx, ax
    cmp byte ptr [bx], 'E'
    jne not_end
    mov ah,09h
    lea dx, MazeWinMsg
    int 21h
    mov ah,00h
    int 16h
    jmp near ptr game_end
not_end:
    pop bx
    pop ax
    ret
check_wall PROC
    push bx
    push cx
    push ax
    mov bl,10
    mul bl
    mov cl, [Y]
    xor ch, ch
    add ax, cx
    lea bx, Maze
    add bx, ax
    cmp byte ptr [bx], '#'
    pop ax
    pop cx
    pop bx
    ret
check_wall ENDP
check_wall_y PROC
    push bx
    push cx
    push dx
    mov dl, al
    mov al, [X]
    mov bl, 10
    mul bl
    mov bh, 0
    mov bl, dl
    add ax, bx
    lea bx, Maze
    add bx, ax
    cmp byte ptr [bx], '#'
    pop dx
    pop cx
    pop bx
    ret
check_wall_y ENDP
draw_maze PROC
    push ax
    push bx
    push cx
    push dx
    xor bx, bx
    mov cx, 10
draw_row:
    push cx
    mov cx, 10
draw_col:
    mov al, Maze[bx]
    call is_player_maze
    mov dl, al
    mov ah, 02h
    int 21h
    inc bx
    loop draw_col
    lea dx, MazeCRLF
    mov ah, 09h
    int 21h
    pop cx
    loop draw_row
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_maze ENDP
is_player_maze PROC
    push bx
    push ax
    mov ax, bx
    mov bl, 10
    div bl
    cmp al, [X]
    jne not_player_maze
    cmp ah, [Y]
    jne not_player_maze
    pop ax
    mov al, '@'
    pop bx
    ret
not_player_maze:
    pop ax
    pop bx
    ret
is_player_maze ENDP
get_key PROC
    mov ah,00h
    int 16h
    ret
get_key ENDP
cls PROC
    mov ax,0600h
    mov bh,07h
    xor cx,cx
    mov dx,184fh
    int 10h
    ret
cls ENDP
    ret
game_maze ENDP

; ============================================
; 公共退出逻辑
; ============================================
game_end:
    mov ah,09h
    lea dx,str_over
    int 21h
    mov ah,00h
    int 16h
    jmp near ptr main_menu

exit_prog:
    mov ah,4ch
    int 21h

CODE ENDS
END START