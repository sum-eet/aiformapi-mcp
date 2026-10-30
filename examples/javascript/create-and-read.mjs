// Create a form, then read its responses.
// Source: https://aiformapi.com/docs/quickstart
// Needs Node 18 or newer. Run: AIFORMAPI_KEY=afk_... node create-and-read.mjs

const BASE = "https://aiformapi.com/v1";
const KEY = process.env.AIFORMAPI_KEY;
if (!KEY) throw new Error("Set AIFORMAPI_KEY first.");

async function api(path, options = {}) {
  const res = await fetch(`${BASE}${path}`, {
    ...options,
    headers: {
      Authorization: `Bearer ${KEY}`,
      "Content-Type": "application/json",
      ...options.headers,
    },
  });
  const isJson = (res.headers.get("content-type") || "").includes("json");
  const body = isJson ? await res.json() : await res.text();
  if (!res.ok) {
    const e = body.error || {};
    throw new Error(`${res.status} ${e.code}: ${e.message}`);
  }
  return body;
}

const form = await api("/forms", {
  method: "POST",
  body: JSON.stringify({
    title: "Friday dinner RSVP",
    description: "Tell us if you can come. It takes 20 seconds.",
    fields: [
      { id: "full_name", label: "Your name", type: "short_text", required: true },
      {
        id: "attending",
        label: "Can you come?",
        type: "single_choice",
        required: true,
        options: ["Yes", "No", "Maybe"],
      },
      { id: "guests", label: "How many people are you bringing?", type: "number", min: 0, max: 5 },
    ],
    settings: { agent_fill: true, confirmation_message: "Thanks. See you Friday." },
  }),
});

console.log("Share this link:", form.public_url);

// Read the responses. The list is empty until someone submits the form.
const page = await api(`/forms/${form.id}/responses?format=json`);
for (const row of page.data) {
  console.log(row.submitted_at, row.source, row.answers);
}
