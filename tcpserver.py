import socket
import sys

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
addr = ('localhost', int(sys.argv[1]))
print >>sys.stderr, 'listening on %s port %s' % addr
sock.bind(addr)
sock.listen(1)
conn, a = sock.accept()
print >>sys.stderr, 'Connected by', aa

while 1:
    data = conn.recv(1024)
    print >>sys.stderr, data
    if data:
        conn.sendall(data)
conn.close()
