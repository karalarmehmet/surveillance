# --- Build stage (what you already have) ---
FROM golang:1.23.2-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN cp run.sh.example run.sh
RUN cp database.yml.example database.yml
RUN chmod +x run.sh
RUN go build -o surveillance cmd/web/*.go

FROM alpine:3.18
WORKDIR /app

# Copy the compiled binary AND the run script from the builder stage
COPY --from=builder /app/surveillance .
COPY --from=builder /app/run.sh .  

RUN sed -i 's/\r$//' ./run.sh

# Create and switch to a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 4000
CMD ["./run.sh"]