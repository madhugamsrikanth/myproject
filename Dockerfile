FROM python:3.12-slim

WORKDIR /app

COPY app.py .
COPY test.py .

RUN python test.py

EXPOSE 5001

CMD ["python3","app.py"] 
