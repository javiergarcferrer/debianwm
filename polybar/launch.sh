# !/usr/bin/env bash
polybar-msg cmd quit

polybar main | tee -a /tmp/polybar.log & disown
