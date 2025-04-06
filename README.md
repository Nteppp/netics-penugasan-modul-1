# netics-penugasan-modul-1

 ```
 http://104.214.185.247:8000/health
 ```

## Penjelasan Program
### main.py
```
from fastapi import FastAPI
import time
from datetime import datetime
```
Program menggunakan bahasa pemrograman python dan untuk membuat instance pada web akan menggunakan library `fastapi` dan library `time` serta `datetime` untuk mencatat uptime server dan waktu akses.
```
app = FastAPI()
start_time = time.time() 

@app.get("/health")
```
Selanjutnya dideklarasikan instance `app` untuk menjalankan server dan akan digunakan untuk mendefinisikan endpoint `/health` pada `@app.get("/health")` yang juga akan mengeksekusi fungsi health. `start_time` akan mencatat waktu berjalannya server saat program dieksekusi.
```
def health():
    uptime = round(time.time() - start_time, 2) 
    return {
        "nama": "Stefanus Yosua Mamamoba",
        "nrp": "5025231066",
        "status": "UP",
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "uptime": f"{uptime} seconds"
    }
```
`uptime` akan mengurang waktu sekarang dengan waktu yang dideklarasi sebelumnya. `timestamp` akan menampilkan waktu pada zona waktu UTC.

### Dockerfile
```
FROM python:3.11-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt
```
ini merupakan `build` stage agar dependencies tidak perlu didownload pada proses final. Setelah itu mengambil `requirements` yang berisi `fastapi` dan `uvicorn` digunakan untuk menjalankan server.
```
RUN useradd -m myuser
USER myuser
```
membuat user `myuser` untuk meningkatkan keamanan daripada menggunakan `root`
```
FROM python:3.11-slim
WORKDIR /app
COPY --from=build /install /usr/local
COPY --from=build /app /app
COPY main.py .
```
memasuki direktori `/app` untuk menyimpan semua dependencies yang sudah didownload di `/app` dan mengambil `main.py`
```
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```
container akan menggunakan port `8000` setelah itu akan melakukan eksekusi command untuk menjalankan server.

### main.yaml
```
name: Deploy FastAPI 

on:
  push:
    branches: 
      - main
```
workflow dijalankan ketika ada yang di push di `main`.
```
jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      IMAGE_NAME: fastapi-app
```
file .yaml memiliki beberapa jobs yang akan dijalankan pada ekosistem `ubuntu`. Selain itu ada `IMAGE_NAME` yang akan digunakan untuk eksekusi selanjutnya.
```
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: Dockerfile
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
```
langkah pertama akan mengambil seluruh source code, setelah itu menyiapkan docker buildx untuk membuat image docker. selanjutnya log in pada docker dilakukan dan proses build serta push dilakukan
```
    -   name: Deploy to VPS via SSH
        uses: appleboy/ssh-action@v0.1.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          port: 22
          script: |
            docker pull ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
            docker rm -f fastapi-app || true
            docker run -d --name fastapi-app -p 8000:8000 ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
```
setelah itu melakukan deployment dengan mengambil image terlebih dahulu. terakhir dilakukan mapping port 8000 pada container ke vps. karena menggunakan port 8000, maka dalam mengakses harus menggunakan `:8000` setelah mengisi ip.


## Hasil Akhir
![image](https://github.com/user-attachments/assets/e9b1c13a-9eba-4149-97fb-ef02ba6d18f2)
