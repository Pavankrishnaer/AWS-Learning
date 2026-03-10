# Display all the prime numbers between 1 to 250.

for num in range(1, 251):
    is_prime = True
    for i in range(2, num):
        if num % i == 0:
            is_prime = False
            break
    if is_prime and num > 1:
        print(num, "is a Prime Number")
    else:
        print(num, "is Not a Prime Number")
