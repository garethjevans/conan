# conan the destroyer

A bash script to delete as much as possible from a GCP project.

WARNING: destructive!

```
gcloud init

conan (master) $ ./conan-the-destroyer.sh 
#####################################################################
[compute]
region = europe-west2
zone = europe-west2-a
[core]
account = admin@example.com
disable_usage_reporting = True
project = my-gcp-project

Your active configuration is: [default]
#####################################################################

Are you sure you want to delete all resources in the 'my-gcp-project' project?
(a response of 'yes' is required to proceed)
yes
```

