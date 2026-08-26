# ------------------------------------------------------------------------------
# LM Studio (lms)
# ------------------------------------------------------------------------------

# Start LM Studio server
[group('AI')]
start-lms:
    @echo "Starting LM Studio server..."
    lms server start --bind 0.0.0.0 --cors
