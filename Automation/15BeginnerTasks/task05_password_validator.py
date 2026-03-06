password = input("Enter password: ")

has_letter = False
has_number = False
has_upper = False
has_lower = False

for char in password:
    if char.isalpha():
        has_letter = True
        if char.isupper():
            has_upper = True
        if char.islower():
            has_lower = True
    if char.isdigit():
        has_number = True

if len(password) >= 8 and has_letter and has_number:
    print("Valid password")
else:
    print("Invalid password")
