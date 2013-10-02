#!/bin/bash - 
#===============================================================================
#
#          FILE:  install.sh
# 
#         USAGE:  ./install.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: YOUR NAME (), 
#       COMPANY: 
#       CREATED: 10/02/2013 06:47:20 PM EEST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

perl Makefile.PL
make 
make test
make install
