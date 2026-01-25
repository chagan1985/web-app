FROM python:3.12-alpine

WORKDIR /app

COPY build/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY application/ ./application/

CMD ["python", "application/main.py"]
