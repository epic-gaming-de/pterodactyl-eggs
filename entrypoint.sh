#!/bin/bash
sleep 2

# Get Docker Variables
SRCDS_APPID=$(eval echo "$SRCDS_APPID")
HOME=/home/container

"$HOME"/steamcmd/steamcmd.sh +login anonymous +force_install_dir "$HOME" +app_update "$SRCDS_APPID" +quit

# Get all other Docker Variables
GIT_DETAILS=$(eval echo "$GIT_DETAILS") #https://user:passwd@url

if [ ! -z "$GIT_DETAILS" ]; then
	GIT_BRANCHES_ALL=$(eval echo "$GIT_BRANCHES") #branch1,branch2,...
	GIT_BRANCHES=$( cut -d ',' -f 2- <<< "$GIT_BRANCHES_ALL" ) 	#branch2,...
	GIT_BASE_BRANCH=$( cut -d ',' -f 1- <<< "$GIT_BRANCHES_ALL" ) #branch1

	if [ ! -d ".git" ]; then
		git clone "$GIT_DETAILS" "$GIT_BASE_BRANCH" . -q
	else
		git fetch origin
		git reset --hard
	fi

	IFS=',' read -ra ADDR <<< "$GIT_BRANCHES"
	for i in "${ADDR[@]}"; do
		git merge origin/"$i" --allow-unrelated-histories
	done
fi

cd "$HOME" || exit

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Replace Startup Variables
MODIFIED_STARTUP=$(eval echo $(echo "$STARTUP" | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# Run the Server
${MODIFIED_STARTUP}