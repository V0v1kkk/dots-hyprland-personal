#!/usr/bin/env bash
# Sync configuration files FROM fork TO local ~/.config directory
# This script copies config files from the fork to your main config directory

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DOTS="$SCRIPT_DIR/dots/.config"
LOCAL_CONFIG="$HOME/.config"
CONFIG_FILE="$SCRIPT_DIR/sync-configs.conf"
EXCLUDE_FILE="$SCRIPT_DIR/sync-configs.exclude"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Warning: Configuration file not found: $CONFIG_FILE${NC}"
    echo "Using hardcoded config list as fallback"
    CONFIGS=("hypr" "quickshell" "fuzzel" "wlogout" "cava")
else
    # Read configs from file (skip comments and empty lines)
    CONFIGS=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        CONFIGS+=("$line")
    done < "$CONFIG_FILE"
fi

echo -e "${BLUE}=== Syncing FROM fork TO local config ===${NC}"
echo "Source: $FORK_DOTS"
echo "Target: $LOCAL_CONFIG"
echo "Configs to sync: ${#CONFIGS[@]}"
echo ""

# List of config directories/files to sync
# Add paths relative to .config directory

for config in "${CONFIGS[@]}"; do
    if [ -e "$FORK_DOTS/$config" ]; then
        echo -e "${GREEN}✓${NC} Syncing $config..."
        
        # Create backup if target exists
        if [ -e "$LOCAL_CONFIG/$config" ]; then
            echo -e "  ${YELLOW}Creating backup of existing config${NC}"
            cp -r "$LOCAL_CONFIG/$config" "$LOCAL_CONFIG/${config}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        
        # Copy from fork to local with exclusions
        if [ -f "$EXCLUDE_FILE" ]; then
            # Build rsync exclude options
            RSYNC_OPTS=()
            while IFS= read -r pattern; do
                # Skip comments and empty lines
                [[ "$pattern" =~ ^[[:space:]]*# ]] && continue
                [[ -z "${pattern// /}" ]] && continue
                # Apply pattern if it matches current config
                if [[ "$pattern" == "$config"/* || "$pattern" == "$config" ]]; then
                    RSYNC_OPTS+=("--exclude=${pattern#$config/}")
                fi
            done < "$EXCLUDE_FILE"
            
            rsync -a "${RSYNC_OPTS[@]}" "$FORK_DOTS/$config/" "$LOCAL_CONFIG/$config/"
        else
            cp -r "$FORK_DOTS/$config" "$LOCAL_CONFIG/"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Skipping $config (not found in fork)"
    fi
done

echo ""
echo -e "${GREEN}=== Sync complete! ===${NC}"
