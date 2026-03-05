num = int(input("Enter number: "))

is_prime = True

for i in range(2, num):
    if num % i == 0:
        is_prime = False

if is_prime and num > 1:
    print(num, "is a Prime number")
else:
    print(num, "is Not prime")