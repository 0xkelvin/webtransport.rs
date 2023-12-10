FROM rust:1.74-slim-bookworm as builder

RUN rustup default nightly
RUN rustup target add wasm32-unknown-unknown

RUN apt-get update && apt-get install -y \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN cargo install cargo-leptos

WORKDIR /app

COPY . .

RUN cargo leptos build --release

FROM debian:bookworm-slim

# Copy the server binary to the /app directory
COPY --from=builder /app/target/release/leptos-actix-webtransport-template /app/
# /target/site contains our JS/WASM/CSS, etc.
COPY --from=builder /app/target/site /app/site
# Copy Cargo.toml if it’s needed at runtime
COPY --from=builder /app/Cargo.toml /app/
WORKDIR /app
ENV RUST_LOG="info"
ENV LEPTOS_SITE_ADDR="0.0.0.0:8080"
ENV LEPTOS_SITE_ROOT="site"
EXPOSE 8080

CMD ["/app/leptos-actix-webtransport-template"]
