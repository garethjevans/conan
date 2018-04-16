################################
# Define properties
################################
GCP_PROJECT=$(gcloud config get-value project 2>/dev/null)
GCP_ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
GCP_REGION=$(gcloud config get-value compute/region 2>/dev/null)
################################

function delete_everything() {

    echo "Checking whether there are instances to delete..."
    for zone in $(gcloud compute zones list --filter=$GCP_REGION | grep -v NAME | awk '{printf $1 " "}')
    do
        for instance in $(gcloud compute instances list --filter="zone:($zone)" | grep -v NAME | awk '{printf $1 " "}')
        do
            echo "deleting ${instance}..."
            gcloud compute instances delete --zone=$zone --quiet ${instance}
        done
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

    for f in $(gcloud compute forwarding-rules list --global | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${f}..."
        gcloud compute forwarding-rules delete --global --quiet ${f}
    done

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

    for u in $(gcloud compute url-maps list | grep -v NAME | awk '{printf $1 " "}')
    do
        echo "deleting ${u}..."
        gcloud compute url-maps delete --quiet ${u}
    done

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

    echo "Checking whether there are external IP addresses to delete..."
    for address in $(gcloud compute addresses list | grep -v "NAME" | awk '{printf $1 " "}')
    do
        echo "deleting ${address}..."
        gcloud compute addresses delete --quiet ${address} --region\=${GCP_REGION}
    done

    echo "Checking whether there are firewall rules to delete..."
    for firewall_rule in $(gcloud compute firewall-rules list 2>/dev/null | grep -v "NAME" | awk '{printf $1 " "}')
    do
        echo "deleting ${firewall_rule}..."
        gcloud compute firewall-rules delete --quiet ${firewall_rule}
    done

    echo "Checking whether there are subnets to delete..."
    for subnet in $(gcloud compute networks subnets list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${subnet}..."
        gcloud compute networks subnets delete --quiet ${subnet} --region\=${GCP_REGION}
    done

    echo "Checking whether there are networks to delete..."
    for network in $(gcloud compute networks list | egrep -v "NAME|default" | awk '{printf $1 " "}')
    do
        echo "deleting ${network}..."
        gcloud compute networks delete --quiet ${network}
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

