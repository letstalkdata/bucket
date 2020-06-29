#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_create_node(){
    # $namespace $nodecount $profile $os $osv $withClient $withVolume $volumeGB
    nsName=$1
    shift
    nodecount=$1
    shift
    profile=$1
    shift
    os=$1
    shift
    osv=$1
    shift
    withClient=$1
    shift
    withVolume=$1
    shift
    volumeGB=$1
    #
    nodeTemplate="sys-client-v1"
    #
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Creating provided namespace.${NC}";
        echo $nsName >> db/ns.csv
        echo -e "${CYAN}New namespace ${GREEN}[$nsName]${CYAN} created ${NC}"   
    fi
    check2=$(case $profile in tiny|mini|regular1|regular2|heavy1|heavy2|heavy3) echo yes;; *)  echo no;; esac)
    if [[ $check2 == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given profile. Valid bucket profiles are tiny, mini, regular1, regular2, heavy1, heavy2, heavy3${NC}" ;
        exit 1;
    fi
    check3=$(case $os in centos|ubuntu) echo yes;; *)  echo no;; esac)
    if [[ $check3 == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given os type. Valid os type are centos and ubuntu${NC}" ;
        exit 1;
    fi
    if (( $nodecount <= 0 )); then
        nodecount=1
        echo -e "${CYAN}Node Count Default is set to ${GREEN}[1]${CYAN}${NC}"
    fi
    for (( c=1; c<=$nodecount; c++ ))
    do
        nName=$nsName"-node"$c
        imgName=""
        cnt=0;
        if [[ $os == "centos" ]]; then 
            check4=$(case $osv in 6|7|8) echo yes;; *)  echo no;; esac)
            if [[ $check4 == "no" ]]; then 
                echo -e "${RED}Cannot proceed with given os version. Valid os version for [centos] are 6, 7 and 8${NC}" ;
                exit 1;
            fi
            lxc launch images:centos/$osv $nName --profile $profile
            sleep 5s
            cat preconfig/nodeInit.sh | lxc exec $nName bash
            if (( $withVolume > 0 )); then
                echo -e "${CYAN}Setting up loopback device...${NC}"
                #
                cat preconfig/volumeInit.sh | lxc exec $nName bash
                #
                ldName=$(sudo losetup -f)
                ldNo=$(echo $ldName | sed 's/\/dev\/loop//') 
                imgName="loopDevice/loop-"$ldNo".img"
                volumeMB=$(($volumeGB * 1000))
                cnt=$(($volumeMB / 100))
                dd if=/dev/zero of=$imgName bs=100M count=$cnt
                ldDevice="/dev/loop"$ldNo
                cmd1="sudo mknod -m 660 $ldDevice b 7 $ldNo"
                eval $cmd1
                sudo losetup -fP $imgName
                dvcName="ldDisk1-"$ldNo
                lxc config device add $nName $dvcName unix-block source=$ldDevice
                #
                mntLoc="/mnt/dvc1"
                ldDeviceesc=$(echo $ldDevice | sed 's_/_\\/_g')
                mntLocesc=$(echo $mntLoc | sed 's_/_\\/_g')
                find1="<device>"
                find2="<mountLocation>"
                #
                cat template/mount.sh > loopDevice/mount.sh
                sed -i "s/<device>/$ldDeviceesc/g" loopDevice/mount.sh
                sed -i "s/<mountLocation>/$mntLocesc/g" loopDevice/mount.sh
                #
                #cat loopDevice/mount.sh | lxc exec $nName bash
            fi
        fi
        if [[ $os == "ubuntu" ]]; then 
            check4=$(case $osv in 16.04|18.04|19.04) echo yes;; *)  echo no;; esac)
            if [[ $check4 == "no" ]]; then 
                echo -e "${RED}Cannot proceed with given os version. Valid os version for [ubuntu] are 16.04, 18.04 and 19.04${NC}" ;
                exit 1;
            fi
            lxc launch ubuntu:$osv $nName --profile $profile
        fi
    done
    clientName=$nsName"-client"
    if (( $withClient > 0 )); then
        lxc file pull sys-dtr/certs/ca.crt configs/ca.crt
        echo -e "${CYAN}Deploying client node to access the nodes.${GREEN}[$clientName]${NC}"
        lxc copy $nodeTemplate $clientName --profile mini
        lxc start $clientName
        lxc file push configs/ca.crt $clientName/etc/docker/certs.d/sys-dtr:5000/ca.crt
        bucket_create_rope $clientName "webssh"
    fi
    #
    #
}
#
bucket_delete_node() {
    #$namespace 
    nsName=$1
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Can not be deleted. exiting...${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "default" ]]; then
        echo -e "${GREEN}[default] ${RED}namespace can not be deleted. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Nothing to do.${NC}";
        exit 0;
    fi
    bucket=$(lxc list $nsName --format csv -c n)
    if [[ ! $bucket ]]; then 
        sed -i "/$nsName/d" ./db/ns.csv
        echo -e "${GREEN}namespace [$nsName] deleted successfully.${NC}" ;
        exit 0;
    fi
    echo -e "${RED}It will delete all buckets inside [$nsName] namespace${NC}" 
    echo -ne "${CYAN}"
    echo "$bucket"
    echo -ne "${NC}"
    read -p "Are you Sure want to continue? (y/n)?" choice
    case "$choice" in 
        y|Y ) 
            echo -e "${CYAN}Deleting all nodes within namespace [$nsName]...${NC}"
            lxc list $nsName --format csv -c n | while read -r line ; do
                ldNo=$(lxc config device list $line | grep ldDisk | cut -d'-' -f2)
                ldDevice="/dev/loop"$ldNo
                img="loopDevice/loop-"$ldNo".img"
                sudo losetup -d $ldDevice
                sudo rm -rf $ldDevice
                rm -rf $img
            done
            lxc delete -f $(lxc list $nsName --format csv -c n)
            sed -i "/$nsName/d" ./db/ns.csv
            echo -e "${GREEN}Namespace [$nsName] for node deployment deleted successfully.${NC}"
            ;;
        n|N ) 
            echo -e "${CYAN}Delete aborted.${NC}"
            exit 1;
            ;;
        * ) 
            echo -e "${RED}Invalid input. Exiting...${NC}"
            exit 1;
            ;;
    esac
}