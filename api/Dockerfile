FROM python:3.8 AS builder
COPY requirements.txt .

RUN pip install --upgrade pip && \
  pip install --user --no-warn-script-location -r requirements.txt

FROM python:3.8-slim
WORKDIR /app

COPY --from=builder /root/.local/bin /root/.local/bin
COPY --from=builder /root/.local/lib /root/.local/lib
COPY src/ .

ENV PATH=/root/.local:$PATH

EXPOSE 8080

CMD [ "python","-tt","./app.py" ] 
