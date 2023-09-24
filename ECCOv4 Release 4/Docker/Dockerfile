FROM debian:latest

RUN ["/bin/bash", "-c", "echo I am using bash"]
SHELL ["/bin/bash", "-c"]

ARG CHIP_ARCT=x86_64

USER root

ENV mainpath ./
RUN echo ${mainpath}

RUN mkdir -p ${mainpath}


# install libraries as root user
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get install -y --no-install-recommends vim && \
    apt-get install -y --no-install-recommends less && \
    apt-get install -y --no-install-recommends git && \
    apt-get install -y --no-install-recommends wget && \
    apt-get install -y --no-install-recommends unzip && \
    apt-get install -y --no-install-recommends ca-certificates && \
    apt-get install -y --no-install-recommends gfortran && \
    apt-get install -y --no-install-recommends gnuplot && \
    apt-get install -y --no-install-recommends openmpi-bin && \
    apt-get install -y --no-install-recommends openmpi-doc && \
    apt-get install -y --no-install-recommends libopenmpi-dev && \
    apt-get install -y --no-install-recommends mpich && \
    apt-get install -y --no-install-recommends libnetcdf-dev && \
    apt-get install -y --no-install-recommends libnetcdff-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update
RUN update-ca-certificates

# add a user called 'ecco'
RUN useradd -ms /bin/bash ecco
USER ecco 
ENV USER_HOME_DIR /home/ecco
WORKDIR /home/ecco

# copy local directory 'src' to the docker image /home/ecco/docker_src
COPY --chown=ecco:users ./src ${USER_HOME_DIR}/docker_src

# set environment variables for compiling MITgcm
ENV MPI_INC_DIR /usr/lib/${CHIP_ARCT}-linux-gnu/openmpi/include
ENV ROOTDIR /home/ecco/MITgcm

# download the mitgcm and ecco configuration files
RUN cd ${USER_HOME_DIR}
RUN ${USER_HOME_DIR}/docker_src/get_MITgcm_ECCO.sh
