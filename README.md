SecureX Note Locker (Assembly)

A secure note-locking system implemented in x86 Assembly (MASM + Irvine32) that protects user notes using a custom-designed encryption algorithm.

Overview

SecureX allows users to:

Create password-protected notes
Store notes securely in memory
Encrypt passwords using a custom multi-stage encryption pipeline
Authenticate access by comparing encrypted credentials (no plaintext storage)

This project demonstrates low-level systems programming, data security concepts, and custom cryptographic design in Assembly.

 Features
 Password validation:
Exactly 8 characters
Must include:
At least one uppercase letter
At least one digit
At least one special character
 Custom encryption algorithm:
Multi-layer transformation (XOR, rotation, mixing, inversion)
Key-based obfuscation derived from note number
No plaintext password storage
 Secure authentication:
Input password is encrypted again
Compared with stored encrypted password
 Note system:
Create and store notes (up to 200 characters)
Protected access via password
Custom Encryption Design

Unlike standard libraries, this project uses a self-designed encryption pipeline:

 Key Generation

Keys are derived from the note number:

seed = (noteNumber * 37 + 91) mod 256
key1 = seed XOR 0xA5
key2 = ROL(key1, 2)
key3 = key2 + 0x3C
 Encryption Pipeline

Password (8 bytes) is processed as:

[P0 P1 P2 P3 | P4 P5 P6 P7]
Step 1: Split
First half: P0–P3
Second half: P4–P7
Step 2: Initial XOR
First half XOR key1
Second half XOR key2
Step 3: Bit Rotation
First half → ROL 2
Second half → ROL 1
Step 4: Cross XOR
First half XOR key2
Second half XOR key1
Step 5: Cross Mixing

For i = 0 to 3:

F[i] = F[i] XOR S[i]
S[i] = S[i] XOR (key3 + i)
Step 6: Final Obfuscation
F[i] = NOT F[i]
S[i] = NOT S[i]

 Security Characteristics
✔ Multi-stage transformation (non-linear behavior)
✔ Key-dependent encryption (varies per note)
✔ Bit-level operations (XOR, ROL, NOT)
✔ No direct reversibility without keys
✔ Prevents plaintext exposure

Note: This is a custom educational encryption scheme, not intended to replace industry-standard cryptography (e.g., AES, SHA).
