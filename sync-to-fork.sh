#!/usr/bin/env bash
# Sync configuration files FROM local ~/.config TO fork directory
# This script copies only existing config files from your main config to the fork

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_CONFIG="$HOME/.config"
FORK_DOTS="$SCRIPT_DIR/dots/.config"
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

echo -e "${BLUE}=== Syncing FROM local config TO fork ===${NC}"
echo "Source: $LOCAL_CONFIG"
echo "Target: $FORK_DOTS"
echo "Configs to sync: ${#CONFIGS[@]}"
echo ""

# List of config directories/files to sync
# Only configs that exist in LOCAL_CONFIG will be copied

for config in "${CONFIGS[@]}"; do
    if [ -e "$LOCAL_CONFIG/$config" ]; then
        echo -e "${GREEN}✓${NC} Syncing $config..."
        
        # Create backup in fork if target exists
        if [ -e "$FORK_DOTS/$config" ]; then
            echo -e "  ${YELLOW}Creating backup of fork config${NC}"
            cp -r "$FORK_DOTS/$config" "$FORK_DOTS/${config}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        
        # Ensure parent directory exists
        mkdir -p "$FORK_DOTS"
        
        # Copy from local to fork with exclusions
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
            
            rsync -a "${RSYNC_OPTS[@]}" "$LOCAL_CONFIG/$config/" "$FORK_DOTS/$config/"
        else
            cp -r "$LOCAL_CONFIG/$config" "$FORK_DOTS/"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Skipping $config (not found in local config)"
    fi
done

echo ""
echo -e "${GREEN}=== Sync complete! ===${NC}"
echo -e "${BLUE}Don't forget to commit changes in the fork if needed:${NC}"
echo "  cd $SCRIPT_DIR"
echo "  git status"
echo "  git add dots/.config"
echo "  git commit -m 'Update config files'"
