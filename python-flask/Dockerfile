FROM python:3.9-alpine3.14

WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt

COPY *.py /code/

CMD ["python", "app.py"]

