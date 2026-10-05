"""Disposable connectivity target; deliberately not a real database."""
import socketserver

class Handler(socketserver.BaseRequestHandler):
    def handle(self):
        self.request.sendall(b"server-controls-lab: simulated data service\n")

class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True

with Server(("0.0.0.0", 5432), Handler) as server:
    server.serve_forever()
