import random

number = random.randint(1, 101)

guess = int(input("Guess a number between 1 and 100: "))

if guess > 0 and guess < 101:
    if guess == number:
        print("We matched! I guessed too", number)
    else:
        print("Nope! We did not match. I guessed", number)
else:
    print("Invalid number. Please guess a number between 1 and 100.")