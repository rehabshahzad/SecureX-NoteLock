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

Note Security Flow
Create Note
→ Encrypt Password
→ Encrypt Note
→ Store Securely
Open Note
→ Verify Password
→ Decrypt Note
→ Display Note
→ Re-encrypt Note
Brute Force Protection

After 3 incorrect password attempts:

Note gets locked
Access is denied
Tech Stack
x86 Assembly
MASM
Irvine32
Note

This is a custom educational encryption project and not a replacement for modern encryption standards like AES or SHA.
