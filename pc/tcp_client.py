# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

# echo-client.py

import socket

# Press the green button in the gutter to run the script.
if __name__ == '__main__':

    HOST = "192.168.246.140"  # The server's hostname or IP address
    PORT = 8080  # The port used by the server

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
      #  s.sendall(b"Hello, world")
        while (1):
            data = s.recv(1500)
            print(f"Received {data!r}")

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
