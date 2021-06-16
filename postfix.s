.data

invalid_str:
    .ascii "Invalid"

num:
    .long

.text
    .global postfix

postfix:
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx
    pushl %ecx
    pushl %edx

    movl 8(%ebp), %edx # edx contiene la stringa di input

    leal num, %esi

    xorl %ecx, %ecx # azzerro ecx, contatore per la stringa
    xorl %eax, %eax # azzerro eax, contiene un carattere dalla stringa (in ogni istante)
    xorl %ebx, %ebx # azzerro ebx, contatore per il numero

control:
    movb (%ebx, %edx), %al

    testb %al, %al # cmp $0, %al
    jz store

    cmp $32, %al # controllo dello spazio (32)
    je prep

    cmp $43, %al # contollo del + (43)
    je subtraction

    cmp $45, %al # contollo del - (45)
    je check_symb

    cmp $42, %al # contollo del * (42)
    je multiplication

    cmp $47, %al # contollo del / (47)
    je division

    # Le cifre vanno da 48-57 (compresi)
    cmp $48, %al
    jl invalid_prep
    cmp $57, %al
    jg invalid_prep

    movb %al, (%ecx, %esi, 1) # caricamento del carattere nella var
    inc %ecx # incremento del contatore (lunghezza di ogni numero)
    inc %ebx # incremento del contatore (posizione nella stringa) 

    jmp control

invalid_prep:
    xorl %ebx, %ebx # funge da offset per la stringa
    movl $7, %ecx # lunghezza della stringa "Invalid"
    movl 12(%ebp), %eax # carico l'indirizzo di output in eax
    movl %eax, %edi # registro di destinazione (output)
    leal invalid_str, %esi # carico l'indirizzo della stringa "Invalid" in esi (registro sorgente)

    jmp invalid

invalid:
    movl (%esi, %ebx), %eax # carico ogni carattere della stringa "Invalid" in eax
    movl %eax, (%edi, %ebx) # carico ogni carattere nella stringa di output
    inc %ebx
    loop invalid

    jmp end


prep:
    pushl %ebx # salvo il contenuto di ebx (posizione all'interno della stringa)
    pushl %edx # salvo lo stato di edx (che contiene l'input)
    pushl %esi # salvo il puntatore al primo carattere (sara' modificato in seguito)

    movl $10, %ebx
    xorl %edx, %edx
    xorl %eax, %eax
    
    jmp conv_to_int

conv_to_int:
    mull %ebx

    movb (%esi), %dl
    subl $48, %edx
    addl %edx, %eax
    inc %esi

    loop conv_to_int

    jmp push_num

push_num:
    popl %esi # riporto esi allo stato iniziale
    popl %edx # riporto edx allo stato iniziale
    popl %ebx # riporto ebx allo stato iniziale
    popl %ecx # contiene il flag
    inc %ebx # per saltare il carattere (spazio -> 32)

    cmp $1, %ecx
    je neg_val

    pushl %ecx
    pushl %eax # salvo il numero sullo stack
    xorl %eax, %eax
    xorl %ecx, %ecx
    jmp control

neg_val:
    not %eax
    inc %eax

    pushl %eax
    xorl %eax, %eax
    xorl %ecx, %ecx
    jmp control
    
check_symb:
    inc %ebx

    movb (%ebx, %edx), %al

    cmp $32, %al
    je subtraction

    pushl $1

    jmp control

sum:
	popl %eax
	popl %ebx
	
	addl %ebx, %eax
	
	pushl %eax
	
subtraction:
	popl %eax
	popl %ebx
	
	subl %ebx, %eax
	
	pushl %eax
	
	
multiplication:
	popl %eax
	popl %ebx
	
	mull %ebx
	
	pushl %eax
	
division:
	popl %eax
	popl %ebx
	
	divl %ebx
	
	pushl %eax

store:
    # scrivere il risultato


end:
    movl %ebp, %esp
    subl $12, %esp

    popl %edx # 
    popl %ecx # 
    popl %ebx # 
    popl %ebp

ret
