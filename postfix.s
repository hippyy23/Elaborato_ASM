.data

invalid_str:
    .ascii "Invalid"

num:
    .long 1337

.text
    .global postfix

postfix:
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %esi
    pushl %edi

    movl 8(%ebp), %edx # edx contiene la stringa di input

    subl $4, %esp # creo uno spazio per il flag (per vedere il contenuto del flag utilizzare "-24(%ebp)")
    movl $0, -24(%ebp)

    subl $4, %esp # creo uno spazio per il puntatore (offset) ad ogni carattere (per vedere il contenuto del flag utilizzare "-28(%ebp)")
    movl $0, -28(%ebp)

    lea num, %esi

    xorl %ecx, %ecx # azzerro ecx, contatore per la stringa
    xorl %eax, %eax # azzerro eax, contiene un carattere della stringa (in ogni istante)

control:
    movl -28(%ebp), %ebx
    movb (%ebx, %edx), %al

    testb %al, %al # cmp $0, %al
    jz store_prep

    cmp $32, %al # controllo dello spazio (32)
    je prep

    cmp $43, %al # contollo del + (43)
    je sum

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
    addl $1, -28(%ebp)

    jmp control

invalid_prep:
    xorl %ebx, %ebx # funge da offset per la stringa
    movl $7, %ecx # lunghezza della stringa "Invalid"
    movl 12(%ebp), %edi # carico l'indirizzo di output in edi (registro destinazione)
    lea invalid_str, %esi # carico l'indirizzo della stringa "Invalid" in esi (registro sorgente)

    jmp invalid

invalid:
    movb (%esi, %ebx), %al # carico ogni carattere della stringa "Invalid" in eax
    movb %al, (%edi, %ebx) # carico ogni carattere nella stringa di output
    inc %ebx
    loop invalid
    movb $0, (%edi, %ebx)

    jmp end


prep:
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
    addl $1, -28(%ebp) # per saltare il carattere (spazio -> 32)

    cmp $1, -24(%ebp)
    je neg_val

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
    movl $0, -24(%ebp) # riporto il flag a 0

    jmp control
    
check_symb:
    addl $1, -28(%ebp)
    movl -28(%ebp), %ebx
    movb (%ebx, %edx), %al # guardo il prossimo carattere per controllare se e' un numero, uno spazio o un carattere non valido

    cmp $32, %al
    je subtraction
    testb %al, %al
    je subtraction

    # Le cifre vanno da 48-57 (compresi)
    cmp $48, %al
    jl invalid_prep
    cmp $57, %al
    jg invalid_prep

    movl $1, -24(%ebp) # flag impostato a 1

    jmp control

sum:
    popl %ebx
    popl %eax

    addl %ebx, %eax

    pushl %eax

    addl $1, -28(%ebp)
    jmp check_next
	
subtraction:
    popl %ebx
    popl %eax

    subl %ebx, %eax

    pushl %eax

    jmp check_next
	
multiplication:
    popl %ebx
    popl %eax

    mull %ebx

    pushl %eax

    addl $1, -28(%ebp)
    jmp check_next
	
division:
    xorl %edx, %edx
    popl %ebx
    popl %eax

    idivl %ebx

    pushl %eax

    addl $1, -28(%ebp)
    jmp check_next

check_next:
    xorl %eax, %eax

    # riporto l'indirizzo di input in edx
    movl 8(%ebp), %edx
    movl -28(%ebp), %ebx

    movb (%ebx, %edx), %al

    # controllo se la stringa e' finita
    testb %al, %al
    jz store_prep

    # Le cifre vanno da 48-57 (compresi)
    cmp $32, %al
    je to_cntrl
    cmp $48, %al
    jl invalid_prep
    cmp $57, %al
    jg invalid_prep

    addl $1, -28(%ebp)
    jmp control

to_cntrl:
    addl $1, -28(%ebp)
    jmp control

store_prep:
    popl %eax # risultato
    xorl %ecx, %ecx
    xorl %ebx, %ebx
    movl 12(%ebp), %edi # carico l'indirizzo di output in edi (registro destinazione)

    cmp $0, %eax
    jl store_prep_neg

    jmp continue_div

store_prep_neg:
    not %eax
    inc %eax
    movl $1, -24(%ebp)

    jmp continue_div

continue_div:
    cmp $10, %eax

    jge divide

    pushl %eax
    inc %ecx

    xorl %ebx, %ebx
    cmp $1, -24(%ebp)
    je insert_neg_symb
    jmp store

divide:
    xorl %edx, %edx
    movl $10, %ebx

    divl %ebx
    pushl %edx

    inc %ecx

    jmp continue_div

insert_neg_symb:
    movl $45, (%edi, %ebx)
    inc %ebx

    jmp store

store:
    popl %eax
    addl $48, %eax
    movl %eax, (%edi, %ebx)
    inc %ebx

    loop store
    jmp end

end:
    movl %ebp, %esp
    subl $20, %esp

    popl %edi
    popl %esi
    popl %edx
    popl %ecx
    popl %ebx
    popl %ebp

ret
