#!/bin/sh
set -e

# Render (and most container platforms) assign the listen port via $PORT.
# Default to 80 for local `docker run` testing where $PORT isn't set.
PORT="${PORT:-80}"

sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Render/Cloudflare terminate TLS and proxy to us over plain HTTP on $PORT.
# Apache only ever sees "http" on a non-standard port, so without an explicit
# ServerName it leaks the real internal port (e.g. :10000) into any
# self-referential redirect it builds itself (e.g. mod_dir's automatic
# trailing-slash redirect for directory URLs). Pinning ServerName to the
# default http port (80) makes Apache treat that port as canonical and omit
# it from those redirects, matching what the public edge actually serves.
if ! grep -qE "^[[:space:]]*ServerName" /etc/apache2/sites-available/000-default.conf; then
    sed -i "/<VirtualHost/a ServerName localhost:80" /etc/apache2/sites-available/000-default.conf
fi

exec "$@"
