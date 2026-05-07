#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
VERBOSE=false

for arg in "$@"; do
  case "${arg}" in
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
    *)
      echo "Usage: $0 [--dry-run] [--verbose]"
      exit 1
      ;;
  esac
done

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

declare -a TARGETS=()
declare -a SKIPPED=()
FIND_RESULTS_FILE="$(mktemp)"
trap 'rm -f "${FIND_RESULTS_FILE}"' EXIT

find "${ROOT_DIR}" -type d \( -name ".build" -o -name ".swiftpm" \) -print0 > "${FIND_RESULTS_FILE}"
while IFS= read -r -d '' dir; do
  rel_path="${dir#"${ROOT_DIR}/"}"

  # Do not remove directories that contain tracked files.
  if [[ -n "$(git -C "${ROOT_DIR}" ls-files -- "${rel_path}")" ]]; then
    SKIPPED+=("${dir}")
    continue
  fi

  TARGETS+=("${dir}")
done < "${FIND_RESULTS_FILE}"

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  if [[ "${VERBOSE}" == true ]]; then
    echo "No .build or .swiftpm directories found under: ${ROOT_DIR}"
  fi
  exit 0
fi

if [[ "${VERBOSE}" == true ]]; then
  echo "Found ${#TARGETS[@]} removable directories under: ${ROOT_DIR}"
  for dir in "${TARGETS[@]}"; do
    echo " - ${dir}"
  done
  if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    echo "Skipped ${#SKIPPED[@]} directories containing tracked files:"
    for dir in "${SKIPPED[@]}"; do
      echo " - ${dir}"
    done
  fi
fi

if [[ "${DRY_RUN}" == true ]]; then
  if [[ "${VERBOSE}" == true ]]; then
    echo "Dry run completed. No directories were removed."
  fi
  exit 0
fi

for dir in "${TARGETS[@]}"; do
  rm -rf "${dir}"
done

if [[ "${VERBOSE}" == true ]]; then
  echo "Removed ${#TARGETS[@]} directories."
fi
