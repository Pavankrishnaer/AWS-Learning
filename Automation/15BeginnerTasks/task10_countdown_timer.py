import time

seconds = int(input("Enter seconds: "))

for i in range(seconds, -1, -1):
    print(i)
    time.sleep(1)