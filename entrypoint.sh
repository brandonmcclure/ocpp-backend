#/bin/sh

cd /src && mix deps.get
cd /src && mix ecto.create
cd /src && mix ecto.migrate
cd /src && mix phx.server
