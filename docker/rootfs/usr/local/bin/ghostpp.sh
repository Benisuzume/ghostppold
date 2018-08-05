#!/bin/bash

# create environment based configuration
envsubst < /opt/ghostpp/docker.cfg > /opt/ghostpp/ghost.cfg

# start bot
/opt/ghostpp/ghost++
