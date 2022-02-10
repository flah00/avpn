#!/usr/bin/env bash
sed -e 's/"/\\"/g' -e 's/\(.*\)/          "      \1\\n",/' openvpn.sh
