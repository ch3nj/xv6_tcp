import socket
import sys

addr = ('localhost', int(sys.argv[1]))
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(addr)

for i in range(int(sys.argv[2])):
    sock.sendall('Hello, world')
    data = sock.recv(1024)
    print 'Received', repr(data)

sock.close()
