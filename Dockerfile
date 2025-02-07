FROM golang AS builder
WORKDIR /app
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build ./main.go

FROM alpine
COPY --from=builder /app/main ./
ENTRYPOINT ["/main"]