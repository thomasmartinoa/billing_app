#!/bin/sh
# Maven Wrapper script for Unix-like systems

# Resolve the project base directory
BASEDIR=$(dirname "$0")
cd "$BASEDIR" || exit 1

# Check if mvnw exists
if [ -f "./mvnw" ]; then
    ./mvnw "$@"
else
    # Fallback to system Maven
    mvn "$@"
fi
