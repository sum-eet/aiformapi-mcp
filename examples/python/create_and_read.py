"""Create a form, then read its responses.

Source: https://aiformapi.com/docs/quickstart
Needs the requests package. Run: AIFORMAPI_KEY=afk_... python create_and_read.py
"""
import os

import requests

BASE = "https://aiformapi.com/v1"
KEY = os.environ.get("AIFORMAPI_KEY")
if not KEY:
    raise SystemExit("Set AIFORMAPI_KEY first.")

session = requests.Session()
session.headers.update({"Authorization": f"Bearer {KEY}"})

resp = session.post(
    f"{BASE}/forms",
    json={
        "title": "Friday dinner RSVP",
        "description": "Tell us if you can come. It takes 20 seconds.",
        "fields": [
            {"id": "full_name", "label": "Your name", "type": "short_text", "required": True},
            {
                "id": "attending",
                "label": "Can you come?",
                "type": "single_choice",
                "required": True,
                "options": ["Yes", "No", "Maybe"],
            },
            {"id": "guests", "label": "How many people are you bringing?", "type": "number", "min": 0, "max": 5},
        ],
        "settings": {"agent_fill": True, "confirmation_message": "Thanks. See you Friday."},
    },
    timeout=30,
)
resp.raise_for_status()
form = resp.json()
print("Share this link:", form["public_url"])

# Read the responses. The list is empty until someone submits the form.
r = session.get(f"{BASE}/forms/{form['id']}/responses", params={"format": "json"}, timeout=30)
r.raise_for_status()
for row in r.json()["data"]:
    print(row["submitted_at"], row["source"], row["answers"])
