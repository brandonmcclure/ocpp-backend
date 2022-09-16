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
COPY --from=builder /src/_build/dev/rel/ocpp_backend/bin/ocpp_backend /

FROM scratch as app

COPY --from=export / /app/ocpp_backend
ENTRYPOINT [ "/app/ocpp_backend" ]
EXPOSE 8383