#!/bin/bash


RED='\e[1;31m'
CYAN='\e[1;033;36m'
GREEN='\e[1;033;32m'
NC='\e[0m'

function echo_red() {
      echo -e "${RED}$1 ${NC}"
}

function echo_green() {
      echo -e "${GREEN}$1 ${NC}"
}

function echo_cyan() {
      echo -e "${CYAN}$1 ${NC}"
}