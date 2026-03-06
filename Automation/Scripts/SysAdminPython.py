# Python script that connects to a running EC2 instance and:
# 1. Creates a new Linux user with a name you choose.
# 2. Creates a home directory for that user (if it's not automatically created).
# 3. Ensures the new user owns their home directory.
# 4. Sets correct ownership

import subprocess
import os
import pwd

username = input("Enter the required Username: ")

isUsernameExists = subprocess.run(["id", username], capture_output=True)

# check if user exists
if isUsernameExists.returncode == 0:
    print("User: {}, already exists".format(username))
else:
    subprocess.run(["sudo", "useradd", "-m", username])
    print("User: {}, created successfully".format(username))

# check if user has the home directory
print("Checking if the user has home directory")
newUserHomeDirectory = f"/home/{username}"
if not os.path.exists(newUserHomeDirectory):
    subprocess.run(["sudo", "mkdir", newUserHomeDirectory])
    print("User: {}, has the home directory: {}".format(username, newUserHomeDirectory))
else:
    print("User: {}, has the home directory: {}".format(username, newUserHomeDirectory))

# Check ownership
print("Checking if the user has right ownership")
owner_uid = os.stat(newUserHomeDirectory).st_uid
expected_uid = pwd.getpwnam(username).pw_uid

if owner_uid != expected_uid:
    print("Fixing ownership...")
    subprocess.run(["sudo", "chown", f"{username}:{username}", newUserHomeDirectory])
else:
    print("User: {}, has the ownership".format(username))

print("User setup completed.")
