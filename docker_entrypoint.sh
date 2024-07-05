#!/bin/sh

printf "\n\n [i] Starting Boltz...\n\n"
exec tini nginx -g "daemon off;"