#!/bin/bash

# create environment based configuration
envsubst < docker.cfg > ghost.cfg

# start bot
/opt/ghostpp/ghost++
