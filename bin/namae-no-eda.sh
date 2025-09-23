#!/usr/bin/env bash
set -euo pipefail

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
    echo "❌ Could not determine branch name."
    return 1
  fi

  echo "$branch"
}

# Convert CSV string to array
csv_to_array() {
  local csv="$1"
  IFS=',' read -r -a arr <<< "$csv"
  echo "${arr[@]}"
}

# Check for exact match in array
in_array() {
  local val="$1"
  shift
  for e in "$@"; do
    [[ "$e" == "$val" ]] && return 0
  done
  return 1
}

# Check for glob match in array
glob_match_any() {
  local name="$1"
  shift
  for pat in "$@"; do
    # shellcheck disable=SC2053
    [[ "$name" == $pat ]] && return 0
  done
  return 1
}

# Validate branch (arrays passed as positional arguments)
validate_branch() {
  local branch="$1"
  shift

  local -a exclude=()
  local -a allowed=()
  local i=0

  # First split arguments into exclude and allowed arrays
  for arg in "$@"; do
    if [[ "$arg" == "__SEP__" ]]; then
      i=1
      continue
    fi
    if [[ $i -eq 0 ]]; then
      exclude+=("$arg")
    else
      allowed+=("$arg")
    fi
  done

  # Exclude exact names
  if in_array "$branch" "${exclude[@]}"; then
    echo "✅ Branch '$branch' is excluded from checks."
    return 0
  fi

  # Allowed glob patterns
  if glob_match_any "$branch" "${allowed[@]}"; then
    echo "✅ Branch '$branch' matches an allowed pattern."
    return 0
  fi

  # Invalid branch
  echo "❌ Invalid branch name: $branch"
  echo "   Must match one of the allowed patterns: ${allowed[*]}"
  return 1
}

# Main flow
main() {
  branch=$(get_branch_name) || exit 1

  read -r -a exclude <<< "$(csv_to_array "${INPUT_EXCLUDE:-}")"
  read -r -a allowed <<< "$(csv_to_array "${INPUT_ALLOWED:?Allowed patterns are required}")"

  # Pass arrays as arguments with a separator
  validate_branch "$branch" "${exclude[@]}" "__SEP__" "${allowed[@]}" || exit 1
}

main
