#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
help_bucket(){
    echo -e "${CYAN}${GREEN}bucket${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${GREEN}bucket${CYAN} is an utility for building miniaturised version SQL Server Big Data Cluster${NC}"
    echo -e "${CYAN}for learning and validation purpose${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} [command]${NC}"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}config       Manage bucket instance and server configuration options${NC}"
    echo -e "${CYAN}setup        Setup bucket environment on your ubuntu machine (physical/VM)${NC}"
    echo -e "${CYAN}info         Showcase overall information of bucket setup${NC}"
    echo -e "${CYAN}create       Create nodes and clusters${NC}"
    echo -e "${CYAN}delete       Delete nodes and clusters${NC}"
    echo -e "${CYAN}modify       Modify nodes and clusters${NC}" 
    echo -e "${CYAN}show         Show instance and other running details${NC}"
    echo -e "${CYAN}snapshot     Manage bucket instance snapshots${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo -e "${CYAN}-v  --version         Print version number${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} [command] --help' for more information about a command.${NC}"
}
help_bucket_create(){
    echo -e "${GREEN}bucket create${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Create nodes and cluster for learning and validation purpose${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create [command] [flags]${NC}"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}ns        Create NameSpace ${NC}"
    echo -e "${CYAN}node      Create simple CentOS/Ubuntu node/s for individual POCs ${NC}"
    echo -e "${CYAN}mysql     Create standalone or cluster MySQL deployment ${NC}"
    echo -e "${CYAN}client    Create single CentOS client Machine with required tool installed${NC}"
    echo -e "${CYAN}dtr       Create a Local Docker Registry${NC}"
    echo -e "${CYAN}k8s       Deploy Single master or Multi master kubernetes cluster${NC}"
    echo -e "${CYAN}nfs       Create NFS(Network file syatem) deployment${NC}"
    echo -e "${CYAN}rope      Create rope to given bucket for external access${NC}"
    echo -e "${CYAN}gluster   Create GlusterFS HCI storage cluster${NC}"
    echo -e "${CYAN}bdc       Deploy SQL Server Big Data Cluster on new or existing K8s cluster${NC}" 
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} [command] --help' for more information about a command.${NC}"
}
help_bucket_create_ns(){
    echo -e "${GREEN}create ns${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Create Namespace for segrigation of workload${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create ns [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}    --name            Name of the node to be created${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create node --help' for more information about a command.${NC}"
}
help_bucket_create_node(){
    echo -e "${GREEN}create node${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Create simple single node with different OS and computation profile${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create node [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n, --namespace       Attach node to given namespace${NC}"
    echo -e "${CYAN}-c, --count           Number of nodes to be created${NC}"
    echo -e "${CYAN}-p  --profile         Pass different profile (tiny [mini] regular1 regular2 heavy1 heavy2 heavy3) ${NC}"
    echo -e "${CYAN}    --os              Create node with given os (default = [centos], ubuntu) ${NC}"
    echo -e "${CYAN}-v, --osv             Create node with given os and version ${NC}"
    echo -e "${CYAN}                      (default = [7] for centos (other versions 6 & 8)) ${NC}"
    echo -e "${CYAN}                      (default = [16.04] for ubuntu (other versions 18.04 & 19.04)) ${NC}"
    echo -e "${CYAN}    --withClient      Add client node along with 'webssh' rope ${NC}"
    echo -e "${CYAN}    --withVolume      Add an extra loopback volume to each node${NC}"
    echo -e "${CYAN}    --volumeGB        Size of loopback volume (GB) to be added to each node${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create node --help' for more information about a command.${NC}"
}
help_bucket_create_client(){
    echo -e "${GREEN}create client${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN} Create single CentOS client node with required tool installed and configured${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create client [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n, --namespace       Attach client node to specified namespace${NC}"
    echo -e "${CYAN}    --name            Name of the client to be created${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create node --help' for more information about a command.${NC}"
}
help_bucket_create_dtr(){
    echo -e "${GREEN}bucket create dtr${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy a Local Docker Registry${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create dtr [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n, --namespace       Attach client node to specified namespace${NC}"
    echo -e "${CYAN}    --name            [Mandatory Parameter] Name of the local docker registry to be created${NC}"
    echo -e "${CYAN}-p  --profile         Different profile (tiny [mini] mini2 regular regular2 heavy heavy2 heavy3) ${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create node --help' for more information about a command.${NC}"
}
help_bucket_create_k8s(){
    echo -e "${GREEN}bucket create k8s${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy Single master or Multi master kubernetes cluster${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create k8s [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n, --namespace       Attach client node to specified namespace${NC}"
    echo -e "${CYAN}-p  --profile         worker node profile (tiny [mini] mini2 regular regular2 heavy heavy2 heavy3) ${NC}"
    echo -e "${CYAN}-v, --k8sVersion      Kubernetes version to be deployed (default = 1.14.2)${NC}"
    echo -e "${CYAN}-m, --master          No Of Master Nodes (default is 1 and max of 3 as per this release)${NC}"
    echo -e "${CYAN}-w, --worker          No Of worker Nodes (default is 1 and max of 9 as per this release)${NC}"
    echo -e "${CYAN}    --cni             Container Network Interface (default = Flannel other options *Calico*, *Weave*)${NC}"
    echo -e "${CYAN}    --csi             Container Storage Interface ([local], nfs, gluster)${NC}"
    echo -e "${CYAN}    --dtr             Configure local docker registry (default = shared, other option *local* )${NC}"
    echo -e "${CYAN}    --noClient        Do not deploy a client node along with Kubernetes cluster for management${NC}"
    echo -e "${CYAN}    --noDashboard     Do not deploy Kubernetes dashboard along with Kubernetes cluster for visualization${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create node --help' for more information about a command.${NC}"
}
help_bucket_create_bdc(){
    echo -e "${GREEN}create bdc${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy SQL Server Big Data Cluster${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create bdc [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n, --namespace       Create or attach BDC cluster to specified namespace${NC}"
    echo -e "${CYAN}-   --name            Name of the SQL BDC deployment${NC}"
    echo -e "${CYAN}-k, --oldk8s          Deploy SQL BDC on existing Kubernetes cluster (default = Deploy new K8s Cluster)${NC}"
    echo -e "${CYAN}-p  --profile         Bucket profile for K8s worker nodes(tiny [mini] mini2 regular regular2 heavy heavy2 heavy3) ${NC}"
    echo -e "${CYAN}-m, --master          Kubernetes master nodes[default=1]${NC}"
    echo -e "${CYAN}-w, --worker          Kubernetes worker nodes[default=1]${NC}"
    echo -e "${CYAN}-u, --user            SQL BDC User name${NC}"
    echo -e "${CYAN}-p, --password        SQL BDC Password${NC}"
    echo -e "${CYAN}-   --dpn             SQL BDC Data Pool Nodes (ex:- --dpn 4:5:6 where 4, 5 and 6 are kubernetes worker nodes)${NC}"
    echo -e "${CYAN}-   --cpn             SQL BDC Compute Pool Nodes (ex:- --cpn 4:5:6 where 4, 5 and 6 are kubernetes worker nodes)${NC}"
    echo -e "${CYAN}-   --spn             SQL BDC Storage Pool Nodes (ex:- --spn 7:8:9 where 7, 8 and 9 are kubernetes worker nodes)${NC}"
    echo -e "${CYAN}    --ha              BDC HA deployment (Default = NO HA)${NC}"
    echo -e "${CYAN}    --help            Print help${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create node --help' for more information about a command.${NC}"
}
help_bucket_create_rope(){
    echo -e "${GREEN}create rope${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Create a rope to the bucket for reaching from outside world${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create rope [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-b, --bucket          Name of the bucket for attaching the rope${NC}"
    echo -e "${CYAN}-r, --rope            rope type to be created for hook attachment [default = ssh, dashbord)${NC}"
    echo -e "${CYAN}-k, --hook            bucket hook (port) to attach [default = 22 for ssh rope type]${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket create rope -b k8s2-client -r ssh ${NC}"
    echo -e "${CYAN}bucket create rope -b k8s2-client -r ssh -k 22 ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create rope --help' for more information about a command.${NC}"
    echo
}
help_bucket_show_rope(){
    echo -e "${GREEN}show rope${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Showcase all ropes attached given bucket ${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} show rope [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-b, --bucket          Name of the bucket for attaching the rope${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket show rope -b k8s2-client ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} show rope --help' for more information about a command.${NC}"
    echo
}
help_bucket_delete_rope(){
    echo -e "${GREEN}delete rope${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Delete given rope from given bucket ${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} delete rope [flags]${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} rm rope [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-b, --bucket          Name of the bucket for attaching the rope${NC}"
    echo -e "${CYAN}-r, --rope            rope name to be deleted ${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket delete rope -b k8s2-client ${NC}"
    echo -e "${CYAN}bucket rm rope -b k8s2-client ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} delete rope --help' for more information about a command.${NC}"
    echo
}
help_bucket_create_k8sui(){
    echo -e "${GREEN}create k8sUI${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy K8sUI dashboard on existing K8s cluster and make it asscessble from LAN${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create k8sUI [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n, --namespace       Attach client node to specified namespace${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket create k8sUI -n k8s1 ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create k8sUI --help' for more information about a command.${NC}"
    echo
}
help_bucket_show_k8sui(){
    echo -e "${GREEN}show k8sUI${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Show detail about K8sUI dashboard and its access token ${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create k8sUI [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n, --namespace       Attach client node to specified namespace${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket create k8sUI -n k8s1 ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create k8sUI --help' for more information about a command.${NC}"
    echo
}
help_bucket_setup(){
    echo -e "${GREEN}setup${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Setup different bucket initial configuration ${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} setup [command]${NC}"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}init                setup initial bucket environment${NC}"
    echo -e "${CYAN}profile             setup initial profiles${NC}"
    echo -e "${CYAN}template            setup initial templates by type${NC}"
    echo -e "${CYAN}all                 setup all initial configuration${NC}"
    echo
    echo -e "${CYAN}Universal Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket setup -h ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} setup --help' for more information about a command.${NC}"
    echo
}
help_bucket_setup_template(){
    echo -e "${GREEN}setup template${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Setup different bucket initial template ${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} setup template [flags]${NC}"
    echo
    echo -e "${CYAN}Available Flags:${NC}"
    echo -e "${CYAN}-c, --client        setup client template only${NC}"
    echo -e "${CYAN}-n, --node          setup node template only${NC}"
    echo -e "${CYAN}-m, --mysql         setup MySQL template only${NC}"
    echo -e "${CYAN}-k, --k8s           setup k8s template only${NC}"
    echo -e "${CYAN}-g, --gluster       setup glusterFS template only${NC}"
    echo -e "${CYAN}-k, --k8s           setup k8s template only${NC}"
    echo -e "${CYAN}-d, --dtr           setup dtr template only${NC}"
    echo -e "${CYAN}-a, --all           setup all templates ${NC}"
    echo
    echo -e "${CYAN}Universal Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket setup template -h ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} setup template --help' for more information about a command.${NC}"
    echo
}
help_bucket_create_gluster(){
    echo -e "${GREEN}create gluster${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy Multi node glusterFS cluster${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create gluster [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n,  --namespace       Attach client node to specified namespace${NC}"
    echo -e "${CYAN}-p,  --profile         bucket profile (tiny [mini] mini2 regular regular2 heavy heavy2 heavy3) ${NC}"
    echo -e "${CYAN}-gn, --glusterNode     No Of glusterFS Nodes (default is 1 and max is 9 as per this release)${NC}"
    echo -e "${CYAN}     --volumeGB        Size of loopback volume (GB) to be added to each gluster node${NC}"
    echo -e "${CYAN}     --noClient        Do not deploy a client node along with Kubernetes cluster for management${NC}"
    echo
    echo -e "${CYAN}Universal Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create nfs --help' for more information about a command.${NC}"
}
help_bucket_create_nfs(){
    echo -e "${GREEN}create nfs${CYAN} help${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}Deploy single node NFS Server${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} create nfs [flags]${NC}"
    echo
    echo -e "${CYAN}Flags:${NC}"
    echo -e "${CYAN}-n,  --namespace       Attach NFS node to specified namespace${NC}"
    echo -e "${CYAN}-p,  --profile         bucket profile (tiny [mini] mini2 regular regular2 heavy heavy2 heavy3) ${NC}"
    echo
    echo -e "${CYAN}Universal Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} create nfs --help' for more information about a command.${NC}"
}
help_bucket_list(){
    echo -e "${GREEN}list${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}list different resources created using bucket ${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} list [command]${NC}"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "${CYAN}ns                  list all existing namespaces${NC}"
    echo -e "${CYAN}node                list all nodes in a given namespaces ${NC}"
    echo -e "${CYAN}rope                list all ropes in a given namespaces${NC}"
    echo
    echo -e "${CYAN}Universal Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket list -h ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} list --help' for more information about a command.${NC}"
    echo
}
help_bucket_list(){
    echo -e "${GREEN}list ns${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}list all existing namespaces created using bucket ${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} list ns [namespace_name]${NC}"
    echo
    echo -e "${CYAN}Universal Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket list ns n1 ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} list --help' for more information about a command.${NC}"
    echo
}
help_bucket_list(){
    echo -e "${GREEN}list node${CYAN} help:-${NC}"
    echo -e "${CYAN}Description:"
    echo -e "${CYAN}list all nodes in a given namespace ${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo -e "${CYAN}${GREEN}bucket${CYAN} list node [command]${NC}"
    echo
    echo -e "${CYAN}Available Flags:${NC}"
    echo -e "${CYAN}-n, --namespace     namespaces name${NC}"
    echo
    echo -e "${CYAN}Universal Flags:${NC}"
    echo -e "${CYAN}-h, --help            Print help${NC}"
    echo
    echo -e "${CYAN}Example:${NC}"
    echo -e "${CYAN}bucket list node -n n1 ${NC}"
    echo
    echo -e "${CYAN}Use '${GREEN}bucket${CYAN} list --help' for more information about a command.${NC}"
    echo
}