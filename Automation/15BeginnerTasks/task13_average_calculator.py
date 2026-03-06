total = 0
count = 0

while True:
    num = float(input("Enter a number. (Enter 0 to stop): "))

    if num == 0:
        break

    total = total + num
    count = count + 1

average = total / count

print("Sum of numbers is:", total)
print("Count of numbers is:", count)
print("Average of numbers is:", average)