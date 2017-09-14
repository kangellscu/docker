#!/bin/bash

set -e

# We want build a immutable service, so after inited, configuration should not be changed

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
