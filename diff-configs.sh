#!/usr/bin/env bash
# Compare configuration files between local ~/.config and fork
# Shows differences for each synced config

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_CONFIG="$HOME/.config"
FORK_DOTS="$SCRIPT_DIR/dots/.config"
CONFIG_FILE="$SCRIPT_DIR/sync-configs.conf"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Read configs from file (skip comments and empty lines)
CONFIGS=()
while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    CONFIGS+=("$line")
done < "$CONFIG_FILE"

echo -e "${BLUE}=== Comparing local config vs fork ===${NC}"
echo "Local:  $LOCAL_CONFIG"
echo "Fork:   $FORK_DOTS"
echo ""
echo "Configs to check: ${#CONFIGS[@]}"
echo ""

TOTAL_DIFFS=0
MISSING_LOCAL=()
MISSING_FORK=()
HAS_DIFF=()

for config in "${CONFIGS[@]}"; do
    LOCAL_PATH="$LOCAL_CONFIG/$config"
    FORK_PATH="$FORK_DOTS/$config"
    
    # Check if both exist
    if [ ! -e "$LOCAL_PATH" ] && [ ! -e "$FORK_PATH" ]; then
        echo -e "${YELLOW}⚠${NC} $config - ${YELLOW}not found in both${NC}"
        continue
    elif [ ! -e "$LOCAL_PATH" ]; then
        echo -e "${RED}✗${NC} $config - ${RED}missing in local${NC}"
        MISSING_LOCAL+=("$config")
        continue
    elif [ ! -e "$FORK_PATH" ]; then
        echo -e "${RED}✗${NC} $config - ${RED}missing in fork${NC}"
        MISSING_FORK+=("$config")
        continue
    fi
    
    # Compare using diff (suppress output, just check exit code)
    if diff -rq "$LOCAL_PATH" "$FORK_PATH" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $config - ${GREEN}identical${NC}"
    else
        echo -e "${BLUE}≠${NC} $config - ${BLUE}has differences${NC}"
        HAS_DIFF+=("$config")
        ((TOTAL_DIFFS++)) || true
        
        # Show file-level diff summary
        echo -e "${YELLOW}  Files with differences:${NC}"
        diff -rq "${DIFF_OPTS[@]}" "$LOCAL_PATH" "$FORK_PATH" 2>/dev/null | grep -E "(differ|Only)" | sed 's|^|    |' || true
    fi
done

# Summary
echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo "Total configs checked: ${#CONFIGS[@]}"
echo "Configs with differences: ${#HAS_DIFF[@]}"
echo "Missing in local: ${#MISSING_LOCAL[@]}"
echo "Missing in fork: ${#MISSING_FORK[@]}"

if [ ${#HAS_DIFF[@]} -gt 0 ]; then
    echo ""
    echo -e "${BLUE}Configs with differences:${NC}"
    for config in "${HAS_DIFF[@]}"; do
        echo "  - $config"
    done
fi

if [ ${#MISSING_LOCAL[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Missing in local:${NC}"
    for config in "${MISSING_LOCAL[@]}"; do
        echo "  - $config"
    done
fi

if [ ${#MISSING_FORK[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Missing in fork:${NC}"
    for config in "${MISSING_FORK[@]}"; do
        echo "  - $config"
    done
fi

# Detailed diff option
if [ ${#HAS_DIFF[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}To see detailed diff for a specific config, run:${NC}"
    echo "  diff -r $LOCAL_CONFIG/<config> $FORK_DOTS/<config>"
    echo ""
    echo -e "${YELLOW}Or use this script with --detail <config> flag${NC}"
fi

# Handle --detail flag
if [ "$1" == "--detail" ] && [ -n "$2" ]; then
    CONFIG_NAME="$2"
    echo ""
    echo -e "${BLUE}=== Detailed diff for: $CONFIG_NAME ===${NC}"
    diff -r "$LOCAL_CONFIG/$CONFIG_NAME" "$FORK_DOTS/$CONFIG_NAME" || true
fi
