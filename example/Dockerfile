# Dockerfile
FROM python:3.9.1-buster
LABEL authors="auto"

COPY requirements.txt .

COPY sync.py .

RUN pip install --upgrade pip && pip install numpy==1.21.5 && pip install pandas==1.3.3 && pip install -r requirements.txt

CMD ["python", "sync.py"]