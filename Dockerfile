ARG TARGET_ELIXER_TAG
FROM $TARGET_ELIXER_TAG

RUN mkdir -p /src && \
  apk add inotify-tools

COPY ./src/hello_pheonix/ /src/
WORKDIR /src
RUN mix local.hex --force && \
  mix archive.install hex phx_new --force && \
  mix deps.get && \
  mix local.rebar --force
COPY entrypoint.sh /root/entrypoint.sh
CMD ["/bin/sh", "/root/entrypoint.sh"]
# CMD ["mix", "run","--no-halt"]

EXPOSE 4000