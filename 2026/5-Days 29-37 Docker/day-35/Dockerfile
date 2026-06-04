# Dockerfile
# Multi-stage optimized & hardened build for Go application
# Applies container security and minimization standards (Day 35 Lab)

# =========================================================
# Stage 1: Build & Compile the application binary (Heavy SDK)
# =========================================================
FROM golang:1.22.3-alpine3.19 AS builder

WORKDIR /src

# Copy main source code
COPY main.go .

# Compile Go application with static linking & stripping debug information
# CGO_ENABLED=0 compiles statically to run without runtime shared libs
# -ldflags="-s -w" removes symbol tables and debug headers (saves ~30-50% size)
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /bin/myapp main.go

# =========================================================
# Stage 2: Deploy & Execute in a minimal, secure runtime (Hardened)
# =========================================================
FROM alpine:3.19.1

# Create a non-root system user and group for maximum runtime hardening
# Avoids security vulnerability if container is broken out into host shell
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /bin/myapp .

# Change ownership of the runtime binary to the non-root user
RUN chown appuser:appgroup myapp

# Switch executing user to the non-root account
USER appuser

# Expose web port
EXPOSE 8080

# Run the compiled binary
CMD ["./myapp"]
