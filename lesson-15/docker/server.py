from http.server import HTTPServer, BaseHTTPRequestHandler
import socket
import sys 
import time

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()
        self.wfile.write(b'<b>Hello from hostname:</b> ' + socket.gethostname().encode() + b'<br><br>')
        self.wfile.write(b'<b>Interval: </b> ' + str(interval).encode() + b'<br><br>')
        self.wfile.write(b'<b>Desired count of print: </b> ' + str(desired_count).encode() + b'<br><br>')
        count = 1
        while(count <= desired_count):
            self.wfile.write(b"<b>" + str(count).encode() + b".</b> " + b"<b>Current time: </b>" + str(time.strftime("%X")).encode() + b"<br>")
            time.sleep(interval)
            count+=1
        self.wfile.write(b"<br><b>End of loop.</b>")
            
interval = int(sys.argv[1])
desired_count = int(sys.argv[2])

SERVER_PORT = 8002
httpd = HTTPServer(('0.0.0.0', SERVER_PORT), SimpleHTTPRequestHandler)
print('Listening on port %s ...' % SERVER_PORT)
httpd.serve_forever()