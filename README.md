SecureX Note Locker (Assembly)

A secure note-locking system built in x86 Assembly (MASM + Irvine32) that protects notes using a custom encryption algorithm, password authentication, and brute-force protection.

Features
Password-protected notes
Custom encryption algorithm
No plaintext password storage
Note encryption & decryption
Automatic re-encryption after viewing
Locks note after 3 failed attempts
Supports notes up to 200 characters
Password Requirements

Password must be:

Exactly 8 characters
At least 1 uppercase letter
At least 1 digit
At least 1 special character
Custom Encryption

Keys are generated from note number:

seed = (noteNumber × 37 + 91) mod 256
key1 = seed XOR A5h
key2 = ROL(key1,2)
key3 = key2 + 3Ch
Password Encryption

Uses:

XOR
Bit rotation
Cross mixing
Bit inversion

Passwords are stored only in encrypted form.


SecureX Encryption Flow


1. Password Encryption Flow
User enters 8-character password
        ↓
Validate password rules
        ↓
Generate key using note number
        ↓
Apply XOR with key
        ↓
Rotate bits
        ↓
Mix/scramble characters
        ↓
Invert bits
        ↓
Store encrypted password


2. Password Login Flow
User enters password again
        ↓
Encrypt it using same steps
        ↓
Compare with stored encrypted password
        ↓
If match → access granted
If not → access denied


3. Note Encryption Flow
User writes note
        ↓
Generate note-based key
        ↓
Apply XOR to each character
        ↓
Rotate bits
        ↓
Apply character mixing
        ↓
Invert bits
        ↓
Store encrypted note in memory


4. Note Decryption Flow
User enters correct password
        ↓
Access granted
        ↓
Encrypted note is loaded
        ↓
Reverse encryption steps
        ↓
Original note is displayed

After 3 incorrect password attempts:

Note gets locked
Access is denied
Tech Stack
x86 Assembly
MASM
Irvine32
Note

This is a custom educational encryption project and not a replacement for modern encryption standards like AES or SHA.
