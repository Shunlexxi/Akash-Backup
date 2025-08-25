FROM alpine:3.20

RUN apk add --no-cache bash ca-certificates tzdata curl coreutils tar \
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community restic \
    && mkdir -p /app /tmp/ingest

COPY entrypoint.sh /app/entrypoint.sh
COPY include-exclude-example.txt /app/include-exclude.txt
RUN chmod +x /app/entrypoint.sh

ENV RESTIC_BACKUP_PATH=/tmp/ingest \
    RESTIC_CRON="0 * * * *" \
    RESTIC_FORGET_ARGS="--keep-daily 7 --keep-weekly 4 --prune" \
    HEALTHCHECK_PORT=8081

EXPOSE 8081
ENTRYPOINT ["/app/entrypoint.sh"]
