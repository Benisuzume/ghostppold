############################################################
# Dockerfile
############################################################

# Base Image
FROM ubuntu:18.10

############################################################
# Environment Configuration
############################################################

############################################################
# Installation
############################################################

# Install packages. Notes:
#   * git: a git client to check out repositories
ENV PACKAGES="\
  build-essential \
  git \
  libgeoip-dev \
  libgmp-dev \
  zlib1g-dev \
  libbz2-dev \
  libmysqlclient-dev \
  libboost-all-dev \
  gettext-base \
"

# Packages
RUN echo "Installing Packages ..." &&\
	# Update Package List
	apt-get update &&\
	# Package Install [no-cache, because the cache would be within the build - bloating up the file size]
	apt-get install -y $PACKAGES

# Copy Artifacts
ADD rootfs /opt/ghostpp

# Configuration
RUN echo "Configuration ..." &&\
	# GHostPP - Libraries
	mkdir mapcfgs maps replays savegames

# Build CleanUp
RUN echo "CleanUp ..."

############################################################
# Execution
############################################################
CMD [ "/usr/local/bin/ghostpp.sh"]
