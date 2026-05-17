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

# Build the C library (lgpio)
RUN wget https://github.com/joan2937/lg/archive/master.tar.gz && \
    tar zxvf master.tar.gz && \
    cd lg-master && \
    make install

COPY --from=uv_bin /uv /bin/uv
WORKDIR /app

# Install dependencies directly into the SYSTEM python
COPY pyproject.toml uv.lock ./
RUN uv pip install --no-cache --system -r pyproject.toml

# --- Stage 2: Runtime ---
FROM python:3.12-slim-bookworm

WORKDIR /app

# Copy compiled C libraries
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
# Copy the installed python packages from system site-packages
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY . .

RUN ldconfig

CMD ["python", "main.py"]
