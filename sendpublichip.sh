#!/bin/bash
#Send your ip to gist
#It will update an existing gist when you run this script
#How to get your token
#github->setting->developer setting->Personal access token
token=your_token
gistid=your_gist
generate_post_data()
{
  cat <<EOF
{"description": "Created via API", "public": "true", "files": {"$(hostname)": { "content":"$(curl ifconfig.co)"}}}
EOF
}
generate_post_data
curl -H "Authorization: token $token" --request PATCH --data "$(generate_post_data)" https://api.github.com/gists/$gistid
