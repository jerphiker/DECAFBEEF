#!/bin/bash

export GEM_HOME=~/.gem
export GEM_PATH=$GEM_HOME/bin
export PATH=$GEM_PATH:$PATH

gem1.9.3 install rexical racc

make
