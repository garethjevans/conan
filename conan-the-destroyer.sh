#!/bin/bash
################################
# Define properties
################################
GCP_PROJECT=$(gcloud config get-value project 2>/dev/null)
GCP_ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
GCP_REGION=$(gcloud config get-value compute/region 2>/dev/null)
################################

function delete_everything() {

    if [[ $(gcloud --project ${GCP_PROJECT} services list --enabled | grep -c "container.googleapis.com") -eq 1 ]]; then
		echo "Checking whether there are clusters to delete..."
    	for zone in $(gcloud compute zones list --filter=$GCP_REGION | grep -v NAME | awk '{printf $1 " "}')
    	do
        	for c in $(gcloud container clusters list --filter="zone:($zone)" | grep -v NAME | awk '{printf $1 " "}')
        	do
            	echo "deleting ${c}..."
            	gcloud container clusters delete --zone=$zone --quiet ${c}
        	done
    	done
	fi 

    echo "Checking whether there are instances to delete..."
    for zone in $(gcloud compute zones list --filter=$GCP_REGION | grep -v NAME | awk '{printf $1 " "}')
    do
        for instance in $(gcloud compute instances list --filter="zone:($zone)" | grep -v NAME | awk '{printf $1 " "}')
        do
            echo "deleting ${instance}..."
            instances="${instances} ${instance}"
        done
        if [[ $(gcloud compute instances list --filter="zone:($zone)" 2>&1 | grep -v "Listed 0 items") ]]; then
            gcloud compute instances delete --zone=$zone --quiet ${instances}
        fi
    done

    echo "Checking whether there are disks to delete..."
    for zone in $(gcloud compute zones list --filter=$GCP_REGION | grep -v NAME | awk '{printf $1 " "}')
    do
        for disk in $(gcloud compute disks list --filter="zone:($zone)" | grep -v NAME | awk '{printf $1 " "}')
        do
            echo "deleting ${disk}..."
            gcloud compute disks delete --zone=$zone --quiet ${disk}
        done
    done

    echo "Checking whether there are forwarding rules to delete..."
    for f in $(gcloud compute forwarding-rules list --global | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${f}..."
        gcloud compute forwarding-rules delete --global --quiet ${f}
    done

    for f in $(gcloud compute forwarding-rules list --filter="region:($GCP_REGION)" | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${f}..."
        gcloud compute forwarding-rules delete --region=$GCP_REGION --quiet ${f}
    done
 
    echo "Checking whether there are target proxies to delete..."
    for t in $(gcloud compute target-https-proxies list | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${t}..."
        gcloud compute target-https-proxies delete --quiet ${t}
    done

    for t in $(gcloud compute target-http-proxies list | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${t}..."
        gcloud compute target-http-proxies delete --quiet ${t}
    done

    for t in $(gcloud compute target-pools list | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${t}..."
        gcloud compute target-pools delete --quiet ${t}
    done

    echo "Checking whether there are url maps to delete..."
    for u in $(gcloud compute url-maps list | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${u}..."
        gcloud compute url-maps delete --quiet ${u}
    done

    echo "Checking whether there are backend services to delete..."
    for backend_service in $(gcloud compute backend-services list | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${backend_service}..."
        gcloud compute backend-services delete --quiet ${backend_service} --global
    done

    echo "Checking whether there are instance groups to delete..."
    for zone in $(gcloud compute zones list --filter=$GCP_REGION | grep -v NAME | awk '{printf $1 " "}')
    do
        for instance_group in $(gcloud compute instance-groups unmanaged list --filter="zone:($zone)" | grep -v NAME | awk '{printf $1 " "}')
        do
            echo "deleting ${instance_group}..."
            gcloud compute instance-groups unmanaged delete --zone=$zone --quiet ${instance_group}
        done
    done

    echo "Checking whether there are images to delete..."
    for image in $(gcloud compute images list --filter=stemcell | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${image}..."
        gcloud compute images delete --quiet ${image}
    done

    echo "Checking whether there are routes to delete..."
    for route in $(gcloud compute routes list --filter=nat | grep -v "NAME" | awk '{printf $1 " "}')
    do
        echo "deleting ${route}..."
        gcloud compute routes delete --quiet ${route}
    done

    echo "Checking whether there are health-checks to delete..."
    for s in $(gcloud compute health-checks list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${s}..."
        gcloud compute health-checks delete --quiet ${s}
    done

    for s in $(gcloud compute http-health-checks list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${s}..."
        gcloud compute http-health-checks delete --quiet ${s}
    done
    
	for s in $(gcloud compute https-health-checks list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${s}..."
        gcloud compute https-health-checks delete --quiet ${s}
    done

    echo "Checking whether there are external IP addresses to delete..."
    for address in $(gcloud compute addresses list --filter="region:($GCP_REGION)" | grep -v "NAME" | awk '{printf $1 " "}')
    do
        echo "deleting ${address}..."
        gcloud compute addresses delete --quiet ${address} --region=${GCP_REGION}
    done

    for address in $(gcloud compute addresses list --global | grep -v "NAME" | awk '{printf $1 " "}')
    do
        echo "deleting ${address}..."
        gcloud compute addresses delete --quiet ${address} --global
    done

    echo "Checking whether there are firewall rules to delete..."
    for firewall_rule in $(gcloud compute firewall-rules list 2>/dev/null | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${firewall_rule}..."
        gcloud compute firewall-rules delete --quiet ${firewall_rule}
    done

    echo "Checking whether there are subnets to delete..."
    for subnet in $(gcloud compute networks subnets list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${subnet}..."
        gcloud compute networks subnets delete --quiet ${subnet} --region=${GCP_REGION}
    done

    echo "Checking whether there are networks to delete..."
    for network in $(gcloud compute networks list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${network}..."
        gcloud compute networks delete --quiet ${network}
    done

    echo "Checking whether there are ssl-certificates to delete..."
    for s in $(gcloud compute ssl-certificates list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${s}..."
        gcloud compute ssl-certificates delete --quiet ${s}
    done
    
    if [[ $(gcloud --project ${GCP_PROJECT} services list --enabled | grep -c "dns.googleapis.com") -eq 1 ]]; then
	    echo "Checking whether there are dns zones to delete..."
        for d in $(gcloud dns managed-zones list | egrep -v "NAME|default" | awk '{printf $1 " "}')
        do
            echo "deleting ${d}..."
            gcloud dns record-sets import -z ${d} --delete-all-existing /dev/null
            gcloud dns managed-zones delete --quiet ${d}
        done
	fi

    echo "Checking whether there are sql instances to delete..."
    for s in $(gcloud sql instances list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${s}..."
        gcloud sql instances delete --quiet ${s}
    done
    
    if [[ $(gcloud --project ${GCP_PROJECT} services list --enabled | grep -c "sourcerepo.googleapis.com") -eq 1 ]]; then
        echo "Checking whether there are source repos to delete..."
        for s in $(gcloud source repos list | egrep -v "NAME|default" | awk '{printf $1 " "}')
        do
            echo "deleting ${s}..."
            gcloud source repos delete --quiet ${s}
        done
    fi
    
    echo "Checking whether there are buckets to delete..."
    for s in $(gsutil ls )
    do
        echo "deleting ${s}..."
        gsutil rm -fr ${s}
    done
    
}

echo "#####################################################################"
gcloud config list
echo "#####################################################################"

read -p "
Are you sure you want to delete all resources in the '${GCP_PROJECT}' project?
(a response of 'yes' is required to proceed)
" CHOICE
case "$CHOICE" in
  yes) delete_everything;;
  * ) ;;
esac

