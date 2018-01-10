#!/bin/bash
sleep 2

# Get Docker Variables
SRCDS_APPID=$(eval echo "$SRCDS_APPID")
HOME=/home/container

"$HOME"/steamcmd/steamcmd.sh +login anonymous +force_install_dir "$HOME" +app_update "$SRCDS_APPID" +quit

# Get all other Docker Variables
GIT_DETAILS=$(eval echo "$GIT_DETAILS") #https://user:passwd@url
SYMLINKS=$(eval echo "$SYMLINKS") #/linkpath/from/:/shared/linkpath/to,...

cd "$HOME" || exit

IFS=',' read -ra SYMLINKS_LIST <<< "$SYMLINKS"
for i in "${SYMLINKS_LIST[@]}"; do
	IFS=':' read -ra SYMLINK_PARTS <<< "$i"
	
	if [[ ! "$i[0]" == *"shared"* ]]; then
		if [[ ! "$i[0]" == *"/shared"* ]]; then
			rm -rf "$i[0]"
			ls -s "$i[0]" "$i[1]"
		fi
	fi
done

if [ ! -z "$GIT_DETAILS" ]; then
	GIT_BRANCHES_ALL=$(eval echo "$GIT_BRANCHES") #branch1,branch2,...
	GIT_BRANCHES=$( cut -d ',' -f 2- <<< "$GIT_BRANCHES_ALL" ) 	#branch2,...
	GIT_BASE_BRANCH=$( cut -d ',' -f 1 <<< "$GIT_BRANCHES_ALL" ) #branch1

    cd "$HOME"/garrysmod || exit

	if [ ! -d ".git" ]; then
	    git config --global user.email "egg@nest.com"
        git config --global user.name "Egg"

        git init
        git remote add origin "$GIT_DETAILS"
        git fetch --all -q
        git reset --hard -q # this is required if files in the non-empty directory are in the repo
        git checkout -t origin/"$GIT_BASE_BRANCH" -b origin/"$GIT_BASE_BRANCH" -f
	else
		git fetch origin
		git reset --hard
	fi

	IFS=',' read -ra ADDR <<< "$GIT_BRANCHES"
	for i in "${ADDR[@]}"; do
		git merge origin/"$i" --commit --no-edit
	done
fi

cd "$HOME" || exit

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Replace Startup Variables
MODIFIED_STARTUP=$(eval echo $(echo "$STARTUP" | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# Run the Server
${MODIFIED_STARTUP}