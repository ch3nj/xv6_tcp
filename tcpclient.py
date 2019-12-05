import socket
import sys

addr = ('localhost', int(sys.argv[1]))
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(addr)
sock.sendall('Hello, world')
data = sock.recv(1024)
sock.close()
print 'Received', repr(data)
