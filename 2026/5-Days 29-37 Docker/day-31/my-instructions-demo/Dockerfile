# 1. FROM - Defines the base image (lightweight python alpine)
FROM python:3.11-alpine

# 2. WORKDIR - Sets the working directory inside the container
WORKDIR /app

# 3. COPY - Copies app.txt from host machine into container's active working directory
COPY app.txt /app/app.txt

# 4. RUN - Executes shell commands during the image build lifecycle
RUN echo "Executing custom build triggers..." && cat /app/app.txt

# 5. EXPOSE - Documents that the container will listen on port 8080 at runtime
EXPOSE 8080

# 6. CMD - Specifies the default executable command run when container boots up
CMD ["python3", "-m", "http.server", "8080"]
