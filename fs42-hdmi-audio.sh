#!/bin/bash

# Wait for the per-user PulseAudio server.
for i in $(seq 1 30); do
    if pactl info >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

if ! pactl info >/dev/null 2>&1; then
    echo "PulseAudio did not become available"
    exit 1
fi

# Create our known-good HDMI sink if it does not already exist.
if ! pactl list short sinks | awk '{print $2}' | grep -qx 'hdmi'; then
    echo "Loading Orange Pi HDMI PulseAudio sink..."

    pactl load-module module-alsa-sink \
        device=plughw:CARD=HDMI,DEV=0 \
        sink_name=hdmi || exit 1
fi

# Make sure FieldStation42's @DEFAULT_SINK@ points here.
pactl set-default-sink hdmi || exit 1

echo "PulseAudio HDMI sink ready."
