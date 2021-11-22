FROM python:3.9-bullseye

WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt

COPY *.py /code/

CMD ["python", "app.py"]

