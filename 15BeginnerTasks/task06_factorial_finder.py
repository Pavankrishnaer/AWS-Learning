num = int(input("Enter number: "))

factorial = 1
print(num, "! = ", end="", sep="")

for i in range(num, 0, -1):
    print(i, end="")
    factorial *= i
    if i > 1:
        print(" x ", end="")
print(" =", factorial)