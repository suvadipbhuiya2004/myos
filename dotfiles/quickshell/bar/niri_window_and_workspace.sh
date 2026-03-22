
#!/usr/bin/env bash

# Function to gather your 3 data points and print them as a single JSON object
print_state() {
    # Fetch raw data to ensure consistency
    local workspaces_json=$(niri msg -j workspaces)
    local windows_json=$(niri msg -j windows)

    # 1. Total active workspaces
    local ws_count=$(echo "$workspaces_json" | jq length)

    # 2. Current active workspace (returns name, or index if unnamed)
    local active_ws=$(echo "$workspaces_json" | jq -r '.[] | select(.is_focused == true) | if .name != null then .name else .idx end')

    # 3. Programs per workspace (Returns array: [{"workspace_id": 1, "count": 3}, ...])
    local windows_per_ws=$(echo "$windows_json" | jq -c 'group_by(.workspace_id) | map({workspace_id: .[0].workspace_id, count: length})')

    # Construct the final JSON payload for Quickshell
    
    jq -nc --unbuffered \
       --arg ws_count "$ws_count" \
       --arg active_ws "$active_ws" \
       --argjson windows_per_ws "$windows_per_ws" \
       '{
          total_workspaces: ($ws_count | tonumber),
          active_workspace: $active_ws,
          windows_per_workspace: $windows_per_ws
        }'
}

# Print the initial state the moment the script starts
print_state

# # Listen to the event stream indefinitely
# niri msg -j event-stream | while read -r event; do
#     # Filter the stream: Only update the bar if workspaces or windows actually changed
#     if [[ "$event" == *"WorkspacesChanged"* ]] || \
#        [[ "$event" == *"WorkspaceActivated"* ]] || \
#        [[ "$event" == *"WindowsChanged"* ]]; then
       
#         print_state
        
#     fi
# done
#
#

# Listen to the event stream indefinitely
niri msg -j event-stream | while read -r event; do
    # Filter the stream: Catch ANY event involving a Window or Workspace
    if [[ "$event" == *"Workspace"* ]] || [[ "$event" == *"Window"* ]]; then
       
        print_state
        
    fi
done
