FROM python:3.12-slim

WORKDIR /app

COPY app.py .
COPY test.py .

RUN python test.py

CMD ["python3","app.py"] 
