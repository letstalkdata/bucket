sleep 20s
    # Verify that the cluster is ready to be used.
    #
    echo "Verifying that the cluster is ready for use..."
    TIMEOUT=600
    RETRY_INTERVAL=5   
    while [[ $(kubectl get nodes -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == *False* ]]; do 
        if [[ "$TIMEOUT" -le 0 ]]; then
            echo -e "${RED}Cluster node failed to reach the 'Ready' state even after 5 minutes. K8s setup failed.${NC}"
            exit 1
        fi
        echo -e "${CYAN}Cluster not ready. Retrying...${NC}" 
        sleep "$RETRY_INTERVAL"
        TIMEOUT=$(($TIMEOUT-$RETRY_INTERVAL))
    done
    #
    echo -e "${CYAN}--------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
    echo -e "${CYAN}--------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
    lxc list $ns
    kubectl get nodes -o wide
    echo -e "${CYAN}--------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
    echo -e "${CYAN}--------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
    # Show total duration for deployment
    echo -e "${GREEN}Total Duration: $((($(date +%s)-$start)/60)) minutes${NC}"