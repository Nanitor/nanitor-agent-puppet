FROM debian:bullseye

ENV PATH="/opt/puppetlabs/bin:$PATH"

RUN apt-get update

# Install program to configure locales
RUN apt-get install -y locales
RUN locale-gen C.UTF-8 && /usr/sbin/update-locale LANG=C.UTF-8
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get install -y \
    curl gnupg lsb-release git vim wget \
    && curl -O https://apt.puppet.com/puppet7-release-bullseye.deb \
    && dpkg -i puppet7-release-bullseye.deb \
    && apt-get update && apt-get install -y puppet-agent \
    && puppet module install puppetlabs-apt \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/puppetlabs/code/environments/production/modules/nanitor_agent
