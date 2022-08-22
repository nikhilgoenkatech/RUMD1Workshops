RUMD1WRKSHP_REPO="https://github.com/nikhilgoenkatech/RUMD1Workshops.git"
RUMD1WRKSHP_DIR="~/docker-compose-bankApp"

RETAILAPP_REPO="https://github.com/nikhilgoenkatech/retailapp.git"
RETAILAPP_DIR="~/e-commerce"

BANKAPP_REPO="https://github.com/nikhilgoenkatech/Bank-Sample-app.git"
BANKAPP_DIR="~/Bank-Sample-app"

OTEL_REPO="https://github.com/nikhilgoenkatech/Otel-sample-code.git"
OTEL_DIR="~/otel"

dockerInstall() {
  if [ "$docker_install" = true ]; then
    printInfoSection "Installing Docker and J Query"
    printInfo "Install J Query"
    apt install jq -y
    printInfo "Install Docker"
    apt install docker.io -y
    service docker start
    usermod -a -G docker $USER
  fi
}

downloadStandAloneSetup() {
  if [ "$standalone_deployment" = true ]; then
    printInfoSection "Installing Standalone pre-requisites"
    apt install python3-pip -y
    apt install nginx -y
    apt install gunicorn -y 
    apt-get remove libapache2-mod-python libapache2-mod-wsgi
    apt-get install libapache2-mod-wsgi-py3 -y
    pip3 install uwsgi

    pip3 install gunicorn==19.7.1
    pip3 install autodynatrace
    pip3 uninstall Django -y
    pip3 install Django==2.2.10

    cp /home/ubuntu/e-commerce/nginx.default /etc/nginx/sites-enabled/default
    pip3 install -r /home/ubuntu/e-commerce/requirements.txt
    
    python3.6 manage.py collectstatic --noinput
    cp -r /home/ubuntu/e-commerce/src/static /static/
    printInfoSection "Installed Standalone pre-requisites"

    printInfo "Install Docker"
    apt install docker.io -y
    service docker start
    usermod -a -G docker $USER

    printInfo "Install npm"
    apt install npm -y
  fi
}

dockerComposeInstall() {
  if [ "$docker_compose_install" = true ]; then
    printInfoSection "Installing Docker-Compose"
    printInfo "Downloading Compose repo"
    bashas "sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose"
    printInfo "Assigning execution permissions to docker-compose"
    bashas "sudo chmod +x /usr/local/bin/docker-compose"
    printInfo "Creating a soft link to the docker-compose binary"
    bashas "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose"
  fi
}

setBashas() {
  # Wrapper for runnig commands for the real owner and not as root
  alias bashas="sudo -H -u ${USER} bash -c"
  # Expand aliases for non-interactive shell
  shopt -s expand_aliases
}
timestamp() {
  date +"[%Y-%m-%d %H:%M:%S]"
}
printInfo() {
  echo "[install-prerequisites|INFO] $(timestamp) |>->-> $1 <-<-<|"
}

printInfoSection() {
  echo "[install-prerequisites|INFO] $(timestamp) |$thickline"
  echo "[install-prerequisites|INFO] $(timestamp) |$halfline $1 $halfline"
  echo "[install-prerequisites|INFO] $(timestamp) |$thinline"
}

printError() {
  echo "[install-prerequisites|ERROR] $(timestamp) |x-x-> $1 <-x-x|"
}

# ======================================================================
#          ----- Installation Functions -------                        #
# The functions for installing the different modules and capabilities. #
# Some functions depend on each other, for understanding the order of  #
# execution see the function doInstallation() defined at the bottom    #
# ======================================================================
updateUbuntu() {
  if [ "$update_ubuntu" = true ]; then
    printInfoSection "Updating Ubuntu apt registry"
    apt update
  fi
}

setupProAliases() {
  if [ "$setup_proaliases" = true ]; then
    printInfoSection "Adding Bash and Kubectl Pro CLI aliases to .bash_aliases for user ubuntu and root "
    echo "
      # Alias for ease of use of the CLI
      alias las='ls -las'
      alias hg='history | grep'
      alias h='history'
      alias vaml='vi -c \"set syntax:yaml\" -'
      alias vson='vi -c \"set syntax:json\" -'
      alias pg='ps -aux | grep' " >/root/.bash_aliases
    homedir=$(eval echo ~$USER)
    cp /root/.bash_aliases $homedir/.bash_aliases
  fi
}

dynatraceActiveGateInstall() {
  if [ "$dynatrace_activegate_install" = true ]; then
    printInfoSection "Installation of Active Gate"
    wget -nv -O activegate.sh "https://$DT_TENANT/api/v1/deployment/installer/gateway/unix/latest?Api-Token=$DT_PAAS_TOKEN&arch=x86&flavor=default"
    sh activegate.sh
    printInfo "removing ActiveGate installer."
    rm activegate.sh
  fi
}

downloadApacheJmeter() {
  if [ "$download_Jmeter" = true ]; then
    printInfoSection "Installation of Apache JMeter"
    bashas "sudo apt-get install openjdk-8-jre-headless -y"
    wget -nv -q -O /home/ubuntu/apache-jmeter.zip "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.2.1.zip"
    bashas "cd /home/ubuntu/"
    bashas "sudo apt-get install unzip -y"
    bashas "sudo unzip /home/ubuntu/apache-jmeter.zip -d /home/ubuntu/" 
    printInfo "Apache Jmeter has been downloaded at /home/ubuntu/apache-jmeter-5.2.1 directory."
  fi
}

downloadApacheJmeterScripts() {
  if [ "$download_JmeterScripts" = true ]; then
    printInfoSection "Cloning the RUMD1Workshop repository"
    bashas "cd /home/ubuntu/"
    bashas "sudo git clone https://github.com/nikhilgoenkatech/RUMD1Workshops.git"
    printInfo "Cloned the RUMD1Workshop repository in /home/ubuntu/ directory."
  fi
}

downloadBankSampleApplication(){
  if [ "$install_start_bank_docker" = true ]; then
    printInfoSection "Downloading docker-image for sample bank application"
    bashas "docker pull nikhilgoenka/sample-bank-app"
    bashas "docker run -d --name SampleBankApp -p 4000:3000 nikhilgoenka/sample-bank-app"
    printInfo "Docker SampleBankApp is running on port 4000"
  fi
}
downloadJenkinsDocker(){
  if [ "$download_jenkins_image" = true ]; then
    printInfoSection "Downloading docker-image for Jenkins Workshop" 
    bashas "docker network create -d bridge mynetwork"
    bashas "docker pull nikhilgoenka/jenkins-dynatrace-workshop"
    bashas "sudo mkdir /var/jenkins/" 
    printInfo "Docker Jenkins is now downloaded and available to be executed."
  fi
}

downloadStartAnsibleTower(){
  if [ "$install_start_ansible_tower_docker" = true ]; then
    printInfoSection "Downloading docker-image for ansible tower"
    bashas "docker pull ybalt/ansible-tower"
    printInfo "Docker Ansible-tower image is now downloaded"
  fi
}
resources_clone(){
  if [ "$clone_the_repo" = true ]; then
    printInfoSection "Clone RUMD1Workshop Resources in $RUMD1WRKSHP_DIR"
    bashas "sudo git clone $RUMD1WRKSHP_REPO $RUMD1WRKSHP_DIR"
    
    printInfoSection "Clone RETAILAPP_REPO Resources in $RETAILAPP_DIR"
    bashas "sudo git clone $RETAILAPP_REPO $RETAILAPP_DIR"
    
    printInfoSection "Clone BANKAPP_REPO Resources in $BANKAPP_DIR"
    bashas "sudo git clone $BANKAPP_REPO $BANKAPP_DIR"    
    
    printInfoSection "Clone OTEL_REPO Resources in $OTEL_DIR"
    bashas "sudo git clone $OTEL_REPO $OTEL_DIR" 
  fi
}
createWorkshopUser() {
  if [ "$create_workshop_user" = true ]; then
    printInfoSection "Creating Workshop User from user($USER) into($NEWUSER)"
    homedirectory=$(eval echo ~$USER)
    printInfo "copy home directories and configurations"
    cp -R $homedirectory /home/$NEWUSER
    printInfo "Create user"
    useradd -s /bin/bash -d /home/$NEWUSER -m -G sudo -p $(openssl passwd -1 $NEWPWD) $NEWUSER
    printInfo "Change diretores rights -r"
    chown -R $NEWUSER:$NEWUSER /home/$NEWUSER
    usermod -a -G docker $NEWUSER
    usermod -a -G microk8s $NEWUSER
    printInfo "Warning: allowing SSH passwordAuthentication into the sshd_config"
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 20/g' /etc/ssh/sshd_config
    sed -i 's/#ClientAliveCountMax 0/ClientAliveCountMax 3/g' /etc/ssh/sshd_config
    service sshd restart
  fi
}

# ======================================================================
#       -------- Function boolean flags ----------                     #
#  Each function flag representas a function and will be evaluated     #
#  before execution.                                                   #
# ======================================================================
# If you add varibles here, dont forget the function definition and the priting in printFlags function.
verbose_mode=false
update_ubuntu=false
clone_the_repo=false
docker_install=false
setup_proaliases=false
download_Jmeter=false
download_JmeterScripts=false
install_start_bank_docker=false
download_jenkins_image=false
install_start_ansible_tower_docker=false
create_workshop_user=false
docker_compose_install=false

installBankCustomerRUMWorkshop() {
  update_ubuntu=true
  setup_proaliases=true
  clone_the_repo=true

  docker_install=true
  create_workshop_user=true
  docker_compose_install=true
}

installBankCustomerRUMWorkshopStandalone() {
  update_ubuntu=true
  setup_proaliases=true
  clone_the_repo=true

  create_workshop_user=true
  standalone_deployment=true
}

# ======================================================================
#            ---- The Installation function -----                      #
#  The order of the subfunctions are defined in a sequencial order     #
#  since ones depend on another.                                       #
# ======================================================================
installSetup() {
  echo ""
  printInfoSection "Installing ... "
  echo ""

  echo ""
  setBashas

  updateUbuntu
  setupProAliases
  createWorkshopUser
  
  resources_clone
  dockerInstall
  dockerComposeInstall
  dynatraceActiveGateInstall
  downloadApacheJmeterScripts

  downloadApacheJmeter

  downloadBankSampleApplication
  downloadJenkinsDocker
  
  downloadStartAnsibleTower
  downloadStandAloneSetup
}

