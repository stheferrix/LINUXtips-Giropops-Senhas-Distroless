FROM cgr.dev/chainguard/python:latest-dev as builder
WORKDIR /app
COPY ./giropops-senhas/requirements.txt .
RUN pip install -r requirements.txt

FROM cgr.dev/chainguard/python:latest
COPY ./giropops-senhas /app
WORKDIR /app
COPY --from=builder /home/nonroot/.local/lib/python3.12/site-packages /home/nonroot/.local/lib/python3.12/site-packages
EXPOSE 5000
ENV REDIS_HOST=172.17.0.2
ENV FLASK_APP=app.py

ENTRYPOINT ["/usr/bin/python", "-m", "flask", "run", "--host=0.0.0.0"]
