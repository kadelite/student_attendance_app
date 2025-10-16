#!/usr/bin/env python3
"""
Simple HTTP server for Student Attendance App
Run this script to serve the web version locally
"""

import http.server
import socketserver
import os
import webbrowser
from pathlib import Path

# Configuration
PORT = 8080
DIRECTORY = "build/web"

def main():
    # Check if build directory exists
    if not os.path.exists(DIRECTORY):
        print("❌ Web build not found!")
        print("Run 'flutter build web --release' first")
        return

    # Change to the build directory
    os.chdir(DIRECTORY)
    
    # Create server
    Handler = http.server.SimpleHTTPRequestHandler
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"🚀 Student Attendance App Server Running!")
        print(f"📱 Open: http://localhost:{PORT}")
        print(f"🔗 Network: http://{get_local_ip()}:{PORT}")
        print("Press Ctrl+C to stop")
        
        # Try to open browser automatically
        try:
            webbrowser.open(f"http://localhost:{PORT}")
        except:
            pass
        
        # Serve forever
        httpd.serve_forever()

def get_local_ip():
    """Get local IP address for network access"""
    import socket
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "localhost"

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n👋 Server stopped!")
    except Exception as e:
        print(f"❌ Error: {e}")