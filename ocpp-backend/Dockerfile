ARG TARGET_ELIXER_TAG
ARG TARGET_ELIXIR_ENV=prod
FROM $TARGET_ELIXER_TAG as builder

ENV MIX_ENV $TARGET_ELIXIR_ENV

RUN mkdir -p /src && \
  apk add inotify-tools

COPY . /src/
WORKDIR /src
RUN mix local.hex --force && \
  mix archive.install hex phx_new --force && \
  mix deps.get && \
  mix local.rebar --force


RUN mix release ocpp_backend
COPY entrypoint.sh /root/entrypoint.sh

FROM scratch as export
COPY --from=builder /src/ .
ARG TARGET_ELIXER_TAG

FROM $TARGET_ELIXER_TAG as app
ARG TARGET_ELIXER_TAG
WORKDIR /app
COPY --from=export / /app
ENTRYPOINT [ "mix","run","--no-halt" ]
EXPOSE 8383