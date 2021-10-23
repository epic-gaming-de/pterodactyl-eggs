# ----------------------------------
# Pterodactyl Epic-Gaming GMOD Dockerfile
# Environment: Source Engine 
# ----------------------------------
FROM        ubuntu:20.04

MAINTAINER  Jakob Mueller <contact@epic-gaming.de>
ENV         DEBIAN_FRONTEND noninteractive
# Install Dependencies
RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y apt-transport-https tar curl git gcc g++ lib32gcc1 lib32z1 lib32stdc++6 libtinfo5:i386 libncurses5:i386 libcurl3-gnutls:i386 iproute2 p7zip p7zip-full p7zip-rar wget
			
RUN			wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
			&& dpkg -i packages-microsoft-prod.deb \
            && rm packages-microsoft-prod.deb \
			&& apt -y update \
			&& apt -y install dotnet-runtime-2.1


RUN groupadd -g 998 container
RUN useradd -m -u 999 -g 998 -s /bin/bash container

USER        container
ENV         HOME /home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
