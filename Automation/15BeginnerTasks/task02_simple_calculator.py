def add(num1, num2):
    return num1 + num2

def subtract(num1, num2):
    return num1 - num2

def multiply(num1, num2):
    return num1 * num2

def divide(num1, num2):
    if num2 == 0:
        return "Error: Division by zero"
    return num1 / num2


def get_numbers():
    try:
        num1 = float(input("Enter first number: "))
        num2 = float(input("Enter second number: "))
        return num1, num2
    except ValueError:
        print("Invalid number entered.")
        return None


def choose_operation():
    op = input("Choose operation (+, -, *, /) or type 'quit' to exit: ")
    return op


def calculator():
    while True:
        operation = choose_operation()

        if operation.lower() in ["quit", "exit"]:
            print("Calculator closed.")
            break

        numbers = get_numbers()

        if numbers is None:
            continue

        num1, num2 = numbers

        if operation == "+":
            print("You chose Addition. Result:", add(num1, num2))

        elif operation == "-":
            print("You chose Subtraction. Result:", subtract(num1, num2))

        elif operation == "*":
            print("You chose Multiplication. Result:", multiply(num1, num2))

        elif operation == "/":
            print("You chose Division. {} was divided by {}. Result:".format(num1, num2), divide(num1, num2))

        else:
            print("Invalid operation selected.")


calculator()