import subprocess
import random
import string
import datetime
import boto3
import socket

def check_password_expiration(username):
    cmd = f"chage -l {username}"
    output = subprocess.check_output(cmd, shell=True).decode("utf-8")
    expiration_date_str = None

    for line in output.split("\n"):
        if "Password expires" in line:
            expiration_date_str = line.split(": ")[-1]
            break

    if expiration_date_str:
        expiration_date = datetime.datetime.strptime(expiration_date_str, "%b %d, %Y")
        days_remaining = (expiration_date - datetime.datetime.now()).days
        if days_remaining <= 60:
            return True

    return False

def generate_random_password(length=12):
    characters = string.ascii_letters + string.digits
    password = ''.join(random.choice(characters) for _ in range(length))
    return password

def send_to_secrets_manager(username, password):
    client = boto3.client('secretsmanager')
    secret_name = f"{socket.gethostname()}ec2--password-{datetime.datetime.today().strftime('%Y-%m-%d_%H%M')}"
    response = client.create_secret(
        Name=secret_name,
        SecretString=password
    )

    print(f"Password for {username} has been sent to Secrets Manager.")

def main():
    username = "ec2-user"

    if check_password_expiration(username):
        new_password = generate_random_password()
        print(new_password)
        subprocess.run(['passwd', username], input=f"{new_password}\n{new_password}\n".encode())

        print(f"Password for user '{username}' has been successfully reset.")
        send_to_secrets_manager(username, new_password)
    else:
        print(f"The password for {username} is not expiring within 60 days.")

if __name__ == '__main__':
    main()