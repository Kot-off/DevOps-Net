``` ruby
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp-education/ubuntu-24-04"
  config.vm.hostname = "ubuntu-24-netology"
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.synced_folder ".", "/vagrant"
  
  # Включить графический интерфейс в VirtualBox
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"  # Увеличиваем память для GUI
    vb.cpus = 2
    vb.name = "ubuntu-24-netology"
    vb.gui = true  # Включаем графический интерфейс
  end
  
  config.vm.provision "shell", inline: <<-SHELL
    # Настройка пользователей
    echo "root:root123" | chpasswd
    if ! id "admin" &>/dev/null; then
      useradd -m -s /bin/bash admin
      echo "admin:admin123" | chpasswd
      usermod -aG sudo admin
    fi
    
    # Установка Ubuntu Desktop
    echo "Устанавливаем графический интерфейс..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-desktop
    
    # Установка дополнительных утилит
    apt-get install -y firefox gedit gnome-terminal
    
    # Настройка автоматического входа для пользователя admin (опционально)
    mkdir -p /etc/lightdm/lightdm.conf.d
    cat > /etc/lightdm/lightdm.conf.d/50-auto-guest.conf << EOF
[Seat:*]
autologin-user=admin
autologin-user-timeout=0
EOF
    
    # Разрешаем парольную аутентификацию для SSH
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh
    
    echo "Графический интерфейс установлен!"
    echo "Перезагрузите машину: vagrant reload"
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