from fastapi import FastAPI
import time
from datetime import datetime

app = FastAPI()
start_time = time.time() 

@app.get("/health")
def health():
    uptime = round(time.time() - start_time, 2) 
    return {
        "nama": "Stefanus Yosua Mamamoba",
        "nrp": "5025231066",
        "status": "UP",
        "timestamp": datetime.now().isoformat(),
        "uptime": f"{uptime} seconds"
    }