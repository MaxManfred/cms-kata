# cms-kata
XPeppers hiring test for Cloud Engineer

##### 1. LOGIN INTO GCP
  * Go to `http://console.cloud.google.com`
  * Login with *****************
  
##### 2. OPEN CLOUD SHELL AND CLONE GITHUB REPOSITORY IN IT
  * On the top right menu, click on `Attiva Cloud Shell` icon (the rightmost one)
  * Click on the `AVVIA CLOUD SHELL` in the popup in the botton right corner
  * Wait until the Cloud Shell VM is provisioned
  * At the Cloud Shell prompt type
    ```
    git clone https://github.com/MaxManfred/cms-kata.git
    ll cms-kata
    ```
  * You should see an output similar to the following
    ```
    drwxr-xr-x 3 mm_gcp_trial mm_gcp_trial 4096 Sep 23 09:46 ./
    drwxr-xr-x 7 mm_gcp_trial mm_gcp_trial 4096 Sep 23 09:46 ../
    -rw-r--r-- 1 mm_gcp_trial mm_gcp_trial  167 Sep 23 09:46 email-notification-channel.yaml
    drwxr-xr-x 8 mm_gcp_trial mm_gcp_trial 4096 Sep 23 09:46 .git/
    -rw-r--r-- 1 mm_gcp_trial mm_gcp_trial  612 Sep 23 09:46 README.md
    -rw-r--r-- 1 mm_gcp_trial mm_gcp_trial 3452 Sep 23 09:46 setup-vm.sh
    ```
##### 3. CREATE A GCP PROJECT (THIS HAS ALREADY BEEN DONE FOR YOU, SO SKIP IT!)
  * At the Cloud Shell prompt type
    ```
    gcloud projects create cms-kata --enable-cloud-apis --set-as-default --name="XPeppers Hiring Test" --labels=type=test
    ```
  * Check the output is similar to the following
    ```
    Create in progress for [https://cloudresourcemanager.googleapis.com/v1/projects/cms-kata].
    Waiting for [operations/cp.8993085962360655024] to finish...done.
    Enabling service [cloudapis.googleapis.com] on project [cms-kata]...
    Operation "operations/acf.56d78f8a-7c88-4cdf-8e9d-b3a412a842e8" finished successfully.
    Updated property [core/project] to [cms-kata].
    ```
  * At the Cloud Shell prompt type 
    ```
    gcloud config list project
    ```
  * Check that an output similar to the following is obtained
    ```
    [core]
    project = cms-kata
    Your active configuration is: [cloudshell-4734]
    ```
  * Check your prompt ends with cms-kata like in the following example:
    ```
    mm_gcp_trial@cloudshell:~ (cms-kata)$
    ```
    
##### 4. ENABLE BILLING FOR THE JUST CREATED PROJECT (THIS HAS ALREADY BEEN DONE FOR YOU, SO SKIP IT!)
  * At the Cloud Shell prompt type
    ```
    gcloud alpha billing accounts list
    ```
  * Check you get an output similar to the following:
    ```
    ACCOUNT_ID            NAME                            OPEN  MASTER_ACCOUNT_ID
    01C185-906034-678FFC  Il mio account di fatturazione  True
    ```
  * Link the just created project to the billing account by typing
    ```
    gcloud alpha billing projects link cms-kata --billing-account 01C185-906034-678FFC
    ```
  * Verify you get an output similar to the following:
    ```
    billingAccountName: billingAccounts/01C185-906034-678FFC
    billingEnabled: true
    name: projects/cms-kata/billingInfo
    projectId: cms-kata
    ```

##### 5. CREATE A STORAGE BUCKET TO STORE Joomla ROTATED LOGS BACKUPS
  * At the Cloud Shell prompt type
    ```
    gsutil mb -c coldline -l europe-west6 --retention 7d gs://cms-kata
    ```
  * In the GCP console, open the hamburger menu on the left select ARCHIVIAZIONE > Storage, then click on the `cms-kata` link
  * Click on the `Crea cartella` button and set `logging` as the new folder name
  * Click on the `CREA` link

##### 6. CREATE A VM INSTANCE FOR Joomla
  * At the Cloud Shell prompt type
    ```
    gcloud compute addresses create joomla-static-ip --region europe-west6
    ```
  * Verify you get an output like the following:
    ```
    Created [https://www.googleapis.com/compute/v1/projects/cms-kata/regions/europe-west6/addresses/joomla-static-ip].
    ```
  * At the Cloud Shell prompt type
    ```
    gcloud compute addresses list
    ```
  * Verify you get an output like the following:
    ```
    NAME              ADDRESS/RANGE  TYPE      PURPOSE  NETWORK  REGION        SUBNET  STATUS
    joomla-static-ip  34.65.182.234  EXTERNAL                    europe-west6          RESERVED
    ```
  * Save the just created reserved ip in an environment variable: at the Cloud Shell prompt type
    ```
    export JOOMLA_STATIC_IP=34.65.182.234
    ```
  * At the Cloud Shell prompt type
    ```
    gcloud beta compute --project=cms-kata instances create joomla-vm --address=$JOOMLA_STATIC_IP --zone=europe-west6-a --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=39538115812-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server,https-server --image=ubuntu-1804-bionic-v20190918 --image-project=ubuntu-os-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=joomla-vm --reservation-affinity=any
    gcloud compute --project=cms-kata firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server
    gcloud compute --project=cms-kata firewall-rules create default-allow-https --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:443 --source-ranges=0.0.0.0/0 --target-tags=https-server
    ```
  * Verify you get an output like the following (just ignore the warning:
    ```
    WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
    Created [https://www.googleapis.com/compute/beta/projects/cms-kata/zones/europe-west6-a/instances/joomla-vm].
    NAME       ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
    joomla-vm  europe-west6-a  n1-standard-1               10.172.0.11  34.65.182.234  RUNNING
    Creating firewall...⠏Created [https://www.googleapis.com/compute/v1/projects/cms-kata/global/firewalls/default-allow-http].
    Creating firewall...done.
    NAME                NETWORK  DIRECTION  PRIORITY  ALLOW   DENY  DISABLED
    default-allow-http  default  INGRESS    1000      tcp:80        False
    Creating firewall...⠏Created [https://www.googleapis.com/compute/v1/projects/cms-kata/global/firewalls/default-allow-https].
    Creating firewall...done.
    NAME                 NETWORK  DIRECTION  PRIORITY  ALLOW    DENY  DISABLED
    default-allow-https  default  INGRESS    1000      tcp:443        False

    ```
  * At the Cloud Shell prompt type
    ```
    gcloud compute instances describe joomla-vm --zone europe-west6-a
    ```
  * Verify you get an output like the following:
    ```
    ...
    id: '5361111333643566982'
    ...
    ```
  * Save the just created istance id in an environment variable: at the Cloud Shell prompt type
    ```
    export INSTANCE_ID=5361111333643566982
    ```
    (notice hyphens have been omitted)
  * At the Cloud Shell prompt type
    ```
    gcloud compute scp cms-kata/setup-vm.sh joomla-vm:~ --zone=europe-west6-a
    ```
  * Verify you get an output like the following:
    ```
    Warning: Permanently added 'compute.3006663807333580857' (ECDSA) to the list of known hosts.
    setup-vm.sh
    ```
     
##### 7. SSH INTO THE JUST CREATED INSTANCE
  * At the Cloud Shell prompt type
    ```
    gcloud beta compute --project "cms-kata" ssh --zone "europe-west6-a" "joomla-vm"
    ```
  * Verify you get an output like the following:
    ```
    Unable to retrieve host keys from instance metadata. Continuing.
    Warning: Permanently added 'compute.5361111333643566982' (ECDSA) to the list of known hosts.
    Welcome to Ubuntu 18.04.3 LTS (GNU/Linux 4.15.0-1044-gcp x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage

    System information as of Mon Sep 23 08:35:39 UTC 2019

    System load:  0.0               Processes:           87
    Usage of /:   11.8% of 9.52GB   Users logged in:     0
    Memory usage: 5%                IP address for ens4: 10.172.0.11
    Swap usage:   0%

    0 packages can be updated.
    0 updates are security updates.
    
    
    The programs included with the Ubuntu system are free software;
    the exact distribution terms for each program are described in the
    individual files in /usr/share/doc/*/copyright.

    Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
    applicable law.

    mm_gcp_trial@joomla-vm:~$
    ```
  * At the SSH instance shell prompt type
    ```
    chmod +x setup-vm.sh
    ```
    
##### 8. SETUP INSTANCE WITH BASE SOFTWARE AND CONFIGURATION
  * At the SSH instance shell prompt type
    ```
    sh ./setup-vm.sh
    ```
  * At the script prompt 
    ```
    Please set MySQL root password:
    ```
    type MySQL root password (we will use `root_password` in this example)
  * At the script prompt 
    ```
    Please set Joomla database:
    ```
    type Joomla database name (we will use `joomla` in this example)
  * At the script prompt 
    ```
    Please set Joomla user name:
    ```
    type Joomla application user name (we will use `joomlauser` in this example)
  * At the script prompt 
    ```
    Please set Joomla user password:
    ```
    type Joomla application user password (we will use `joomlauser_password` in this example)
  * At the script prompt 
    ```
    Please set Joomla version (latest being 3-9-11):
    ```
    type Joomla application version you want to install (we will use `3-9-11` in this example)
  * Wait until the setup script completes (it could take a couple of minutes). Please notice that the script could ask you to confirm a system update by asking `Do you want to continue? [Y/n]`. In such a case type `y` at the system prompt.

##### 9. CONFIGURE Joomla
  * Open a browser tab at `http://JOOMLA_STATIC_IP/installation/index.php` where `JOOMLA_STATIC_IP` is the IP you kept apart at step 6
  * Set `Nome Sito` as you like
  * Set `Descrizione` as you like
  * Set `Dettagli account Super User`
        `Email`: put superuser Email (in this example we will use `mm.gcp.trial@gmail.com`)
        `Nome utente`: put superuser login name (in this example we will use `joomlaadmin`)
        `Password`: put superuser login password (in this example we will use `joomlaadmin_password`)
  * Click `Avanti` button in the lower right corner
  * Leave `Tipo Database` to MySQLi
  * Leave `Nome Host` to localhost
  * Set `Nome utente` to `joomlasuser` (see above step 8)
  * Set `Password` to `joomlauser_password` (see above step 8)
  * Set `Nome database` to `joomla` (see above step 8)
  * Set `Prefisso tabelle` to `cmskata_`
  * Set `Processa database vecchio` to `Elimina` (the right button)
  * Click `Avanti` button in the lower right corner
  * Set `Installa dati di esempio to Dati di esempio Inglesi (GB) Blog`
  * Set `Configurazione email` to `Si`
  * Set `Includi le Password nell'Email` to `No`
  * Click `Installa` button in the lower right corner
  * Verify you land on a page with the following message:
    ```
    Congratulazioni, Joomla!® è stato installato correttamente.
    ```
  * At the instance SSH shell prompt type
    ```
    cd /var/www/html/
    sudo rm -fr installation/
    ```
  * Open a browser tab at `http://JOOMLA_STATIC_IP/` where `JOOMLA_STATIC_IP` is the IP you kept apart at step 6
  * Check you see your site home page
  * Open a browser tab at `http://JOOMLA_STATIC_IP/administrator` where `JOOMLA_STATIC_IP` is the IP you kept apart at step 6
  * Check you see your admin site home page
  * Login with the credentials you set before (`joomlaadmin` / `joomlaadmin_password` in this example)
  * Verify you land in the admin site home page
  * Click on `Never` button under the section `Joomla! would like your permission to collect some basic statistics.`
  * Click on `Read messages` button under the section `You have post-installation messages`
  * Click on `Hide all messages` button in the top left corner
  * Click on the Joomla logo in the top left corner to return to administration home page
  * Clock on the user menu at the top right of the window and choose `Logout`
  
##### 10. SET AUTO BACKUP OF Apache2 ROTATED LOG FILES
  * At the instance SSH shell prompt type
    ```
    sudo nano /etc/logrotate.d/apache2
    ```
  * When nano editor opens, replace the file contents with the one from the cloned github repository (file cms-kata/apache2) so that the `/etc/logrotate.d/apache2` looks like the following
    ```
    /var/log/apache2/*.log {
        daily
        missingok
        rotate 7
        compress
        delaycompress
        notifempty
        create 640 root adm
        sharedscripts
        dateext
        dateformat -%Y-%m-%d
        postrotate
            if invoke-rc.d apache2 status > /dev/null 2>&1; then \
                invoke-rc.d apache2 reload > /dev/null 2>&1; \
            fi;
            gsutil -m rsync -r /var/log/apache2/ gs://cms-kata/logging
        endscript
        prerotate
            if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
                run-parts /etc/logrotate.d/httpd-prerotate; \
            fi; \
        endscript
    }
    ```
  * Type CTRL + O, then RETURN, then CTRL + X
  * At the instance SSH shell prompt type
    ```
    sudo service apache2 restart
    ```
  * Check new logrotate configuration works as expected: in the instance SSH shell prompt type
    ```
    sudo logrotate -vf /etc/logrotate.d/apache2
    ```
  * Verify you get an output like the following:
    ```
    reading config file /etc/logrotate.d/apache2
    Reading state from file: /var/lib/logrotate/status
    Allocating hash table for state file, size 64 entries

    Handling 1 logs

    rotating pattern: /var/log/apache2/*.log  forced from command line (7 rotations)
    empty log files are not rotated, old logs are removed
    considering log /var/log/apache2/access.log
    Creating new state
      Now: 2019-09-24 11:48
      Last rotated at 2019-09-24 11:00
      log needs rotating
    considering log /var/log/apache2/error.log
    Creating new state
      Now: 2019-09-24 11:48
      Last rotated at 2019-09-24 11:00
      log needs rotating
    considering log /var/log/apache2/other_vhosts_access.log
    Creating new state
      Now: 2019-09-24 11:48
      Last rotated at 2019-09-24 11:00
      log does not need rotating (log is empty)
    rotating log /var/log/apache2/access.log, log->rotateCount is 7
    Converted ' -%Y-%m-%d' -> '-%Y-%m-%d'
    dateext suffix '-2019-09-24'
    glob pattern '-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
    glob finding logs to compress failed
    glob finding old rotated logs failed
    rotating log /var/log/apache2/error.log, log->rotateCount is 7
    Converted ' -%Y-%m-%d' -> '-%Y-%m-%d'
    dateext suffix '-2019-09-24'
    glob pattern '-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
    glob finding logs to compress failed
    glob finding old rotated logs failed
    running prerotate script
    renaming /var/log/apache2/access.log to /var/log/apache2/access.log-2019-09-24
    creating new /var/log/apache2/access.log mode = 0640 uid = 0 gid = 4
    renaming /var/log/apache2/error.log to /var/log/apache2/error.log-2019-09-24
    creating new /var/log/apache2/error.log mode = 0640 uid = 0 gid = 4
    running postrotate script
    Building synchronization state...
    Starting synchronization...
    Copying file:///var/log/apache2/access.log [Content-Type=application/octet-stream]...
    Copying file:///var/log/apache2/error.log-2019-09-24 [Content-Type=application/octet-stream]...
    Copying file:///var/log/apache2/error.log [Content-Type=application/octet-stream]...
    Copying file:///var/log/apache2/access.log-2019-09-24 [Content-Type=application/octet-stream]...
    Copying file:///var/log/apache2/other_vhosts_access.log [Content-Type=application/octet-stream]...
    / [5/5 files][ 26.6 KiB/ 26.6 KiB] 100% Done
    Operation completed over 5 objects/26.6 KiB.
    ```
  * At the instance SSH shell prompt type
    ```
    exit
    ```
  * At the Cloud Shell prompt type
    ```
    gsutil ls gs://cms-kata/logging
    ```
  * Verify you get an output like the following:
    ```
    gs://cms-kata/logging/
    gs://cms-kata/logging/access.log
    gs://cms-kata/logging/access.log-2019-09-24
    gs://cms-kata/logging/error.log
    gs://cms-kata/logging/error.log-2019-09-24
    gs://cms-kata/logging/other_vhosts_access.log
    ```
    which shows that you have correctly completed a backup into the created bucket.
  * At the Cloud Shell prompt type
    ```
    gcloud beta compute --project "cms-kata" ssh --zone "europe-west6-a" "joomla-vm"
    ```
    to SSH again ito the instance
  
##### 11. INSTALL STACKDRIVER LOGGING AGENT ON INSTANCE
  * At the instance SSH shell prompt type
    ```
    cd
    mkdir agents
    cd agents
    curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
    sudo bash install-logging-agent.sh
    ```
  * Verify you get an output like the following:
    ```
    ==============================================================================
    Starting installation of google-fluentd
    ==============================================================================

    Installing agents for Debian or Ubuntu.
    OK
    Selecting previously unselected package google-fluentd.
    (Reading database ... 62182 files and directories currently installed.)
    Preparing to unpack .../google-fluentd_1.6.17-1_amd64.deb ...
    Unpacking google-fluentd (1.6.17-1) ...
    Selecting previously unselected package google-fluentd-catch-all-config.
    Preparing to unpack .../google-fluentd-catch-all-config_0.7_all.deb ...
    Unpacking google-fluentd-catch-all-config (0.7) ...
    Setting up google-fluentd (1.6.17-1) ...
    Adding system user `google-fluentd' (UID 113) ...
    Adding new group `google-fluentd' (GID 118) ...
    Adding new user `google-fluentd' (UID 113) with group `google-fluentd' ...
    Not creating home directory `/home/google-fluentd'.
    Installing default conffile /etc/google-fluentd/google-fluentd.conf ...
    Setting up google-fluentd-catch-all-config (0.7) ...
    Processing triggers for libc-bin (2.27-3ubuntu1) ...

    ==============================================================================
    Installation of google-fluentd complete.

    Logs from this machine should be visible in the log viewer at:
      https://console.cloud.google.com/logs/viewer?project=cms-kata&resource=gce_instance/instance_id/5361111333643566982

    A test message has been sent to syslog to help verify proper operation.

    Please consult the documentation for troubleshooting advice:
      https://cloud.google.com/logging/docs/agent

    You can monitor the logging agent's logfile at:
      /var/log/google-fluentd/google-fluentd.log
    ==============================================================================
    ```
  * Open a browser tab at `https://console.cloud.google.com/logs/viewer?project=cms-kata&resource=gce_instance/instance_id/5361111333643566982` (see above)
  * See some logging info
  * Open a browser tab at `http://JOOMLA_STATIC_IP/` where `JOOMLA_STATIC_IP` is the IP you kept apart at step 6
  * Navigate your Joomla site
  * Return to `https://console.cloud.google.com/logs/viewer?project=cms-kata&resource=gce_instance/instance_id/5361111333643566982` (see above)
  * Click on `Opzioni di Visualizzazione > Mostra log recenti per primi` on the right margin of the page to show latest log info first
  * Click on the play icon at the top of the page to enable log streaming
  * Observe that your navigation activities have been logged
  * Point your browser at `http://JOOMLA_STATIC_IP/index.php/fake-url` where `JOOMLA_STATIC_IP` is the IP you kept apart at step 6 and see the page not found error page rendered by Joomla
  * Return to `https://console.cloud.google.com/logs/viewer?project=cms-kata&resource=gce_instance/instance_id/5361111333643566982` (see above) and check an entry like the following
    ```
    2019-09-23 12:11:11.677 CEST 151.15.98.130 - - [23/Sep/2019:10:11:11 +0000] "GET /index.php/fake_url HTTP/1.1" 404 3955 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36"
    ```
    that shows the page not found event has been logged
  
##### 12. PROVISION A STACKDRIVER WORKSPACE FOR YOUR PROJECT
  * On the home page of GCP at `https://console.cloud.google.com/home/dashboard?project=cms-kata` click on the left Hambuger menu icon and select `STACKDRIVER > Monitoraggio`
  * Wait until the Stackdriver workspace gets provisioned
  
##### 13. CREATE A METRIC BASED ON LOGS
  * At the instance SSH shell prompt type
    ```
    exit
    ```
    to logout from SSH (see step 7 to login again) and return to the Cloud Shell prompt
  * At the Cloud Shell prompt type
    ```
    gcloud logging metrics create 4xx-http-responses --description="Fetches 4xx HTTP responses" --log-filter='logName="projects/cms-kata/logs/apache-access" AND resource.type="gce_instance" AND labels."compute.googleapis.com/resource_name"="joomla-vm" AND textPayload:("HTTP/1.1\" 4")'
    ```
  * Verify you get an output like the following:
    ```
    Created [4xx-http-responses].
    ```
  * Point your browser at `http://JOOMLA_STATIC_IP/index.php/fake-url` where `JOOMLA_STATIC_IP` is the IP you kept apart at step 6 and see the page not found error page rendered by Joomla 
  * In the Stackdriver workspace window opened at step 12, click on `Logging` from the left menu
  * Click on `Metriche basate sui log` in the opened `Log Viewer` browser tab and notice you new metric is displayed at the page bottom
  * Click on the three vertical dots button at the very right of the row displaying the `4xx-http-responses` metric just created and choose `Visualizza log per la metrica`
  * Play with the GCP interface to check you access to the site has been correctly picked up by the metric (being a 404 access)
    
##### 14. CREATE A NOTIFICATION CHANNEL
  * At the Cloud Shell prompt type
    ```
    gcloud alpha monitoring channels create --channel-content-from-file="./cms-kata/email-notification-channel.yaml"
    ```
  * Verify you get an output like the following:
    ```
    Created notification channel [projects/cms-kata/notificationChannels/1027742119710711380].
    ```
  * At the Cloud Shell prompt type
    ```
    gcloud alpha monitoring channels describe projects/cms-kata/notificationChannels/1027742119710711380
    ```
    (notice we used the same GCP global id for the channel just created)
  * Verify you get an output like the following:
    ```
    description: Sends an email when a policy is violated
    displayName: Email notification channel
    enabled: true
    labels:
      email_address: mm.gcp.trial@gmail.com
    name: projects/cms-kata/notificationChannels/1027742119710711380
    type: email
    ```
  * Save the just created notification channel id in an environment variable: at the Cloud Shell prompt type
    ```
    export NOTIFICATION_CHANNEL_ID=projects/cms-kata/notificationChannels/1027742119710711380
    ```
    
##### 15. CREATE AN ALERTING POLICY USING THE NOTIFICATION CHANNEL
  * At the Cloud Shell prompt type
    ```
    cp cms-kata/too-many-4xx-responses-policy.yaml cms-kata/too-many-4xx-responses-policy.yaml.bk
    sed -i 's|INSTANCE_ID|'$INSTANCE_ID'|g;s|NOTIFICATION_CHANNEL_ID|'$NOTIFICATION_CHANNEL_ID'|g' cms-kata/too-many-4xx-responses-policy.yaml
    ```
    to backup the original alerting policy config file and replace the placeholders `INSTANCE_ID` and `NOTIFICATION_CHANNEL_ID` in it with the homologous environment variables et above.
  * At the Cloud Shell prompt type
    ```
    nano cms-kata/too-many-4xx-responses-policy.yaml
    ```
    and verify the replacment has actually worked.
  * CTRL + X
  * At the Cloud Shell prompt type
    ```
    gcloud alpha monitoring policies create --policy-from-file="./cms-kata/too-many-4xx-responses-policy.yaml"
    ```
  * Verify you get an output like the following:
    ```
    Created alert policy [projects/cms-kata/alertPolicies/579283631983494493].
    ```
  * At the Cloud Shell prompt type
    ```
    gcloud alpha monitoring policies describe projects/cms-kata/alertPolicies/579283631983494493
    ```
    (notice we used the same GCP global id for the policy just created)
  * Verify you get an output like the following:
    ```
    combiner: OR
    conditions:
    - conditionThreshold:
        aggregations:
        - alignmentPeriod: 60s
          crossSeriesReducer: REDUCE_PERCENTILE_99
          perSeriesAligner: ALIGN_DELTA
        comparison: COMPARISON_GT
        duration: 0s
        filter: metric.type="logging.googleapis.com/user/4xx-http-responses" resource.type="gce_instance"
          resource.label."instance_id"="5361111333643566982"
        thresholdValue: 10.0
        trigger:
          count: 1
      displayName: logging/user/4xx-http-responses for joomla-vm
      name: projects/cms-kata/alertPolicies/579283631983494493/conditions/579283631983494322
    creationRecord:
      mutateTime: '2019-09-23T10:53:00.166867360Z'
      mutatedBy: mm.gcp.trial@gmail.com
    displayName: too-many-4xx-responses-policy
    documentation:
      content: 'Warning: more than 10 HTTP responses with 4xx status code have been returned
        by the joomla-vm instance.'
      mimeType: text/markdown
    enabled: true
    mutationRecord:
      mutateTime: '2019-09-23T10:53:00.166867360Z'
      mutatedBy: mm.gcp.trial@gmail.com
    name: projects/cms-kata/alertPolicies/579283631983494493
    notificationChannels:
    - projects/cms-kata/notificationChannels/1027742119710711380
    ```
  * On the home page of GCP at `https://console.cloud.google.com/home/dashboard?project=cms-kata` click on the left Hambuger menu icon and select `STACKDRIVER > Monitoraggio`
  * Select `Alerting > Policies Overview` from the left menu to access the alerting policies list page.
  * Click on the `too-many-4xx-responses-policy` link to see the details of the alerting policy you have just created
    
##### 16. STIMULATE A FAKE URL ON THE APP TO TRIGGER 404 ACCESSES AND CHECK THE EMAIL NOTIFICATION
  * Point your browser at `http://JOOMLA_STATIC_IP/index.php/fake-url` where `JOOMLA_STATIC_IP` is the IP you kept apart at step 6 and see the page not found error page rendered by Joomla 
  * Reload the page more than 10 times so to generate several 404 HTTP access log entries.
  * Open a web browser tab at `http://www.gmail.com` and login with the credentials at step 1.
  * After a few minutes (keep waiting), you should receive a couple of email from GCP, the first raising the alarm, the second to inform you the situation is back to normal.
  
