# --- Build Stage ---
# (This stage is mostly fine, just removed the unnecessary mkdir/chown)
FROM golang:1.23.2-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# These steps are fine
RUN cp run.sh.example run.sh
RUN cp database.yml.example database.yml
RUN chmod +x run.sh
# Build the Go application
RUN go build -o surveillance cmd/web/*.go

# --- Final Stage ---
FROM alpine:3.18
WORKDIR /app

# 1. Create the user and group FIRST
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 2. Create the directory for uploads
RUN mkdir -p ./uploads

# 3. Copy the necessary files from the builder stage
COPY --from=builder /app/surveillance .
COPY --from=builder /app/run.sh .

# 4. Change ownership of ALL app files and directories at once
RUN chown -R appuser:appgroup /app

# 5. Clean up the run.sh script (if needed)
RUN sed -i 's/\r$//' ./run.sh

# 6. Switch to the non-root user
USER appuser

# Expose the port and set the default command
EXPOSE 4000
# Your CMD was already correct!
CMD ["./run.sh"]