INCLUDE INCLUDE\Irvine32.inc

.stack 4096

.data
;TEXT MESSAGES
title1 BYTE 'Welcome to SecureX',0
menu BYTE '1.Set a Note  2.Open a Note  3.Exit  (choose one option)',0
NoteNumMsg BYTE 'Enter your note number',0
NotePwMsg BYTE 'Setup your password (it must be 8 characters long. it must have a digit,a special character and an Uppercase letter)',0
EnterNoteMsg BYTE 'Type your note here:',0
setupDone BYTE 'Note setup completed successfully',0
acceptedMsg BYTE 'Access Granted',0
deniedMsg BYTE 'Access Denied',0
invalidMenuChoice BYTE 'Please choose a valid option',0
exitChoice BYTE 'Thankyou for trusting us. Visit again soon ;)',0
NoNoteMsg BYTE 'No note has been setup yet. Create your first one',0
invalidPwFormat BYTE 'Password not eligible (must be 8 characters long and have atleast one digit and a special character and an Uppercase character. Try Again)',0
keyGenerationMsg BYTE 'Keys generated successfully',0
pwEncryptConfirmation BYTE 'Your password is successfully encrypted and stored',0
OpenNoteNum BYTE 'Enter the note number you want to open',0
OpenPwMsg BYTE 'Enter your password',0
wrongNoteNumMsg BYTE 'No note exists with this number',0
lockedMsg BYTE 'This note has been locked after 3 failed attempts',0
attemptsLeftMsg BYTE 'Wrong password. Attempts left: ',0
failedAttempts BYTE 0
noteLocked BYTE 0
noteExists BYTE 0
;ACTUAL DATA
noteNum DWORD ?
key1 BYTE ?
key2 BYTE ?
key3 BYTE ?
pwinput BYTE 9 DUP(0)
pwlength DWORD ?
encryptedInput BYTE 9 DUP(0) ;encrypted entered pw
storedEncryptedInput BYTE 9 DUP(0) ;encrypted stored pw
noteText BYTE 201 DUP (0) ;limit upto 200 chars
noteLength DWORD ?
choice DWORD ? ;its the menu choice user chose
tempSecond BYTE ? ;during encryption we need the original second half

;validation checks for pw
hasUpper BYTE 0
hasDigit BYTE 0
hasSpecial BYTE 0 ;0 signifies not found

.code
main PROC

MainMenu:
call Clrscr
mov edx, OFFSET title1
call WriteString
call Crlf
mov edx, OFFSET menu
call WriteString
call ReadInt
mov choice,eax
call Crlf
cmp choice,1
je SetupNote

cmp choice,2
je OpenNote

cmp choice,3
je ExitApp

mov edx, OFFSET invalidMenuChoice
call WriteString
call Crlf
jmp MainMenu

;Note setup logic
SetupNote:

mov edx, OFFSET NoteNumMsg ;firstly we create our three keys
    ; Key generation
    ; seed = (N * 37 + 91) mod 256
    ; h1 = seed XOR A5h
    ; h2 = ROL(h1, 2)
    ; h3 = h2 + 3Ch
    ;This is the algorithm followed 
call WriteString
call Crlf
call ReadInt
mov noteNum, eax ;eax stores that number

call GenerateKeys
mov edx, OFFSET keyGenerationMsg
call WriteString
Call Crlf


; NOW MOVE ON TO THE PASSWORD
mov edx, OFFSET NotePwMsg
call WriteString
call Crlf

mov edx, OFFSET pwinput
mov ecx, 8
call ReadString
mov pwlength, eax ;eax internally gets the length ig
call ValidatePassword
cmp eax,1
jne IneligiblePassword
call EncryptPassword

;copying encrypted input into stored input
mov esi, OFFSET encryptedInput
mov edi,OFFSET storedEncryptedInput
mov ecx,8
StoreLoop:
mov al,[esi]
mov [edi],al
inc esi
inc edi
loop StoreLoop
mov BYTE PTR [edi],0

mov edx,OFFSET pwEncryptConfirmation
call WriteString
Call Crlf
Call Crlf

;Enter Note text
mov edx, OFFSET EnterNoteMsg
call WriteString
call Crlf
call Crlf

mov edx, OFFSET noteText
mov ecx,127 ;"The Irvine32 ReadString function internally restricts input length to 128 bytes, so buffer size must be controlled accordingly to prevent runtime errors."
call ReadString
mov noteLength,eax

call EncryptNote
mov failedAttempts, 0
mov noteLocked, 0
mov noteExists,1
mov edx, OFFSET setupDone
call WriteString
call Crlf
call WaitMsg
jmp MainMenu

IneligiblePassword:
mov edx,  OFFSET invalidPwFormat
call WriteString
call Crlf
call WaitMsg
jmp MainMenu


OpenNote:
cmp noteExists,1
jne NoNoteAvailable

cmp noteLocked,1
je NoteIsLocked

mov edx, OFFSET OpenNoteNum
call WriteString
call Crlf
call ReadInt

cmp eax, noteNum
jne WrongNoteNumber ;eax stores that number
call GenerateKeys
mov edx, OFFSET OpenPwMsg
call WriteString
call Crlf
mov edx, OFFSET pwinput
mov ecx,8
call ReadString
mov pwlength,eax

cmp pwlength,8
jne AccessDenied

call EncryptPassword
call ComparePasswords
cmp eax,1
jne AccessDenied
jmp AccessGranted


NoNoteAvailable:
    mov edx, OFFSET NoNoteMsg
    call WriteString
    call Crlf
    call WaitMsg
    jmp MainMenu

WrongNoteNumber:
    mov edx, OFFSET wrongNoteNumMsg
    call WriteString
    call Crlf
    call WaitMsg
    jmp MainMenu

AccessDenied:
    inc failedAttempts
    mov edx, OFFSET deniedMsg
    call WriteString
    call Crlf

    cmp failedAttempts, 3
    je LockTheNote

    mov edx, OFFSET attemptsLeftMsg
    call WriteString

    movzx eax, failedAttempts
    mov ebx, 3
    sub ebx, eax
    mov eax, ebx
    call WriteDec
    call Crlf

    call WaitMsg
    jmp MainMenu

AccessGranted:
    mov failedAttempts, 0
    mov edx, OFFSET acceptedMsg
    call WriteString
    call Crlf
    call Crlf

    call DecryptNote

    mov edx, OFFSET noteText
    call WriteString
    call Crlf
    call WaitMsg

    call EncryptNote

    jmp MainMenu

NoteIsLocked:
    mov edx, OFFSET lockedMsg
    call WriteString
    call Crlf
    call WaitMsg
    jmp MainMenu


LockTheNote:
    mov noteLocked, 1
    mov edx, OFFSET lockedMsg
    call WriteString
    call Crlf
    call WaitMsg
    jmp MainMenu

ExitApp:
mov edx, OFFSET exitChoice
call WriteString
call Crlf
exit


main ENDP
GenerateKeys PROC
    mov eax, noteNum
    imul eax, 37
    add eax, 91
    and eax, 0FFh

    mov bl, al
    mov al, bl
    xor al, 0A5h
    mov key1, al

    rol al, 2
    mov key2, al

    add al, 3Ch
    mov key3, al

    ret
GenerateKeys ENDP
ValidatePassword PROC
    cmp pwlength, 8
    jne InvalidPwProc

    mov hasUpper, 0
    mov hasDigit, 0
    mov hasSpecial, 0

    mov esi, OFFSET pwinput
    mov ecx, 8

ValidateLoop:
    mov al, [esi]

    cmp al, 'A'
    jl CheckDigitProc
    cmp al, 'Z'
    jg CheckDigitProc
    mov hasUpper, 1
    jmp NextCharProc

CheckDigitProc:
    mov al, [esi]
    cmp al, '0'
    jl CheckSpecialProc
    cmp al, '9'
    jg CheckSpecialProc
    mov hasDigit, 1
    jmp NextCharProc

CheckSpecialProc:
    mov al, [esi]
    cmp al, 'a'
    jl MarkSpecialProc
    cmp al, 'z'
    jg MarkSpecialProc
    jmp NextCharProc

MarkSpecialProc:
    mov hasSpecial, 1

NextCharProc:
    inc esi
    loop ValidateLoop

    cmp hasUpper, 1
    jne InvalidPwProc

    cmp hasDigit, 1
    jne InvalidPwProc

    cmp hasSpecial, 1
    jne InvalidPwProc

    mov eax, 1
    ret

InvalidPwProc:
    mov eax, 0
    ret
ValidatePassword ENDP

EncryptPassword PROC
    ;copy pwinput to encryptedInput
    mov esi, OFFSET pwinput
    mov edi, OFFSET encryptedInput
    mov ecx, 8

CopyPwProc:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop CopyPwProc

    mov BYTE PTR [edi], 0

    ;Step 1 + Step 2 + Step 3
    mov esi, OFFSET encryptedInput
    mov ecx, 4

EncryptHalvesProc:
    mov al, [esi]
    xor al, key1
    rol al, 2
    xor al, key2
    mov [esi], al

    mov al, [esi+4]
    xor al, key2
    rol al, 1
    xor al, key1
    mov [esi+4], al

    inc esi
    loop EncryptHalvesProc

    ; Step 4 + Step 5
    mov esi, OFFSET encryptedInput
    mov ecx, 4
    mov bl, 0

MixPhaseProc:
    mov al, [esi+4]
    mov tempSecond, al

    mov al, [esi]
    xor al, tempSecond
    not al
    mov [esi], al

    mov al, tempSecond
    mov dl, key3
    add dl, bl
    xor al, dl
    not al
    mov [esi+4], al

    inc esi
    inc bl
    loop MixPhaseProc

    ret
EncryptPassword ENDP

ComparePasswords PROC
    mov esi, OFFSET encryptedInput
    mov edi, OFFSET storedEncryptedInput
    mov ecx, 8

CompareLoopProc:
    mov al, [esi]
    cmp al, [edi]
    jne NotMatchedProc

    inc esi
    inc edi
    loop CompareLoopProc

    mov eax, 1
    ret

NotMatchedProc:
    mov eax, 0
    ret
ComparePasswords ENDP
EncryptNote PROC
    mov esi, OFFSET noteText
    mov ecx, noteLength
    cmp ecx, 0
    je EncryptNoteDone

EncryptNoteLoop:
    mov al, [esi]
    xor al, key1
    rol al, 1
    add al, key2
    xor al, key3
    mov [esi], al
    inc esi
    loop EncryptNoteLoop

EncryptNoteDone:
    ret
EncryptNote ENDP
DecryptNote PROC
    mov esi, OFFSET noteText
    mov ecx, noteLength
    cmp ecx, 0
    je DecryptNoteDone

DecryptNoteLoop:
    mov al, [esi]
    xor al, key3
    sub al, key2
    ror al, 1
    xor al, key1
    mov [esi], al
    inc esi
    loop DecryptNoteLoop

DecryptNoteDone:
    ret
DecryptNote ENDP
END main