```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp-education/ubuntu-24-04"
  config.vm.hostname = "ubuntu-24-netology"
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.synced_folder ".", "/vagrant"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3072"  # Меньше памяти для легковесного GUI
    vb.cpus = 2
    vb.name = "ubuntu-24-netology"
    vb.gui = true
  end
  
  config.vm.provision "shell", inline: <<-SHELL
    # Настройка пользователей
    echo "root:root123" | chpasswd
    if ! id "admin" &>/dev/null; then
      useradd -m -s /bin/bash admin
      echo "admin:admin123" | chpasswd
      usermod -aG sudo admin
    fi
    
    # Установка Xfce (легковесный DE)
    echo "Устанавливаем Xfce..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 xfce4-goodies
    apt-get install -y firefox
    
    # Установка дисплей менеджера
    apt-get install -y lightdm
    
    # Настройка автоматического запуска Xfce
    echo "exec startxfce4" > /home/admin/.xinitrc
    chown admin:admin /home/admin/.xinitrc
    
    # Настройка автоматического входа
    mkdir -p /etc/lightdm/lightdm.conf.d
    cat > /etc/lightdm/lightdm.conf.d/50-auto-guest.conf << EOF
[Seat:*]
autologin-user=admin
autologin-user-timeout=0
EOF
    
    # Включаем дисплей менеджер
    systemctl enable lightdm
    systemctl set-default graphical.target
    
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh
    
    echo "Xfce установлен! Перезагрузите: vagrant reload"
  SHELL
end
```
## После установки:

1. **Перезагрузите машину**:

```bash
vagrant reload
```

2. **Или если нужно пересоздать**:
```bash
vagrant destroy -f
vagrant up
```

**Рекомендую 
- Вариант 1 (полный Ubuntu Desktop) если у вас достаточно ресурсов
- Вариант 2 (Xfce) для экономии памяти.