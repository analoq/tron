DIR_LEFT	equ 0
DIR_RIGHT	equ 1
DIR_UP		equ 2
DIR_DOWN	equ 3

PLAYER1_SX	equ 304
PLAYER1_SY	equ 150
PLAYER1_SD	equ DIR_LEFT

PLAYER2_SX	equ 16
PLAYER2_SY	equ 50
PLAYER2_SD	equ DIR_RIGHT

PLAYER_X	equ 0
PLAYER_Y	equ 2
PLAYER_DR	equ 4
PLAYER_CL	equ 5
PLAYER_BG	equ 6
PLAYER_SC	equ 7
PLAYER_KL	equ 9
PLAYER_KR	equ 11
PLAYER_KU	equ 13
PLAYER_KD	equ 15

        org 0x100

section .text

start:	call video_set
        push palette
        call palette_set
	call keyboard_install
	call music_init

.begin:	call video_clear
	
	push 80
	push 32
        push gfx_title
	call gfx_draw

	push 13
	push 12
	push 12
	push score$
	call text_write
	push 13
	push 14
	push 14
	push word [player2+PLAYER_SC]
	call number_write

	push 14
	push 24
	push 12
	push score$
	call text_write
	push 14
	push 26
	push 14
	push word [player1+PLAYER_SC]
	call number_write

	push 1
	push 9
	push 20
	push instruct$
	call text_write

	call keyboard_wait
        call video_clear
        ; reset player positions
	mov word [player1+PLAYER_X], PLAYER1_SX
	mov word [player1+PLAYER_Y], PLAYER1_SY
	mov byte [player1+PLAYER_DR], PLAYER1_SD
	mov byte [player1+PLAYER_BG], 0
	mov word [player2+PLAYER_X], PLAYER2_SX
	mov word [player2+PLAYER_Y], PLAYER2_SY
	mov byte [player2+PLAYER_DR], PLAYER2_SD
	mov byte [player2+PLAYER_BG], 0
.loop:  ; draw
	push player1
	call player_draw
	push player2
	call player_draw
        call video_retrace

	cmp byte [player1+PLAYER_BG], 0
	jne .player1_lose
	cmp byte [player2+PLAYER_BG], 0
	jne .player2_lose

	push player1
	call player_move
	push player2
	call player_move

	; handle input
	cmp byte [keys+KEY_ESC], 1
	je .done
	push player1
	call player_input
	push player2
	call player_input
	jmp .loop

.player1_lose:
	push player1
	call player_die
	inc byte [player2+PLAYER_SC]
	cmp byte [player2+PLAYER_BG], 0
	jne .player2_lose
	jmp .begin

.player2_lose:
	push player2
	call player_die
	inc byte [player1+PLAYER_SC]
	jmp .begin

.done:  call music_init
        call keyboard_uninstall
        call text_set
        call ansi_output
        call exit

player_input:
	push bp
	mov bp, sp
	push si
	push di
	mov si, [bp+4]

	mov di, [si+PLAYER_KL]
	cmp byte [keys+di], 1
	je .left
	mov di, [si+PLAYER_KR]
	cmp byte [keys+di], 1
	je .right
	mov di, [si+PLAYER_KU]
	cmp byte [keys+di], 1
	je .up
	mov di, [si+PLAYER_KD]
	cmp byte [keys+di], 1
	je .down
	jmp .done

.left:	cmp byte [si+PLAYER_DR], DIR_RIGHT
	je .done
	mov byte [si+PLAYER_DR], DIR_LEFT
	jmp .done
.right:	cmp byte [si+PLAYER_DR], DIR_LEFT
        je .done
        mov byte [si+PLAYER_DR], DIR_RIGHT
        jmp .done
.up:	cmp byte [si+PLAYER_DR], DIR_DOWN
	je .done
	mov byte [si+PLAYER_DR], DIR_UP
	jmp .done
.down:	cmp byte [si+PLAYER_DR], DIR_UP
	je .done
	mov byte [si+PLAYER_DR], DIR_DOWN
	jmp .done

.done:	pop di
	pop si
	mov sp, bp
	pop bp
	ret 2

player_move:
	push bp
	mov bp, sp
	push si
	mov si, [bp+4]
	cmp byte [si+PLAYER_DR], DIR_RIGHT
	je .right
	cmp byte [si+PLAYER_DR], DIR_LEFT
	je .left
	cmp byte [si+PLAYER_DR], DIR_UP
	je .up
	cmp byte [si+PLAYER_DR], DIR_DOWN
	je .down
	jmp .done

.right:	cmp word [si+PLAYER_X], 319
        je .rwrap
        inc word [si+PLAYER_X]
	jmp .done
.rwrap: mov word [si+PLAYER_X], 0
        jmp .done

.left:	cmp word [si+PLAYER_X], 0
        je .lwrap
        dec word [si+PLAYER_X]
	jmp .done
.lwrap: mov word [si+PLAYER_X], 319
        jmp .done

.up:	cmp word [si+PLAYER_Y], 0
        je .uwrap
        dec word [si+PLAYER_Y]
	jmp .done
.uwrap: mov word [si+PLAYER_Y], 199
        jmp .done

.down:	cmp word [si+PLAYER_Y], 199
        je .dwrap
        inc word [si+PLAYER_Y]
	jmp .done
.dwrap: mov word [si+PLAYER_Y], 0
        jmp .done

.done:	pop si
	mov sp, bp
	pop bp
	ret 2

player_draw:
	push bp
	mov bp, sp
	push si
	push ax
	mov si, [bp+4]
	push word [si+PLAYER_X]
	push word [si+PLAYER_Y]
	call pixel_get
	mov byte [si+PLAYER_BG], al
	push word [si+PLAYER_CL]
	push word [si+PLAYER_X]
	push word [si+PLAYER_Y]
	call pixel_put
	pop ax
	pop si
	mov sp, bp
	pop bp
	ret 2

player_die:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push si

        push fx_death
	call sound_fx
	mov si, [bp+4]
	mov cx, 0
.loop:	mov ax, [si+PLAYER_X]
	mov bx, [si+PLAYER_Y]
	add ax, cx
	add bx, cx
	push word 15
	push word ax
	push word bx
	call pixel_put
	mov ax, [si+PLAYER_X]
	mov bx, [si+PLAYER_Y]
	sub ax, cx
	sub bx, cx
	push word 15
	push word ax
	push word bx
	call pixel_put
	mov ax, [si+PLAYER_X]
	mov bx, [si+PLAYER_Y]
	sub ax, cx
	add bx, cx
	push word 15
	push word ax
	push word bx
	call pixel_put
	mov ax, [si+PLAYER_X]
	mov bx, [si+PLAYER_Y]
	add ax, cx
	sub bx, cx
	push word 15
	push word ax
	push word bx
	call pixel_put
	call video_retrace
	call video_retrace
	call video_retrace
	call video_retrace
	inc cx
	cmp cx, 16
	jg .done
	jmp .loop

.done:	pop si
	pop cx
	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret 2

ansi_output:
        push ax
        push cx
        push es
        push si
        push di

        mov ax, 0xB800
        mov es, ax
        mov si, ansi
        mov di, 0
        mov cx, 80
        rep movsw

        pop di
        pop si
        pop es
        pop cx
        pop ax
        ret

%include "LIBRARY.ASM"
%include "SOUND.ASM"
%include "GRAPHICS.ASM"
%include "ANSI.ASM"

section .data

player1:	dw PLAYER1_SX
		dw PLAYER1_SY
		db DIR_LEFT
		db 14
		db 0
		dw 0
		dw KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN

player2:	dw PLAYER2_SX
		dw PLAYER2_SY
		db DIR_RIGHT
		db 13
		db 0
		dw 0
		dw KEY_A, KEY_D, KEY_W, KEY_S

score$:		db 'Score', 0
instruct$:	db 'Press SPACE to continue', 0

section .bss
