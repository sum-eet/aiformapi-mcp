# AI Form API: MCP servers

[AI Form API](https://aiformapi.com) is a forms API and MCP server. Your AI agent creates a form, you share the link, people answer, and the agent reads the answers as JSON or CSV.

This repo holds the connection docs, the `server.json` files for the [official MCP Registry](https://registry.modelcontextprotocol.io) and code examples. The service runs at https://aiformapi.com. This repo has no server code.

- Docs: https://aiformapi.com/docs
- MCP setup page: https://aiformapi.com/docs/mcp
- OpenAPI 3.1 spec: https://aiformapi.com/openapi.json
- Full reference for agents: https://aiformapi.com/llms-full.txt
- Contact: hello@aiformapi.com

## The 2 MCP servers

Both servers use the Streamable HTTP transport.

| Server | URL | Auth | Who uses it |
|---|---|---|---|
| Creator | `https://aiformapi.com/mcp` | `Authorization: Bearer afk_...` | You, the form owner. Create forms and read responses. |
| Fill | `https://aiformapi.com/mcp/fill` | None. The fill code is an argument. | A person who hands a form to their own AI agent. |

Get an API key for the creator server from the dashboard at https://aiformapi.com. See [Authentication](https://aiformapi.com/docs/authentication). The key starts with `afk_`. Keep it out of files you commit.

The fill server needs no login. A visitor presses "Want your AI agent to fill this?" on a public form page and copies a prompt with a one-time fill code. The agent reads the form, asks the person for anything missing, shows all answers, and submits only after the person says yes.

## Which apps work today

| App | Creator server | Fill server |
|---|---|---|
| Claude Code | Yes, with a header | Yes |
| Cursor | Yes, with a header | Yes |
| VS Code | Yes, with a header | Yes |
| Claude Desktop | Yes, through `mcp-remote` with a header | Yes, as a custom connector |
| n8n | Yes, with a header | Yes |
| Claude.ai | Not yet. It needs OAuth, which is planned. | Yes, as a custom connector |
| ChatGPT | Not yet. It needs OAuth, which is planned. | Yes, as a custom connector |

## Connect the creator server

Set your key in your shell first. Use your own key.

```bash
export AIFORMAPI_KEY="afk_paste_your_key_here"
```

### Claude Code

```bash
claude mcp add --transport http aiformapi https://aiformapi.com/mcp \
  --header "Authorization: Bearer $AIFORMAPI_KEY"
```

This stores the key in your local Claude Code config. To keep the key out of a shared file, use a project `.mcp.json` that reads the environment variable ([example](examples/mcp/claude-code.mcp.json)):

```json
{
  "mcpServers": {
    "aiformapi": {
      "type": "http",
      "url": "https://aiformapi.com/mcp",
      "headers": {
        "Authorization": "Bearer ${AIFORMAPI_KEY}"
      }
    }
  }
}
```

Run `/mcp` in Claude Code to see the connection. Claude Code docs: https://code.claude.com/docs/en/mcp

### Cursor

Put this in `.cursor/mcp.json` for one project, or in `~/.cursor/mcp.json` for all projects ([example](examples/mcp/cursor.mcp.json)). Set `AIFORMAPI_KEY` in your shell profile first.

```json
{
  "mcpServers": {
    "aiformapi": {
      "url": "https://aiformapi.com/mcp",
      "headers": {
        "Authorization": "Bearer ${env:AIFORMAPI_KEY}"
      }
    }
  }
}
```

Cursor docs: https://cursor.com/docs/context/mcp

### VS Code

Put this in `.vscode/mcp.json`, or run **MCP: Open User Configuration** for a profile-wide file ([example](examples/mcp/vscode.mcp.json)). VS Code uses the top-level key `servers`, not `mcpServers`. It asks for the key when the server starts for the first time.

```json
{
  "inputs": [
    {
      "type": "promptString",
      "id": "aiformapi-key",
      "description": "AI Form API key",
      "password": true
    }
  ],
  "servers": {
    "aiformapi": {
      "type": "http",
      "url": "https://aiformapi.com/mcp",
      "headers": {
        "Authorization": "Bearer ${input:aiformapi-key}"
      }
    }
  }
}
```

VS Code docs: https://code.visualstudio.com/docs/agents/reference/mcp-configuration

### Claude Desktop (through mcp-remote)

Claude Desktop reads local servers from `claude_desktop_config.json`. The [`mcp-remote`](https://github.com/geelen/mcp-remote) package turns a remote server with a header into a local one. You need Node.js.

1. Open the file. On macOS it is `~/Library/Application Support/Claude/claude_desktop_config.json`. On Windows it is `%APPDATA%\Claude\claude_desktop_config.json`. You can also open it from Settings, Developer, Edit Config.
2. Add the server ([example](examples/mcp/claude-desktop.config.json)). The space of `Bearer ` lives in the environment variable, not in `args`, so the entry also works on Windows.

```json
{
  "mcpServers": {
    "aiformapi": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://aiformapi.com/mcp",
        "--header",
        "Authorization:${AIFORMAPI_AUTH}"
      ],
      "env": {
        "AIFORMAPI_AUTH": "Bearer afk_your_key_here"
      }
    }
  }
}
```

3. Quit Claude Desktop fully and open it again.

This file holds your key in plain text. Do not share it or commit it.

### n8n

Use the **MCP Client Tool** node and connect it to an AI Agent node. Set the endpoint to `https://aiformapi.com/mcp`, the transport to HTTP Streamable, and the authentication to Bearer with your key. Field names change between n8n versions, so check yours. n8n docs: https://docs.n8n.io/integrations/builtin/cluster-nodes/sub-nodes/n8n-nodes-langchain.toolmcp/

## Connect the fill server

The fill server has no login, so it needs no header.

### Claude.ai and Claude Desktop

Add it as a custom connector.

1. Go to Customize, then Connectors.
2. Press **+ Add**, then **Add custom connector**.
3. Enter a name, for example `AI Form API fill`.
4. Enter the URL `https://aiformapi.com/mcp/fill`.
5. Choose **No sign in** for authentication.
6. Press **Add**.
7. In a chat, press **+**, then **Connectors**, and switch the connector on.

Anthropic says custom connectors are available on Free, Pro, Max, Team and Enterprise plans, and that Free plans have a limit of 1 custom connector. See https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp

### ChatGPT

ChatGPT adds remote servers as connectors in developer mode. Create a connector, enter the URL `https://aiformapi.com/mcp/fill`, and choose no authentication. Menu names and plan availability change often. Check OpenAI's current help page for the exact steps.

### Claude Code, Cursor, VS Code and n8n

Add it the same way as the creator server, without the header.

```bash
claude mcp add --transport http aiformapi-fill https://aiformapi.com/mcp/fill
```

```json
{
  "mcpServers": {
    "aiformapi-fill": {
      "url": "https://aiformapi.com/mcp/fill"
    }
  }
}
```

## Tools

### Creator server (`/mcp`)

The tools return rows and form definitions. They do not summarise. Your own model reads the rows and writes the summary.

| Tool | Arguments | Same as |
|---|---|---|
| `create_form` | `title`, `description` (optional), `fields`, `settings` (optional) | `POST /v1/forms` |
| `list_forms` | `limit` (optional), `cursor` (optional) | `GET /v1/forms` |
| `get_form` | `form_id` | `GET /v1/forms/{id}` |
| `update_form` | `form_id`, and any of `title`, `description`, `fields`, `settings` | `PATCH /v1/forms/{id}` |
| `close_form` | `form_id` | `POST /v1/forms/{id}/close` |
| `reopen_form` | `form_id` | `POST /v1/forms/{id}/reopen` |
| `get_responses` | `form_id`, and any of `format`, `since`, `limit`, `cursor`, `order` | `GET /v1/forms/{id}/responses` |
| `add_webhook` | `form_id`, `url` | `POST /v1/forms/{id}/webhooks` |
| `get_usage` | none | `GET /v1/usage` |

The arguments match the body or query of the REST call. The form id is the argument `form_id`, not a path part. `format` is `json` (default) or `csv`. `order` is `asc` or `desc`. In `update_form`, `fields` replaces the whole list and `settings` merges key by key. There is no tool to delete a form. Use the REST API or the dashboard.

A failed call returns a tool error with the same JSON error body as the REST API. See [API error codes](https://aiformapi.com/docs/errors).

### Fill server (`/mcp/fill`)

| Tool | Arguments | Does |
|---|---|---|
| `get_fill_form` | `fill_token` | Returns the form and instructions. Does not use up the code. |
| `submit_fill` | `fill_token`, `answers` | Stores the answers. `answers` maps field ids to values. |

`fill_token` is the code from the prompt. It starts with `fil_`. A successful `submit_fill` returns `response_id`, `receipt` and `submitted_at`.

## Limits on the free plan

| Scope | Free plan |
|---|---|
| API key (REST and creator MCP together) | 30 requests per minute, 1,000 per day |
| Open forms per account | 3 |
| Responses per account per calendar month (UTC), all sources | 100 |
| Fill MCP calls, per IP | 20 per minute |
| One fill code | 1 successful use, 60 minutes lifetime, 5 POST attempts |
| `POST /v1/fill/{token}`, per IP | 10 per minute |
| Webhooks per form | 3 |
| Request body size | 64 KB |

Creator MCP calls count against the same limit as REST calls for the key. The API, MCP, agent fill and CSV export are included in the free plan. A 429 response has a `Retry-After` header. The full table, with the `RateLimit-*` headers, is at https://aiformapi.com/docs/rate-limits

## Examples

The [`examples/`](examples) folder has copy-paste code from the [quickstart](https://aiformapi.com/docs/quickstart). Each example creates a small RSVP form and reads the responses back.

- [`examples/curl/create-and-read.sh`](examples/curl/create-and-read.sh)
- [`examples/javascript/create-and-read.mjs`](examples/javascript/create-and-read.mjs) (Node 18 or newer, `fetch`)
- [`examples/python/create_and_read.py`](examples/python/create_and_read.py) (`requests`)
- [`examples/mcp/`](examples/mcp): the client config files from this README

## MCP Registry

The two servers are listed in the official MCP Registry with the `server.json` files in this repo:

- [`server.json`](server.json): creator server, `io.github.sum-eet/aiformapi`
- [`server-fill.json`](server-fill.json): fill server, `io.github.sum-eet/aiformapi-fill`

## License

The docs and examples in this repo use the [MIT license](LICENSE). AI Form API is a hosted service. This license does not cover the service.
