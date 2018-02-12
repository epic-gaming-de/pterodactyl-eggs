#!/bin/bash
sleep 2

# Get Docker Variables
SRCDS_APPID=$(eval echo "$SRCDS_APPID")
HOME=/home/container

"$HOME"/steamcmd/steamcmd.sh +login anonymous +force_install_dir "$HOME" +app_update "$SRCDS_APPID" +quit

# Get all other Docker Variables
GIT_DETAILS=$(eval echo "$GIT_DETAILS") #https://user:passwd@url
SYMLINKS=$(eval echo "$SYMLINKS") #/linkpath/from/:/shared/linkpath/to,...
TODELETE=$(eval echo "$TODELETE") #file1,file2

cd "$HOME" || exit

IFS=',' read -ra FILESTODELETE <<< "$TODELETE"
for i in "${FILESTODELETE[@]}"; do
	rm -rf "$i"
done

IFS=',' read -ra SYMLINKS_LIST <<< "$SYMLINKS"
for i in "${SYMLINKS_LIST[@]}"; do
	IFS=':' read -ra SYMLINK_PARTS <<< "$i"
	
	if [[ ! ${SYMLINK_PARTS[0]} == "shared"* ]]; then
		if [[ ! ${SYMLINK_PARTS[0]} == "/shared"* ]]; then
			install -D . ${SYMLINK_PARTS[0]} > /dev/null
			rm -rf ${SYMLINK_PARTS[0]}
			ln -s ${SYMLINK_PARTS[1]} ${SYMLINK_PARTS[0]} 
		fi
	fi
done

if [ ! -z "$GIT_DETAILS" ]; then
	GIT_BRANCHES=$(eval echo "$GIT_BRANCHES") #branch1,branch2,...
	#GIT_BASE_BRANCH=$( cut -d ',' -f 1 <<< "$GIT_BRANCHES" ) #branch1
	
    cd "$HOME"/garrysmod || exit

	if [ ! -d ".git" ]; then
	    git config --global user.email "contact@epic-gaming.de"
        git config --global user.name "Epic-Gaming GMOD"

        git init
        git remote add origin "$GIT_DETAILS"
        git fetch --all -q
        git reset --hard -q
	else
		git fetch -q
	fi
	
	GIT_BRANCHNAME="$GIT_BRANCHES" | tr "," "-"
	
	git checkout --orphan "$GIT_BRANCHNAME"
	git reset --hard -q

	IFS=',' read -ra ADDR <<< "$GIT_BRANCHES"
	for i in "${ADDR[@]}"; do
		git merge origin/"$i" --commit --no-edit -q
	done
fi

cd /shared/gmod/resource_syncer/ || exit

dotnet GmodResourceSync.dll "$HOME/garrysmod" "/shared/fastdl" "7z"

cd "$HOME" || exit

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Replace Startup Variables
MODIFIED_STARTUP=$(eval echo $(echo "$STARTUP" | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# Run the Server
${MODIFIED_STARTUP}