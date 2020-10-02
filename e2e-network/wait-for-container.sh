#!/bin/sh

container="$1"
expected_message="$2"

for i in $(seq 1 120); do
  echo "Verifying if container $container is ready ($i)..."

  if docker logs "$container" 2>&1 | grep -q "$expected_message"; then
    echo "Container $container is ready!"
    exit 0
  else
    sleep 1
  fi
done

#timeout
echo "Failed to verify $container"
exit 1