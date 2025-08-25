FROM alpine:3.20
RUN apk add --no-cache bash busybox-extras tar
WORKDIR /app
COPY producer.sh /app/producer.sh
RUN chmod +x /app/producer.sh
ENV DATA_DIR=/data SHM_OUT=/dev/shm/outbox EXPORT_HTTP=0
EXPOSE 9000
CMD ["/app/producer.sh"]
