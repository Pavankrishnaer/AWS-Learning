def temperature_converter_fahrenheit():
    c = float(input("Enter temperature in Celsius: "))
    f = (c * 9/5) + 32
    print("Fahrenheit:", f)

def temperature_converter_celsius():
    f = float(input("Enter temperature in Fahrenheit: "))
    c = (f - 32) * 5/9
    print("Celsius:", c)

temperature_converter_fahrenheit()
temperature_converter_celsius()