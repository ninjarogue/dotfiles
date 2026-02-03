---
name: hplife-local-dev
description: Start HP LIFE local dev servers and authenticate browser for testing. Use when testing portal, core, or exec apps locally.
---

# HP LIFE Local Dev

Start local dev servers and open authenticated browser sessions.

## Apps

| App | Directory | Port |
|-----|-----------|------|
| portal | `~/dev/dyd/auth-portal.ws/portal` | 3001 |
| core | `~/dev/dyd/core.ws/core` | 3000 |
| exec | `~/dev/dyd/course-exec.ws/exec` | 3000 |

## Start an app

```bash
cd ~/dev/dyd
pm2 start ecosystem.config.js --only <app>
```

## Get auth tokens

```bash
hplife-tokens
# outputs: {"dydBearer":"...","dydBearerRefresh":"..."}
```

## Open authenticated browser

```bash
TOKENS=$(hplife-tokens)
agent-browser open http://localhost:<port>  # add --headed to show browser window
agent-browser cookies set dydBearer "$(echo $TOKENS | jq -r .dydBearer)"
agent-browser cookies set dydBearerRefresh "$(echo $TOKENS | jq -r .dydBearerRefresh)"
agent-browser reload
```

Use `--headed` when visual inspection or debugging is needed. Omit for faster headless automation.

## Stop an app

```bash
pm2 stop <app>
pm2 delete <app>
```

## View logs

```bash
pm2 logs <app>
```

## Testing course execution

To test a course, first get enrolled courses then build the URL.

### Get enrolled courses

```bash
TOKENS=$(hplife-tokens)
TOKEN=$(echo $TOKENS | jq -r .dydBearer)
curl -s "https://api-dev-hplife.dyd.solutions/learning/api/myTraineeCourses" \
  -H "Authorization: Bearer $TOKEN" | jq '.results[] | {id, name}'
```

### Get course lessons/tasks

```bash
curl -s "https://api-dev-hplife.dyd.solutions/learning/api/trainee/courses/{courseId}" \
  -H "Authorization: Bearer $TOKEN" | jq '.lessons[] | {id, name, tasks}'
```

### Course execution URL

```
http://localhost:3000/trainee/courses/{courseId}/lessons/{lessonId}/tasks/{taskId}/{taskType}
```

Task types: `content`, `quiz`, `survey`, `editableform`, `meeting`
