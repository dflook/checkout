FROM alpine

RUN apk add --no-cache git

RUN git config --global init.defaultBranch main \
 && git config --global gc.auto 0 \
 && git config --global checkout.workers -1 \
 && git config --global core.fsync none \
 && git config --global fetch.parallel 0

COPY entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]
