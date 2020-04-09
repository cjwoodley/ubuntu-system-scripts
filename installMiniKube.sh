
#sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
#sudo apt update
#sudo apt install -y kubectl
instll_pre_reqs()
{
    echo "Installing Curl"
    if ! [ -x "$(command -v curl)" ]; then
        echo 'Error: curl is not installed.' >&2
        sudo apt update 
        sudo apt -y install curl  
    fi
    
}

install_kvm()
{
        echo "Installing KVM"
    if ! [ -x "$(command -v virt-manager)" ]; then
        echo 'Error: virt-manager is not installed.' >&2
        sudo apt update 
        sudo apt -y install qemu qemu-kvm libvirt-bin  bridge-utils  virt-manager libvirt-daemon-system libvirt-clients bridge-utils
        
    fi
    
}

start_kvm_service()
{
    #sudo service libvirtd start
    #sudo update-rc.d libvirtd enable
    #service libvirtd status

service=libvirtd
host=`hostname -f`
if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
echo "$service is running"
else
sudo service $service start
sudo update-rc.d libvirtd enable
if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
subject="$service at $host has been started"
echo "$service at $host wasn't running and has been started" | mail -s "$subject" $email
else
subject="$service at $host is not running"
echo "$service at $host is stopped and cannot be started!!!" | mail -s "$subject" $email
fi
fi
}

add_currentuser_kvm()
{
    sudo adduser `id -un` libvirt
    sudo adduser `id -un` kvm
    
}

install_kubectl()
{
    if ! [ -x "$(command -v /usr/local/bin/kubectl)" ]; then
        echo 'Installing kubectl'
        curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
        kubectl version --client
    fi
}

install_miniKube()
{
    if ! [ -x "$(command -v /usr/local/bin/minikube)" ]; then
    echo 'Installing kubectl'
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
    sudo mkdir -p /usr/local/bin/
    sudo install minikube /usr/local/bin/
    rm ./minikube
    fi
}

instll_pre_reqs
install_kvm
start_kvm_service
install_kubectl
install_miniKube