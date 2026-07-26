```ruby 
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp-education/ubuntu-24-04"
  config.vm.hostname = "ubuntu-24-netology"
  config.vm.network "private_network", ip: "192.168.56.20"
  config.vm.synced_folder ".", "/vagrant"
  
  # Проброс порта для VNC
  config.vm.network "forwarded_port", guest: 5900, host: 5900
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "ubuntu-24-netology"
    vb.gui = false  # Оставляем без GUI в VirtualBox
  end
  
  config.vm.provision "shell", inline: <<-SHELL
    # Настройка пользователей
    echo "root:root123" | chpasswd
    if ! id "admin" &>/dev/null; then
      useradd -m -s /bin/bash admin
      echo "admin:admin123" | chpasswd
      usermod -aG sudo admin
    fi
    
    # Установка VNC сервера и минимального GUI
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 xfce4-goodies
    apt-get install -y tigervnc-standalone-server firefox
    
    # Настройка VNC
    mkdir -p /home/admin/.vnc
    echo "admin123" | vncpasswd -f > /home/admin/.vnc/passwd
    chown -R admin:admin /home/admin/.vnc
    chmod 600 /home/admin/.vnc/passwd
    
    # Создание скрипта запуска VNC
    cat > /home/admin/.vnc/xstartup << 'EOF'
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_MENU_PREFIX="xfce-"
exec startxfce4
EOF
    
    chmod +x /home/admin/.vnc/xstartup
    chown admin:admin /home/admin/.vnc/xstartup
    
    # Запуск VNC сервера
    sudo -u admin vncserver :0 -geometry 1024x768 -depth 24
    
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh
    
    echo "VNC сервер установлен!"
    echo "Подключитесь через VNC клиент к: 192.168.56.20:5900"
    echo "Пароль VNC: admin123"
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