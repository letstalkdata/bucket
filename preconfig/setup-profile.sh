#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
## Setup Profile
lxc profile show default > $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '/config/d' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '/description/d' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i 's/name: default/name: <name>/' $BUCKET_HOME/preconfig/profile-fixed.sh
#
sed -i '1s/^/description: LXD profile for <name> bucket\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '1s/^/  security.privileged: "true"\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '1s/^/  security.nesting: "true"\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '1s/^/  raw.lxc: "lxc.apparmor.profile=unconfined\\nlxc.cap.drop= \\nlxc.cgroup.devices.allow=a\\nlxc.mount.auto=proc:rw sys:rw"\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '1s/^/  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '1s/^/  limits.memory.swap: "false"\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '1s/^/  limits.memory: <mem>\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '1s/^/  limits.cpu: <cpu>\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
sed -i '1s/^/config:\n/' $BUCKET_HOME/preconfig/profile-fixed.sh
echo "fixed profile created.."
#
cpu="1"
mem="1GB"
find1="<name>"
find2="<cpu>"
find3="<mem>"
i=1
for ptype in tiny mini mini2 regular regular2 heavy heavy2 heavy3
do
	name=$ptype;
	case "$ptype" in
		tiny)   cpu="1";
			    mem="1GB";
			    ;;
		mini)   cpu="1";
			    mem="2GB";
			    ;;
        mini2)  cpu="2";
			    mem="2GB";
			    ;;
		regular) cpu="2";
			     mem="4GB";
			    ;;
		regular2) cpu="4";
			      mem="8GB";
			    ;;
		heavy)  cpu="8";
			    mem="16GB";
			    ;;
		heavy2) cpu="8";
			    mem="32GB"
			    ;;
		heavy3) cpu="8";
			    mem="64GB"
			    ;;
		*) exit 1;
	esac
	yaml=""
	yaml=$BUCKET_HOME"/profile/new-"$name"-profile.yaml"
	sed "s/$find1/$name/" $BUCKET_HOME/preconfig/profile-fixed.sh > $yaml
	sed -i "s/$find2/$cpu/" $yaml 
	sed -i "s/$find3/$mem/" $yaml
	#
	lxc profile copy default $name
	#
	lxc profile edit $name < $yaml
	#
	rm -rf $yaml
done
lxc profile list
echo -e "${CYAN}All profiles for bucket created successfully${NC}"