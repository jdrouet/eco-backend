FROM python

WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt

COPY *.py /code/

CMD ["python", "app.py"]

