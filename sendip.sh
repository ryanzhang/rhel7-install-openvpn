#!/bin/bash
#Send your ip to gist
#It will create a new gist everytime you run this script
#How to get your token
#github->setting->developer setting->Personal access token
token=your_github_token
generate_post_data()
{
  cat <<EOF
{"description": "Created via API", "public": "true", "files": {"$(hostname)": { "content":"$(cat /sys/class/net/nm-bridge/address) $(hostname -I)"}}}
EOF
}
generate_post_data
curl -H "Authorization: token $token" --data "$(generate_post_data)" https://api.github.com/gists
