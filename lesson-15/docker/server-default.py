from http.server import HTTPServer, BaseHTTPRequestHandler
import socket
import sys 

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()
        self.wfile.write(b'<b>Hello from hostname:</b> ' + socket.gethostname().encode() + b'<br><br>')
        self.wfile.write(b'<b>Text arg: </b> ' + str(string_arg).encode() + b'<br><br>')

string_arg = sys.argv[1]
SERVER_PORT = 8000
httpd = HTTPServer(('0.0.0.0', SERVER_PORT), SimpleHTTPRequestHandler)
print('Listening on port %s ...' % SERVER_PORT)
httpd.serve_forever()