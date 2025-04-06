FROM python:3.11-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

RUN useradd -m myuser
USER myuser

FROM python:3.11-slim
WORKDIR /app
COPY --from=build /install /usr/local
COPY --from=build /app /app
COPY main.py .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
