#!/usr/bin/env bash
# Create a form, then read its responses as JSON and as CSV.
# Source: https://aiformapi.com/docs/quickstart
#
# Step 1: set your key.   export AIFORMAPI_KEY="afk_paste_your_key_here"
# Step 2: run this file to create the form. Copy the "id" from the answer.
# Step 3: read the responses.   FORM_ID=frm_... ./create-and-read.sh read

set -euo pipefail

if [ -z "${AIFORMAPI_KEY:-}" ]; then
  echo "Set AIFORMAPI_KEY first." >&2
  exit 1
fi

if [ "${1:-create}" = "create" ]; then
  curl -X POST https://aiformapi.com/v1/forms \
    -H "Authorization: Bearer $AIFORMAPI_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "title": "Friday dinner RSVP",
      "description": "Tell us if you can come. It takes 20 seconds.",
      "fields": [
        {"id": "full_name", "label": "Your name", "type": "short_text", "required": true},
        {"id": "attending", "label": "Can you come?", "type": "single_choice",
         "required": true, "options": ["Yes", "No", "Maybe"]},
        {"id": "guests", "label": "How many people are you bringing?", "type": "number",
         "min": 0, "max": 5}
      ],
      "settings": {"agent_fill": true, "confirmation_message": "Thanks. See you Friday."}
    }'
  echo
  echo "Share the public_url. Keep the id for the read step."
  exit 0
fi

if [ "$1" = "read" ]; then
  if [ -z "${FORM_ID:-}" ]; then
    echo "Set FORM_ID first." >&2
    exit 1
  fi

  # JSON
  curl "https://aiformapi.com/v1/forms/$FORM_ID/responses?format=json" \
    -H "Authorization: Bearer $AIFORMAPI_KEY"
  echo

  # CSV
  curl "https://aiformapi.com/v1/forms/$FORM_ID/responses?format=csv" \
    -H "Authorization: Bearer $AIFORMAPI_KEY" \
    -o responses.csv
  echo "Wrote responses.csv"
fi
