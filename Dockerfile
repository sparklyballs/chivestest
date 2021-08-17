ARG UBUNTU_VER="focal"
FROM ubuntu:${UBUNTU_VER} as packages

# build arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG RELEASE

# environment variables
ENV \
	keys="generate" \
	harvester="false" \
	farmer="false" \
	plots_dir="/plots" \
	farmer_address="null" \
	farmer_port="null" \
	testnet="false" \
	full_node_port="null" \
	TZ="UTC"

# set workdir 
WORKDIR /chives-blockchain

# install dependencies
RUN \
	apt-get update \
	&& apt-get install -y \
	--no-install-recommends \
		bc \
		ca-certificates \
		curl \
		git \
		jq \
		lsb-release \
		sudo \
# cleanup
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# build package
RUN \
	if [ -z ${RELEASE+x} ]; then \
	RELEASE=$(curl -u "${SECRETUSER}:${SECRETPASS}" -sX GET "https://api.github.com/repos/HiveProject2021/chives-blockchain/releases/latest" \
	| jq -r ".tag_name"); \
	fi \
	&& git clone -b ${RELEASE} https://github.com/HiveProject2021/chives-blockchain.git \
		/chives-blockchain \		
	&& sh install.sh \
# cleanup
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# add local files
ADD ./entrypoint.sh entrypoint.sh
ENTRYPOINT ["bash", "./entrypoint.sh"]
