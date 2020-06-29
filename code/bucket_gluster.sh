#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_create_gluster() {
    # $namespace $profile $glusterNode $volumeGB $noClient
    nsName=$1
    shift
    profile=$1
    shift
    glusterNode=$1
    shift
    volumeGB=$1
    shift
    noClient=$1
    #
    clientTemplate="sys-client-v1"
    glusterTemplate="sys-gluster"
    #
    if [[ $nsName == "sys" ]]; then
        echo -e "${GREEN}[sys] ${RED}namespace is reserved. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    if [[ $nsName == "default" ]]; then
        echo -e "${RED}Can not create glusterFS cluster in [default] namespace. Please provide another namespace to proceed. exiting...${NC}" ;
        exit 1;
    fi
    check=$(cat db/ns.csv | grep "$nsName")
    if [[ ! $check ]]; then 
        echo -e "${GREEN}Namespace doesnot exists. Creating namespace.${NC}";
        echo $nsName >> db/ns.csv
        echo -e "${CYAN}New namespace ${GREEN}[$nsName]${CYAN} created successfully${NC}"   
    fi
    profileCheck=$(case $profile in tiny|mini|mini2|regular|regular2|heavy|heavy2|heavy3) echo yes;; *)  echo no;; esac)
    if [[ $profileCheck == "no" ]]; then 
        echo -e "${RED}Cannot proceed with given profile. Valid bucket profiles are tiny, [mini], mini2, regular, regular2, heavy, heavy2, heavy3${NC}" ;
        exit 1;
    fi
    #
    if [[ ! $glusterNode ]]; then
        glusterNode=1
        echo -e "${CYAN}Default is set to ${GREEN}[1]${CYAN} glusterFS node${NC}"
    fi
    if (( $glusterNode <= 2 )); then
        glusterNode=3
        echo -e "${CYAN}Default is set to ${GREEN}[1]${CYAN} glusterFS node${NC}"
    fi
    if (( $glusterNode > 9 )); then
        echo -e "${BROWN}As of now we support maximum of ${GREEN}[9]${BROWN} glusterFS nodes only${NC}"
        read -p 'Do you want to continue with 9 glusterFS nodes setup? (y/n) [y]:' ac
        if [[ ! $ac ]]; then
            ac="n"
        fi
        if [ "$ac" == "n" ]; then
            echo -e "${RED}Exiting the setup...${NC}"
            exit 1
        fi
        glusterNode=9
    fi
    #
    start=`date +%s`
    lxc file pull sys-dtr/certs/ca.crt configs/ca.crt
    clientName=$nsName"-client"
    #
    if (( $noClient < 1 )); then
        echo -e "${CYAN}Deploying client node to access the glusterFS cluster.${GREEN}[$clientName]${NC}"
        lxc copy $clientTemplate $clientName --profile mini
        lxc start $clientName
        lxc file push configs/ca.crt $clientName/etc/docker/certs.d/sys-dtr:5000/ca.crt
    fi
    imgName=""
    for (( c=1; c<=$glusterNode; c++ ))
    do
        gname=$nsName"-gluster"$c
        echo -e "${CYAN}Deploying glusterFS node ${GREEN}[$gname]${NC}"
        lxc copy $glusterTemplate $gname --profile $profile
        lxc start $gname
        sleep 2s
        #
        echo -e "${CYAN}Setting up loopback device...${NC}"
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
        lxc config device add $gname $dvcName unix-block source=$ldDevice
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
        cat loopDevice/mount.sh | lxc exec $gname bash
        #
        lxc exec $gname mkdir /mnt/dvc1/brick
        lxc exec $gname mkdir /mnt/dvc1/brick/1
    done
    # Setup glusterFS cluster
    headGluster=$nsName"-gluster1"
    gname=""
    for (( c=1; c<=$glusterNode; c++ ))
    do
        gname=$nsName"-gluster"$c
        if [[ $gname != $headGluster ]]; then
            lxc exec $headGluster gluster peer probe $gname
        fi
    done
    #
    cat template/glusterVolume.sh > loopDevice/glusterVolume.sh
    gname=""
    for (( c=1; c<=$glusterNode; c++ ))
    do
        gname=$nsName"-gluster"$c
        echo -n "$gname:/mnt/dvc1/brick/1 " >> loopDevice/glusterVolume.sh
    done
    echo "" >> loopDevice/glusterVolume.sh
    echo "gluster volume start xfsvol1" >> loopDevice/glusterVolume.sh
    echo "gluster volume status xfsvol1" >> loopDevice/glusterVolume.sh
    echo "gluster volume info xfsvol1" >> loopDevice/glusterVolume.sh
    cat loopDevice/glusterVolume.sh | lxc exec $headGluster bash 
    #
    echo -e "${GREEN}GlusterFS Cluster Creation Duration: $((($(date +%s)-$start)/60)) minutes${NC}"
    bucket_create_rope $headGluster "webssh"
    bucket_create_rope $clientName "webssh"
}

bucket_delete_gluster() {
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
            echo -e "${CYAN}Deleting namespace [$nsName]...${NC}"
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
            echo -e "${GREEN}Namespace [$nsName] for glusterFS deployment deleted successfully.${NC}"
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