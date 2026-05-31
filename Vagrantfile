ANSIBLE_PUB_KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFQOygh2It0BPr+9ZLpBPE883D9km4PyRxpA34SnPa+ ansible-lab4"
TEACHER_HASH = '/5JXF1eouoHIMwxNGCfuG4nGC3isoePoU9eyHIsLH6QOdWNBHc0'

SETUP = <<-SHELL
  id ansible 2>/dev/null || useradd -m -s /bin/bash ansible
  usermod -aG sudo ansible
  echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
  mkdir -p /home/ansible/.ssh
  echo "#{ANSIBLE_PUB_KEY}" >> /home/ansible/.ssh/authorized_keys
  chmod 700 /home/ansible/.ssh
  chmod 600 /home/ansible/.ssh/authorized_keys
  chown -R ansible:ansible /home/ansible/.ssh
  id teacher 2>/dev/null || useradd -m -s /bin/bash teacher
  usermod -aG sudo teacher
  echo 'teacher:12345678' | chpasswd
  echo 'teacher ALL=(ALL) ALL' > /etc/sudoers.d/teacher
  echo '25' > /home/student/gradebook
  apt-get update -q
  apt-get install -y -q curl ca-certificates python3
SHELL

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.define "worker" do |worker|
    worker.vm.hostname = "lab4-worker"
    worker.vm.network "private_network", ip: "192.168.56.10"
    worker.vm.provider "virtualbox" do |vb|
      vb.name = "lab4-worker"
      vb.memory = 2048
      vb.cpus = 2
    end
    worker.vm.provision "shell", inline: SETUP
  end
  config.vm.define "db" do |db|
    db.vm.hostname = "lab4-db"
    db.vm.network "private_network", ip: "192.168.56.11"
    db.vm.provider "virtualbox" do |vb|
      vb.name = "lab4-db"
      vb.memory = 1024
      vb.cpus = 1
    end
    db.vm.provision "shell", inline: SETUP
  end
end