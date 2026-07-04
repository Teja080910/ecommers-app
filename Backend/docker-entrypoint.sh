#!/bin/sh
set -e

# Render (and most container platforms) assign the listen port via $PORT.
# Default to 80 for local `docker run` testing where $PORT isn't set.
PORT="${PORT:-80}"

sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf

exec "$@"
