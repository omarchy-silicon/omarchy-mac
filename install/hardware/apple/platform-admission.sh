# The admission command is deliberately the first Apple Silicon-specific leaf.
# It is read-only and must pass before any Apple hardware setup can mutate the
# target.  Diagnostics may pass an explicit path directly to the command.
"$OMARCHY_PATH/bin/omarchy-hw-apple-platform-admission"
