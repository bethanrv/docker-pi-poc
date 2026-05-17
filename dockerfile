# --- Stage 1: Build ---
FROM ghcr.io/astral-sh/uv:latest AS uv_bin
FROM python:3.12-slim-bookworm AS builder

# Install build tools and dependencies for compiling liblgpio
RUN apt-get update && apt-get install -y \
    gcc \
    swig \
    make \
    wget \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install the actual C library (lgpio) that Debian is missing
RUN wget https://github.com/joan2937/lg/archive/master.tar.gz && \
    tar zxvf master.tar.gz && \
    cd lg-master && \
    make install

COPY --from=uv_bin /uv /bin/uv
WORKDIR /app

# Now uv can compile the Python 'lgpio' wrapper because the C headers are installed
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-cache

# --- Stage 2: Runtime ---
FROM python:3.12-slim-bookworm

WORKDIR /app

# We must copy the compiled C libraries from the builder to the runtime
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /app/.venv /app/.venv
COPY . .

# Refresh the library cache so the system finds liblgpio.so
RUN ldconfig

ENV PATH="/app/.venv/bin:$PATH"

# check w/o
ENV GPIOZERO_PIN_FACTORY=lgpio

CMD ["python", "main.py"]
