# The admission command is deliberately the first Apple Silicon-specific leaf.
# It is read-only and must pass before any Apple hardware setup can mutate the
# target.  The compatible path override is also used by the shell test suite.
"$OMARCHY_PATH/bin/omarchy-hw-apple-platform-admission"
