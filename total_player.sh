#!/bin/sh
cd /total_player
exec bundle exec puma -p 5000 -e production
