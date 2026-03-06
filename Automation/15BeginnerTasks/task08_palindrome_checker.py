word = input("Enter a word: ")

if word == word[::-1]:  # Check if the word is equal to its reverse
    print(word, "is a Palindrome")
else:
    print(word, "is Not a Palindrome")