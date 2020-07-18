#!/bin/bash
#
yum -y install which
yum -y install java-1.8.0-openjdk
jloc="/usr/lib/jvm/"
jv=$(ls /usr/lib/jvm/ | grep java | xargs)
jloc=$jloc""$jv"/jre"