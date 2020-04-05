# ----------------------------------
# Pterodactyl Epic-Gaming GMOD Dockerfile
# Environment: Source Engine 
# ----------------------------------
FROM        ubuntu:16.04

MAINTAINER  Jakob Mueller <contact@epic-gaming.de>
ENV         DEBIAN_FRONTEND noninteractive
# Install Dependencies
RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y apt-transport-https tar curl git gcc g++ lib32gcc1 lib32tinfo5 lib32z1 lib32stdc++6 libtinfo5:i386 libncurses5:i386 libcurl3-gnutls:i386 iproute2 p7zip p7zip-full p7zip-rar  \
            && useradd -m -d /home/container container
			
RUN			echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list \
			&& curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg \
			&& apt -y update \
			&& apt -y install dotnet-runtime-2.0.5


RUN groupadd -g 998 pterodactyl
RUN useradd -m -u 999 -g 998 -s /bin/bash pterodactyl

USER        container
ENV         HOME /home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]