DOS		equ	0x21
VIDEO		equ	0x10
VIDMEM		equ	0xA000
SCREEN_WIDTH    equ     320

KEY_ESC		equ	1
KEY_UP		equ	72
KEY_DOWN	equ	80
KEY_LEFT	equ     75
KEY_RIGHT	equ	77
KEY_W		equ     17
KEY_A		equ     30
KEY_S		equ     31
KEY_D		equ     32
KEY_SPACE	equ     57

NO_EVENT        EQU     0x0000
NOTE_OFF        EQU     0xFFFF
CHAN_LEN        EQU     2

section .text

sound_fx:
        push bp
        mov bp, sp
	push ax
	push dx
        push si
        
	mov al, 0xB8            ; turn voice off
	mov dx, 0x0388
	out dx, al
	mov al, 0x00
	mov dx, 0x0389
	out dx, al

        mov si, [bp+4]

	mov al, 0x20+0x12	;Set the modulator's multiple
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0x40+0x12	;Set the modulator's level to about 40 dB
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0x60+0x12	;Modulator attack, decay
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0x80+0x12	;Modulator sustain, release
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0xE0+0x12	;Modulator wave
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0x23+0x12	;Set the carrier's multiple
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0x43+0x12	;Set the carrier to maximum volume (about 47 dB)
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0x63+0x12	;Carrier attack,   decay
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0x83+0x12	;Carrier sustain, release
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0xE3+0x12	;Carrier wave
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al

	mov al, 0xC8	        ;Feedback
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0xA8	;Set voice frequency's LSB
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al
	mov al, 0xB8	;Turn the voice on; set the octave and freq MSB
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al

        pop si
	pop dx
	pop ax
	mov sp, bp
	pop bp
	ret 2

music_init:
	push ax
	push bx
	push dx
	push si

        mov al, 0x01    	;Allow waveform control
        mov dx, 0x0388
        out dx, al
        mov al, 0x20
        mov dx, 0x0389
        out dx, al
        mov al, 0x08    	;CSM Mode / Keyboard Split.
        mov dx, 0x0388
        out dx, al
        mov al, 0x00
        mov dx, 0x0389
        out dx, al
        mov al, 0xBD    	;Amplitude Modulation Depth / Vibrato Depth / Rhythm
        mov dx, 0x0388
        out dx, al
        mov al, 0x00
        mov dx, 0x0389
        out dx, al

	mov bx, 0
	mov si, instruments
	cld
.loop:	mov al, [chan_offsets+bx]	;Set the modulator's multiple
        add al, 0x20
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
        mov dx, 0x0389
	out dx, al
	mov al, [chan_offsets+bx]	;Set the modulator's level
        add al, 0x40
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
        mov dx, 0x0389
	out dx, al
	mov al, [chan_offsets+bx]       ;Modulator attack, decay
        add al, 0x60
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
        mov dx, 0x0389
	out dx, al
	mov al, [chan_offsets+bx]	;Modulator sustain, release
        add al, 0x80
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
        mov dx, 0x0389
	out dx, al
        mov al, [chan_offsets+bx] ;Waveform modulator
        add al, 0xE0
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
        mov dx, 0x0389
	out dx, al
	mov al, [chan_offsets+bx]	;Set the carrier's multiple
        add al, 0x23
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
        mov dx, 0x0389
	out dx, al
	mov al, [chan_offsets+bx]	;Carrier volume
        add al, 0x43
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
        mov dx, 0x0389
	out dx, al
	mov al, [chan_offsets+bx]	;Carrier attack,   decay
        add al, 0x63
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
        mov dx, 0x0389
	out dx, al
	mov al, [chan_offsets+bx]	;Carrier sustain, release
        add al, 0x83
        add al, bl
	mov dx, 0x0388
	out dx, al
        lodsb
	mov dx, 0x0389
	out dx, al
        mov al, [chan_offsets+bx]       ;Carrier waveform
        add al, 0xE3
        add al, bl
	mov dx, 0x0388
	out dx, al
        lodsb
	mov dx, 0x0389
	out dx, al
        mov al, 0xC0 ;Feedback
        add al, bl
	mov dx, 0x0388
	out dx, al
	lodsb
	mov dx, 0x0389
	out dx, al

        mov al, 0xB0                 ; turn voice off
        add al, bl
	mov dx, 0x0388
	out dx, al
	mov al, 0x00
	mov dx, 0x0389
	out dx, al

	inc bl
	cmp bl, SCORE_CHANS
	jne .loop
	pop si
        pop dx
	pop bx
	pop ax
	ret

music_play:
        push ax
        push bx
        push cx
        push dx

        cmp word [score_wait], 0                ; time for next event?
        jne .done

        mov word [score_wait], SCORE_TEMPO

        mov bx, word [score_pos]                ; current row
        mov ax, ROW_LEN
        mul bx
        mov bx, ax
        
        inc word [score_pos]                    ; next row
        cmp word [score_pos], SCORE_ROWS        ; finished?
        jne .voice
        mov word[score_pos], 0                  ; back to beginning

.voice: mov cl, 0
.loop:  cmp word [score+bx], NO_EVENT        ; no event?
        je .next
        mov al, 0xB0                 ; turn voice off
        add al, cl
	mov dx, 0x0388
	out dx, al
	mov al, 0x00
	mov dx, 0x0389
	out dx, al
	cmp word [score+bx], NOTE_OFF   ; rest?
	je .next
	mov al, 0xA0                 ;Set voice frequency's LSB
        add al, cl
	mov dx, 0x0388
	out dx, al
	mov al, byte [score+bx]
	mov dx, 0x0389
	out dx, al
	mov al, 0xB0                 ;Turn the voice on
        add al, cl
	mov dx, 0x0388
	out dx, al
	mov al, byte [score+bx+1]        ; set MSB
	mov dx, 0x0389
	out dx, al
.next:  inc cl
        add bx, CHAN_LEN
        cmp cl, SCORE_CHANS
	je .done
        jmp .loop

.done:	dec word [score_wait]
	pop dx
	pop cx
	pop bx
	pop ax
	ret

gfx_draw:
        push bp
        mov bp, sp
        push es

        mov si, [bp+4]          ; set destination
	mov di, [bp+6]
	mov ax, SCREEN_WIDTH
	mul di
	add ax, [bp+8]
	mov di, ax

        lodsw                   ; read width
        mov bx, ax
        lodsw                   ; read height
        mov dx, ax

        mov ax, VIDMEM
        mov es, ax
        cld
.L1:    mov cx, bx
        shr cx, 2
.L2:    mov al, [si]            ; first 2
        and al, 0x03
        mov [es:di], al
        inc di
        mov al, [si]            ; first 4
        and al, 0x0C
        shr al, 2
        mov [es:di], al
        inc di
        mov al, [si]            ; first 6
        and al, 0x30
        shr al, 4
        mov [es:di], al
        inc di
        mov al, [si]            ; first 8
        and al, 0xC0
        shr al, 6
        mov [es:di], al
        inc di
        inc si
        loop .L2
        add di, SCREEN_WIDTH
        sub di, bx
        dec dx
        jnz .L1

        pop es
        mov sp, bp
        pop bp
        ret 6

pixel_put:
	push bp
	mov bp, sp
	push ax
	push di
	push es
	mov ax, VIDMEM
	mov es, ax
	mov di, [bp+4]
	mov ax, SCREEN_WIDTH
	mul di
	add ax, [bp+6]
	mov di, ax
	mov al, [bp+8]
        mov byte [es:di], al
	pop es
	pop di
	pop ax
	mov sp, bp
	pop bp
	ret 6

pixel_get:
	push bp
	mov bp, sp
	push di
	push es
	mov ax, VIDMEM
	mov es, ax
	mov di, [bp+4]
	mov ax, SCREEN_WIDTH
	mul di
	add ax, [bp+6]
	mov di, ax
        mov al, byte [es:di]
	pop es
	pop di
	mov sp, bp
	pop bp
	ret 4

palette_set:
        push bp
        mov bp, sp
        push ax
        push dx

        mov si, [bp+4]
.loop:  mov dx, 0x03c8          ; index
        lodsb
        cmp al, 0
        je .done
        out dx, al
        mov dx, 0x03c9          ; red
        lodsb
        out dx, al
        mov dx, 0x03c9          ; green
        lodsb
        out dx, al
        mov dx, 0x03c9          ; blue
        lodsb
        out dx, al
        jmp .loop

.done:  pop dx
        pop ax
        mov sp, bp
        pop bp
        ret 2

keyboard_install:
	push ax
	push ds
	mov ax, 0
	mov ds, ax
	cli
	mov [0x0024], word keyboard_interrupt
	mov [0x0026], cs
	sti
	pop ds
	pop ax
	ret

keyboard_interrupt:
	pusha
	mov 	ax, 0
        in	al, 0x60         ; Get scan code

	test	al, 0x80	; key down?
	jnz	.up
	mov	di, ax
	mov	byte [keys+di], 1
	jmp	.done
.up:	and	al, 0x7F
	mov	di, ax
	mov	byte [keys+di], 0

.done:  mov	al, 0x61         ; Send End-of-Interrupt signal
        out	0x20, al
	popa
        iret                    ; End of handler

keyboard_uninstall:
	push ax
	push ds
	mov ax, 0
	mov ds, ax
	cli
	mov [0x0024], word 0xE987
	mov [0x0026], word 0xF000
	sti
	pop ds
	pop ax
	ret

keyboard_wait:
.loop:	call video_retrace
	cmp byte [keys+KEY_SPACE], 1
	jne .loop
	ret

video_set:
        push ax
        mov ah, 0
        mov al, 0x13
        int VIDEO
        pop ax
        ret

video_clear:
        push ax
        push cx
        push es
        push di
        mov ax, VIDMEM
        mov es, ax
        mov cx, 0xEFFF
        mov di, 0
        mov ax, 0
        cld
        rep stosw
        pop di
        pop es
        pop cx
        pop ax
        ret

video_retrace:
        push dx
        push ax

        call music_play

        mov dx, 0x03DA
.L1     in al, dx
        test al, 8
        jnz .L1
.L2     in al, dx
        test al, 8
        jz .L2

        pop ax
        pop dx
        ret

char_write:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov ah, 0x02		; command cursor
	mov bh, 0		; page
        mov dh, [bp+6]          ; row
        mov dl, [bp+8]          ; column
        int VIDEO

	mov ah, 0x09            ; command write with attr
	mov bl, [bp+10]         ; color
	mov al, byte [bp+4]     ; char
	mov cx, 1               ; repeat
	int VIDEO

	pop dx
	pop cx
	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret 8

text_write:
	push bp
	mov bp, sp
	push si

	mov si, [bp+4]		; messsage
.L1:	push word [bp+10]	; Color
	push word [bp+8]	; X
	push word [bp+6]	; Y
	push word [si]		; Char
	call char_write
	inc word [bp+8]
	inc si
	cmp byte [si], 0
	jne .L1

	pop si
	mov sp, bp
	pop bp
        ret 8

number_write:     ; outputs number pushed on stack
        push bp
        mov bp, sp
        push ax
        push bx
        push dx

        ;convert num to string
        mov ax, [bp+4]
        mov bx, 10

  .1:   mov dx, 0
        div bx
        add dx, '0'
	push word [bp+10]	; color
	push word [bp+8]	; X
	push word [bp+6]	; Y
	push dx 		; char
	call char_write
	dec word [bp+8]
        cmp ax, 0
        jnz .1

        pop dx
        pop bx
        pop ax
        mov sp, bp
        pop bp
        ret 8


text_set:
        mov ah, 0
        mov al, 0x03
        int VIDEO
        ret

exit:
        mov ah, 0x4c
        int DOS
        ret

section .data
keys:   times 128 db 0
