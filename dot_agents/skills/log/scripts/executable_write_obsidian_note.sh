#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"
VAULT_ROOT="${VAULT_ROOT:-/home/aric/Documents/sourdough}"
LOG_FILE_NAME="${LOG_FILE_NAME:-session_log.md}"
DEFAULT_OUTPUT_LOG_FILE="session_log.md"
OUTPUT_LOG_FILE_INPUT="${OUTPUT_LOG_FILE:-}"
OUTPUT_LOG_FILE_IS_DEFAULT=0

if [[ -n "$OUTPUT_LOG_FILE_INPUT" ]]; then
  OUTPUT_LOG_FILE="$OUTPUT_LOG_FILE_INPUT"
else
  OUTPUT_LOG_FILE="$DEFAULT_OUTPUT_LOG_FILE"
  OUTPUT_LOG_FILE_IS_DEFAULT=1
fi

AUTO_BRANCH_SCOPED_OUTPUT=0
TAGS="${TAGS:-#codex #session-log #progress}"
NOTE_PREFIX="${NOTE_PREFIX:-Session Log}"
MAX_LINES="${MAX_LINES:-12}"

usage() {
  cat <<'USAGE'
Usage: write_obsidian_note.sh [options]

Append a timestamped entry to one Obsidian session log file.

Options:
  --source-dir <path>   Directory containing the source log file
  --vault-root <path>   Obsidian vault root directory
  --log-file <path>     Log file path (relative to --source-dir by default)
  --output-log-file <path>
                       Output log file path (relative to --vault-root by default).
                       If omitted: session_logs/<repo>/<branch>.md in git repos,
                       otherwise session_log.md.
  --tags <string>       Space-separated tags for the note footer
  --prefix <string>     Top-level note title (default: Session Log)
  --max-lines <n>       Max extracted lines per section (default: 12)
  -h, --help            Show this help

Environment defaults:
  SOURCE_DIR, VAULT_ROOT, LOG_FILE_NAME, OUTPUT_LOG_FILE, TAGS, NOTE_PREFIX, MAX_LINES
USAGE
}

fail() {
  echo "[ERROR] $*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --source-dir)
      SOURCE_DIR="${2:-}"
      shift 2
      ;;
    --vault-root)
      VAULT_ROOT="${2:-}"
      shift 2
      ;;
    --log-file)
      LOG_FILE_NAME="${2:-}"
      shift 2
      ;;
    --output-log-file)
      OUTPUT_LOG_FILE="${2:-}"
      OUTPUT_LOG_FILE_IS_DEFAULT=0
      shift 2
      ;;
    --tags)
      TAGS="${2:-}"
      shift 2
      ;;
    --prefix)
      NOTE_PREFIX="${2:-}"
      shift 2
      ;;
    --max-lines)
      MAX_LINES="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

sanitize_segment() {
  local raw="$1"
  local clean

  clean="$(printf '%s' "$raw" | sed -E 's#[^A-Za-z0-9._-]+#-#g; s/^-+//; s/-+$//; s/-{2,}/-/g')"

  if [[ -z "$clean" ]]; then
    clean="unknown"
  fi

  printf '%s' "$clean"
}

GIT_REPO_NAME=""
GIT_BRANCH=""

resolve_git_context() {
  local source_dir="$1"
  local repo_root
  local branch_name
  local short_sha

  repo_root="$(git -C "$source_dir" rev-parse --show-toplevel 2>/dev/null || true)"

  if [[ -z "$repo_root" ]]; then
    return 1
  fi

  GIT_REPO_NAME="$(basename "$repo_root")"
  branch_name="$(git -C "$source_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

  if [[ -z "$branch_name" || "$branch_name" == "HEAD" ]]; then
    short_sha="$(git -C "$source_dir" rev-parse --short HEAD 2>/dev/null || true)"
    if [[ -n "$short_sha" ]]; then
      branch_name="detached-$short_sha"
    else
      branch_name="detached"
    fi
  fi

  GIT_BRANCH="$branch_name"
  return 0
}

[[ -n "$SOURCE_DIR" ]] || fail "SOURCE_DIR cannot be empty"
[[ -n "$VAULT_ROOT" ]] || fail "VAULT_ROOT cannot be empty"
[[ -n "$LOG_FILE_NAME" ]] || fail "LOG_FILE_NAME cannot be empty"
[[ -n "$OUTPUT_LOG_FILE" ]] || fail "OUTPUT_LOG_FILE cannot be empty"
[[ -d "$SOURCE_DIR" ]] || fail "SOURCE_DIR does not exist: $SOURCE_DIR"
[[ -d "$VAULT_ROOT" ]] || fail "VAULT_ROOT does not exist: $VAULT_ROOT"
[[ "$MAX_LINES" =~ ^[0-9]+$ ]] || fail "MAX_LINES must be an integer"

resolve_git_context "$SOURCE_DIR" || true

if [[ "$OUTPUT_LOG_FILE_IS_DEFAULT" -eq 1 && -n "$GIT_REPO_NAME" ]]; then
  OUTPUT_LOG_FILE="session_logs/$(sanitize_segment "$GIT_REPO_NAME")/$(sanitize_segment "$GIT_BRANCH").md"
  AUTO_BRANCH_SCOPED_OUTPUT=1
fi

if [[ "$LOG_FILE_NAME" = /* ]]; then
  LOG_FILE="$LOG_FILE_NAME"
else
  LOG_FILE="$SOURCE_DIR/$LOG_FILE_NAME"
fi

if [[ "$LOG_FILE" == "$SOURCE_DIR/"* ]]; then
  LOG_FILE_LABEL="${LOG_FILE#"$SOURCE_DIR/"}"
else
  LOG_FILE_LABEL="$LOG_FILE"
fi

if [[ "$OUTPUT_LOG_FILE" = /* ]]; then
  NOTE_PATH="$OUTPUT_LOG_FILE"
else
  NOTE_PATH="$VAULT_ROOT/$OUTPUT_LOG_FILE"
fi

[[ -d "$NOTE_PATH" ]] && fail "OUTPUT_LOG_FILE points to a directory: $NOTE_PATH"

NOTE_DIR="$(dirname "$NOTE_PATH")"
mkdir -p "$NOTE_DIR"

has_file() {
  local file="$1"
  [[ -f "$file" && -s "$file" ]]
}

trim_non_empty() {
  sed '/^[[:space:]]*$/d' "$1"
}

collect_lines() {
  local file="$1"
  local limit="$2"
  local matcher="$3"

  if ! has_file "$file"; then
    return 0
  fi

  if [[ -n "$matcher" ]]; then
    grep -E -i "$matcher" "$file" 2>/dev/null | sed 's/[[:space:]]*$//' | sed '/^[[:space:]]*$/d' | head -n "$limit" || true
  else
    trim_non_empty "$file" | head -n "$limit" || true
  fi
}

collect_highlights() {
  local file="$1"
  local limit="$2"

  if ! has_file "$file"; then
    return 0
  fi

  local picked
  picked="$({
    grep -E '^[[:space:]]*(#{1,6}[[:space:]]+|[-*][[:space:]]+|[0-9]+[.)][[:space:]]+|-[[:space:]]*\[[ xX]\][[:space:]]+)' "$file" 2>/dev/null || true
  } | sed 's/^[[:space:]]*//' | head -n "$limit")"

  if [[ -n "$picked" ]]; then
    printf '%s\n' "$picked"
  else
    trim_non_empty "$file" | head -n "$limit" || true
  fi
}

collect_section() {
  local file="$1"
  local limit="$2"
  local section_pattern="$3"

  if ! has_file "$file"; then
    return 0
  fi

  awk -v limit="$limit" -v section_pattern="$section_pattern" '
    BEGIN {
      in_section = 0
      count = 0
    }

    /^[[:space:]]*#{1,6}[[:space:]]+/ {
      heading = $0
      sub(/^[[:space:]]*#{1,6}[[:space:]]+/, "", heading)
      heading = tolower(heading)

      if (in_section) {
        exit
      }

      if (heading ~ section_pattern) {
        in_section = 1
        next
      }
    }

    in_section {
      line = $0
      sub(/[[:space:]]+$/, "", line)
      if (line ~ /^[[:space:]]*$/) {
        next
      }
      print line
      count++
      if (count >= limit) {
        exit
      }
    }
  ' "$file"
}

print_bullets() {
  local lines="$1"

  if [[ -z "${lines//[[:space:]]/}" ]]; then
    echo "- None noted."
    return
  fi

  while IFS= read -r line; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    local clean
    clean="$(printf '%s' "$line" | sed -E 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^-[[:space:]]*\[[ xX]\][[:space:]]+//; s/^[-*][[:space:]]+//; s/^[0-9]+[.)][[:space:]]+//; s/^#+[[:space:]]+//')"
    [[ -z "$clean" ]] && continue
    printf -- '- %s\n' "$clean"
  done <<< "$lines"
}

source_status() {
  local file="$1"
  local label="$2"

  if has_file "$file"; then
    local lines
    lines="$(wc -l < "$file" | tr -d '[:space:]')"
    printf -- '- `%s`: found (%s lines)\n' "$label" "$lines"
  elif [[ -f "$file" ]]; then
    printf -- '- `%s`: found (empty)\n' "$label"
  else
    printf -- '- `%s`: not found\n' "$label"
  fi
}

summary_lines="$(collect_highlights "$LOG_FILE" "$MAX_LINES")"

findings_lines="$(collect_section "$LOG_FILE" "$MAX_LINES" 'findings|discoveries|notes')"

if [[ -z "${findings_lines//[[:space:]]/}" ]]; then
  findings_lines="$(collect_lines "$LOG_FILE" "$MAX_LINES" 'finding|discovered|learned|note')"
fi

progress_lines="$(collect_section "$LOG_FILE" "$MAX_LINES" 'progress|completed|done|implementation|shipped')"

if [[ -z "${progress_lines//[[:space:]]/}" ]]; then
  progress_lines="$(collect_lines "$LOG_FILE" "$MAX_LINES" '(^[[:space:]]*-[[:space:]]*\[[xX]\])|completed|done|implemented|fixed|verified|passed|merged')"
fi

blockers_lines="$(collect_section "$LOG_FILE" "$MAX_LINES" 'blockers?|risks?|issues?|problems?')"

if [[ -z "${blockers_lines//[[:space:]]/}" ]]; then
  blockers_lines="$(collect_lines "$LOG_FILE" "$MAX_LINES" 'blocker|blocked|risk|issue|problem|pending|todo|stuck')"
fi

next_steps_lines="$(collect_section "$LOG_FILE" "$MAX_LINES" 'next steps?|todo|action items?|follow.?ups?|remaining')"

if [[ -z "${next_steps_lines//[[:space:]]/}" ]]; then
  next_steps_lines="$(collect_lines "$LOG_FILE" "$MAX_LINES" '(^[[:space:]]*-[[:space:]]*\[[[:space:]]\])|next step|next steps|todo|follow up|follow-up|action item|remaining|pending')"
fi

timestamp="$(date '+%Y-%m-%d %H:%M')"
generated_at="$(date --iso-8601=seconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S%z')"

write_entry() {
  echo "## $timestamp"
  echo
  echo "### Context"
  echo "- Generated at: $generated_at"
  echo "- Source directory: $SOURCE_DIR"
  echo "- Vault root: $VAULT_ROOT"
  echo "- Output note: $NOTE_PATH"

  if [[ -n "$GIT_REPO_NAME" ]]; then
    echo "- Git context: $GIT_REPO_NAME @ $GIT_BRANCH"
  else
    echo "- Git context: none"
  fi

  if [[ "$AUTO_BRANCH_SCOPED_OUTPUT" -eq 1 ]]; then
    echo "- Output scope: branch default"
  fi

  source_status "$LOG_FILE" "$LOG_FILE_LABEL"
  echo
  echo "### Executive Summary"
  print_bullets "$summary_lines"
  echo
  echo "### Findings"
  print_bullets "$findings_lines"
  echo
  echo "### Progress Completed"
  print_bullets "$progress_lines"
  echo
  echo "### Open Blockers/Risks"
  print_bullets "$blockers_lines"
  echo
  echo "### Next Steps"
  print_bullets "$next_steps_lines"
  echo
  echo "### Tags"
  echo "$TAGS"
}

if [[ -f "$NOTE_PATH" && -s "$NOTE_PATH" ]]; then
  {
    echo
    echo "---"
    echo
    write_entry
  } >> "$NOTE_PATH"
else
  {
    echo "# $NOTE_PREFIX"
    echo
    write_entry
  } > "$NOTE_PATH"
fi

echo "[OK] Updated log: $NOTE_PATH"
