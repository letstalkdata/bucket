#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
# Create profiles for compute nodes
lxc profile copy default tiny
lxc profile copy default mini
lxc profile copy default mini2
lxc profile copy default regular
lxc profile copy default regular2
lxc profile copy default heavy
lxc profile copy default heavy2
lxc profile copy default heavy3
lxc profile edit tiny < ../profile/tiny-profile.yaml
lxc profile edit mini < ../profile/mini-profile.yaml
lxc profile edit mini2 < ../profile/mini2-profile.yaml
lxc profile edit regular < ../profile/regular1-profile.yaml
lxc profile edit regular2 < ../profile/regular2-profile.yaml
lxc profile edit heavy < ../profile/heavy1-profile.yaml
lxc profile edit heavy2 < ../profile/heavy2-profile.yaml
lxc profile edit heavy3 < ../profile/heavy3-profile.yaml
#lxc profile list
echo -e "${CYAN}Bucket profiles created successfully${NC}"