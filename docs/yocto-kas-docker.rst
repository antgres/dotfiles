Build kas in a docker container
---------------------------------

# kas-container

For testing purposes the image can either be build locally via

```
# build image with name mytestname
docker build -t mytestname .
docker run -it -t mytestname bash
# run container with root permissions
docker run -it --user root -t mytestname bash
# run image directly from network
docker run --network host --rm -it mytestname bash
```

To test out the new image with a kas build (and use ssh inside the container to
e.g. clone repositories) `ssh-agent` needs to be activated and needs to have
the correct keys loaded.

For example with the following commands:

```
# Check if ssh-agent is running
ssh-agent
# Start an SSH Agent for the current shell
eval $(ssh-agent)
# List fingerprints of currently loaded keys
ssh-add -l
# Add a specific key to the ssh-agent:
ssh-add path/to/private_key
```

If that is done use the following command to run a kas command inside the newly
created image (else as default ghcr.io/siemens/kas/kas:latest will be used)

```
# Note: Easier to just checkout the layers before using it with the container
GITCONFIG_FILE="~/.gitconfig" kas checkout kas.yml
KAS_CONTAINER_IMAGE=mytestname kas-container --ssh-agent shell kas.build.yml
```

**Note:**: The `kas-container` documentation can be [seen
here](https://kas.readthedocs.io/en/latest/userguide/kas-container.html)

**Note:** All available environemnt flags can be [seen
here](https://kas.readthedocs.io/en/latest/command-line.html#environment-variables).

# Manually

Sometimes it is easier to just build everything from scratch.

```
# check out if keys available in container
docker run -it --user root  -v "$SSH_AUTH_SOCK:$SSH_AUTH_SOCK" -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK -v $PWD:/builder -v ~/.gitconfig:/builder/gitconfig -t mytestname ssh-add -l

# go into container as root
docker run -it --user root  -v "$SSH_AUTH_SOCK:$SSH_AUTH_SOCK" -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK -v $PWD:/builder -v ~/.gitconfig:/builder/gitconfig -t mytestname bash

# create known_hosts for later
ssh -T git@github.com # or other server

# create directory and load stuff
mkdir temp_dock && cd temp_dock
cp ../kas.yml .
GITCONFIG_FILE=/builder/gitconfig kas checkout kas.yml

# change all files to builder
cd .. && chown -R 30000:30000 temp_dock

# start as builder
#TODO:: Maybe it`s easier to just use --user $(id -u):$(id -g) and to remove
# all permissions changing commands
docker run -it -v $PWD:/builder -v ~/.gitconfig:/builder/gitconfig -t mytestname bash
```

**Note:** The kas image defines a user `builder` with user:group number
`30000:30000` (only defined in the official
[kas/Dockerfile](https://github.com/siemens/kas/blob/master/Dockerfile).
