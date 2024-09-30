FROM alpine

RUN apk add --no-cache git

RUN git config --system init.defaultBranch main \
 && git config --system gc.auto 0 \
 && git config --system checkout.workers -1 \
 && git config --system core.fsync none \
 && git config --system fetch.parallel 0

COPY entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]
