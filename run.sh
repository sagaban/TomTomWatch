#!/bin/bash
# Run TomTomWatch on Apple Silicon Macs via Rosetta.
# The bundled usb4java 1.3.0 only ships a darwin-x86-64 native; an arm64 JDK
# can't load it, so we invoke an x86_64 JDK under Rosetta.

set -e
cd "$(dirname "$0")/target"

JAVA_X64="$HOME/.java-x64/jdk-21.0.11+10/Contents/Home/bin/java"
if [ ! -x "$JAVA_X64" ]; then
    echo "x86_64 JDK not found at $JAVA_X64" >&2
    echo "Install with:" >&2
    echo "  mkdir -p ~/.java-x64 && curl -L -o /tmp/temurin21-x64.tar.gz \\" >&2
    echo "    'https://api.adoptium.net/v3/binary/latest/21/ga/mac/x64/jdk/hotspot/normal/eclipse' && \\" >&2
    echo "    tar -xzf /tmp/temurin21-x64.tar.gz -C ~/.java-x64" >&2
    exit 1
fi

exec arch -x86_64 "$JAVA_X64" -jar TomTomWatch.jar "$@"
