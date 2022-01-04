FROM rust:bullseye AS builder

# RUN apk add --no-cache musl-dev

WORKDIR /code
RUN cargo init
COPY Cargo.toml Cargo.lock /code/
RUN cargo fetch
COPY src /code/src
RUN cargo build --release --offline

FROM debian:bullseye

COPY --from=builder /code/target/release/eco-backend /eco-backend

ENTRYPOINT ["/eco-backend"]
