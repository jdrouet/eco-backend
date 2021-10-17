FROM golang:1-alpine AS builder

WORKDIR /code

COPY go.mod go.sum main.go /code/

RUN go build

FROM alpine

ENV HOST=0.0.0.0
ENV PORT=8080

COPY --from=builder /code/eco-backend /eco-backend

ENTRYPOINT ["/eco-backend"]

