# conectar no master e configurar

~/environment/ip # | awk -Fv '/vm_0/{print $1}' 

MASTER=$(~/environment/ip | awk -Fv '/vm_0/{print $1}')
NODE1=$(~/environment/ip | awk -Fv '/vm_1/{print $1}')
NODE2=$(~/environment/ip | awk -Fv '/vm_2/{print $1}')
NODE3=$(~/environment/ip | awk -Fv '/vm_3/{print $1}')

# CONFIGURANDO O MASTER utilizando o KUBEADM INIT:
echo "sudo hostnamectl set-hostname master" >> master.sh
echo "kubeadm version" >> master.sh
echo "sudo kubeadm config images pull" >> master.sh
echo "sudo kubeadm init" >> master.sh
#	Configurar o cliente kubectl:
echo "mkdir -p $HOME/.kube" >> master.sh
echo "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config" >> master.sh
echo "sudo chown $(id -u):$(id -g) $HOME/.kube/config" >> master.sh
#echo "source <(kubectl completion bash)" >> master.sh

# validar
#cat master.sh

# Configurar via SSH
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@MASTER 'bash -s' < config_master.sh
# Configurar a rede do cluster:
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@MASTER 'bash -s' < config_network_weave.sh

### CONFIGURANDO OS NODES utilizando o KUBEADM JOIN:

# Exemplo:
# kubeadm join 10.0.1.169:6443 --token fdwf9o.om0jvrom7uv3eeg4 \
#    --discovery-token-ca-cert-hash sha256:46abcfc7e371878b78f1071a7e396a3b1f1e851cbec76e65f0030d3f73411fd1
echo "Copie e cole 2 linhas com KUBEADM JOIN exibido acima: (digite ENTER PARA CONCLUIR)"
read TOKEN
read ENTER

echo "sudo hostnamectl set-hostname worker1" >> worker1.sh
echo "sudo hostnamectl set-hostname worker2" >> worker2.sh
echo "sudo hostnamectl set-hostname worker3" >> worker3.sh

echo "sudo $TOKEN $ENTER" >> worker1.sh
echo "sudo $TOKEN $ENTER" >> worker2.sh
echo "sudo $TOKEN $ENTER" >> worker3.sh

# validar
#cat worker1.sh

ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$NODE1 'bash -s' < worker1.sh
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$NODE2 'bash -s' < worker2.sh
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$NODE3 'bash -s' < worker3.sh

### CONFIGURANDO OS VOLUMES 
ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@MASTER 'bash -s' < config_volume_portworx.sh
