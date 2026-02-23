#!/usr/bin/env bash
set -euo pipefail

# Defaults
DEFAULT_ALLOWED="feat/*,fix/*,chore/*,docs/*,refactor/*,test/*,perf/*"
DEFAULT_EXCLUDE="main,release/*"

# Success and Error Haikus
# shellcheck disable=SC2034
SUCCESS_HAIKUS=(
  "🌸 Quiet roots shelter forgotten branches."
  "🌸 Flowing stream guides each name downstream."
  "🌸 Soft petals fall where the path is clear."
  "🌸 Wind whispers truth through the ancient leaves."
  "🌸 The mountain stands firm in its steady name."
  "🌸 Silver moon reflects a calm, steady flow."
)

# shellcheck disable=SC2034
ERROR_HAIKUS=(
  "👹 Lost branch drifts, no tree remembers it."
  "👹 Oni grins—chaos blooms from broken names."
  "👹 Shadows stretch long over paths unknown."
  "👹 Thunder cracks the sky when a name is lost."
  "👹 Thorns catch the hem of a straying branch."
  "👹 Deep mist hides the path of the wanderer."
)

# Color support
if [[ -t 1 ]]; then
  readonly RED='\033[0;31m'
  readonly GREEN='\033[0;32m'
  readonly YELLOW='\033[0;33m'
  readonly BLUE='\033[0;34m'
  readonly NC='\033[0m'
else
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly BLUE=''
  readonly NC=''
fi

log_ok() { echo -e "${GREEN}[OK]${NC} ✅ $*"; }
log_err() { echo -e "${RED}[ERROR]${NC} ❌ $*" >&2; }
log_fatal() { echo -e "${RED}[FATAL]${NC} ❌ $*" >&2; }

pick_random() {
  local -n arr=$1
  echo "${arr[RANDOM % ${#arr[@]}]}"
}

# Determine the branch name
get_branch_name() {
  local branch="${INPUT_BRANCH_NAME:-}"

  if [[ -z "$branch" ]]; then
    branch="${GITHUB_HEAD_REF:-}"
    if [[ -z "$branch" && -n "${GITHUB_REF:-}" ]]; then
      branch="${GITHUB_REF#refs/heads/}"
    fi
  fi

  if [[ -z "$branch" ]]; then
    log_fatal "Could not determine branch name."
    pick_random ERROR_HAIKUS >&2
    return 1
  fi

  echo "$branch"
}

# Convert CSV string to array
csv_to_array() {
  local csv="${1-}"
  local IFS=',' parts=()
  read -r -a parts <<< "$csv"
  local out=()
  for tok in "${parts[@]}"; do
    # Trim whitespace
    tok="${tok#"${tok%%[![:space:]]*}"}"
    tok="${tok%"${tok##*[![:space:]]}"}"
    [[ -n "$tok" ]] && out+=("$tok")
  done
  printf '%s\0' "${out[@]}"
}

glob_match_any() {
  local name="$1"
  shift
  for pat in "$@"; do
    # shellcheck disable=SC2053
    [[ "$name" == $pat ]] && return 0
  done
  return 1
}

validate_branch() {
  local branch="$1"
  shift

  local -a exclude=()
  local -a allowed=()
  local parsing_allowed=0

  for arg in "$@"; do
    if [[ "$arg" == "--allowed" ]]; then
      parsing_allowed=1
      continue
    fi
    if [[ $parsing_allowed -eq 0 ]]; then
      exclude+=("$arg")
    else
      allowed+=("$arg")
    fi
  done

  if glob_match_any "$branch" "${exclude[@]}"; then
    log_ok "Branch '${BLUE}$branch${NC}' is excluded from checks."
    pick_random SUCCESS_HAIKUS
    return 0
  fi

  if glob_match_any "$branch" "${allowed[@]}"; then
    log_ok "Branch '${BLUE}$branch${NC}' matches an allowed pattern."
    pick_random SUCCESS_HAIKUS
    return 0
  fi

  log_err "Invalid branch name: ${BLUE}$branch${NC}"
  echo -e "   Must match one of: ${YELLOW}${allowed[*]}${NC}" >&2
  pick_random ERROR_HAIKUS >&2
  return 1
}

main() {
  local branch
  branch=$(get_branch_name) || exit 1

  local -a exclude=()
  local -a allowed=()

  mapfile -d '' -t exclude < <(csv_to_array "${INPUT_EXCLUDE:-$DEFAULT_EXCLUDE}")
  mapfile -d '' -t allowed < <(csv_to_array "${INPUT_ALLOWED:-$DEFAULT_ALLOWED}")

  validate_branch "$branch" "${exclude[@]}" "--allowed" "${allowed[@]}" || exit 1
}

main
