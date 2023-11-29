#!/bin/bash

# Run Flutter analyze and check for errors
if ! output=$(flutter analyze); then
    echo "COMMIT REJECTED: Flutter analyze found the following errors:"
    echo "$output"
    exit 1
fi

# Run Dart analyze and check for errors
if ! output=$(dart analyze); then
    echo "COMMIT REJECTED: Dart analyze found the following errors:"
    echo "$output"
    exit 1
fi

# If we made it this far, the commit is allowed
exit 0