import socket
import sys

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
addr = ('localhost', int(sys.argv[1]))
print >>sys.stderr, 'listening on %s port %s' % addr
sock.bind(addr)
sock.listen(1)
conn, addr = sock.accept()
print 'Connected by', addr
while 1:
    data = conn.recv(1024)
    if not data: break
    print(data)
    conn.sendall(data)
conn.close()
