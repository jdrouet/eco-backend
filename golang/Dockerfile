FROM golang:1-alpine3.14 AS builder

WORKDIR /code

COPY go.mod go.sum main.go /code/

RUN go build

FROM alpine:3.14

ENV ADDRESS=0.0.0.0:8080

COPY --from=builder /code/eco-backend /eco-backend

ENTRYPOINT ["/eco-backend"]

