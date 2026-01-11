from fastapi import FastAPI
import os
import socket
from datetime import datetime

app = FastAPI()

@app.get("/")
async def read_root():
    return {
        "message": "Hello from FastAPI",
        "hostname": socket.gethostname(),
        "ip": socket.gethostbyname(socket.gethostname()),
        "timestamp": datetime.now().isoformat(),
        "database": os.getenv("MYSQL_DATABASE", "netology")
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)