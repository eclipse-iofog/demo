#!/bin/sh

set -e

detect_os(){
  OS=$(uname)
  if [ ! "$OS" = "Linux" ]; then
    echo "Operating System $OS is not supported"
    exit 1
  fi
  if [ -f /etc/os-release ]; then
      . /etc/os-release
      DIST=$NAME
      VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
      DIST=$(lsb_release -si)
      VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
      # For some versions of Debian/Ubuntu without lsb_release command
      . /etc/lsb-release
      DIST=$DISTRIB_ID
      VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
      # Older Debian/Ubuntu/etc.
      DIST=Debian
      VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
      # Older SuSE/etc.
      ...
  elif [ -f /etc/redhat-release ]; then
      # Older Red Hat, CentOS, etc.
      ...
  else
      # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
      DIST=$(uname -s)
      VER=$(uname -r)
  fi
  DIST=$(echo "$DIST" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")
}

install_docker(){
    if [ -z "$(command -v docker)" ]; then
        curl -fsSL https://get.docker.com/ | sh
    fi
    sudo usermod -aG docker $USER
    if [ -z "$(command -v docker)" ]; then
        echo "Failed to install Docker"
        echo "Visit https://docs.docker.com/install/ for instructions on manual installation of Docker"
    fi
}

install_iofogctl(){
    case "$DIST" in
        *ubuntu*|*debian*|*raspbian*)
            curl https://packagecloud.io/install/repositories/iofog/iofogctl/script.deb.sh | sudo bash
            sudo apt-get install iofogctl=2.0.0
            ;;
        *fedora*|*centos*)
            curl https://packagecloud.io/install/repositories/iofog/iofogctl/script.rpm.sh | sudo bash
            sudo yum install iofogctl-2.0.0-1.x86_64
            ;;
        *)
            echo "Failed to install iofogctl"
            echo "Linux distribution $DIST is not supported"
            exit 1
            ;;
    esac
}

detect_os
install_docker
install_iofogctl
