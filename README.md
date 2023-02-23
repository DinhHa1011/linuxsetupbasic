
## NOTE FOR VTAEDHA

### IBus Bamboo - Bộ gõ tiếng Việt cho Linux

```sh
sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo
sudo apt-get update
sudo apt-get install ibus ibus-bamboo --install-recommends
ibus restart
# Đặt ibus-bamboo làm bộ gõ mặc định
env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" && gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"
init 6
```
### NOTEPADQQ
```sh
sudo add-apt-repository ppa:notepadqq-team/notepadqq
sudo apt-get update
sudo apt-get install notepadqq
```

### CHROME
```sh
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
```

### Office 2010 via playonlinux
Link download Office Setup: https://archive.org/download/sw-dvd-5-office-professional-plus-2010-w-32-english-mlf-x-16-52536/SW_DVD5_Office_Professional_Plus_2010_W32_English_MLF_X16-52536.ISO
```sh
sudo apt install winbind
sudo apt-get install playonlinux
```
Tải file ISO trên về giải nén ra (click chuột phải file chọn exact here) 
Mở playonlinux -> Install a program -> gõ office tìm tới office 2010 -> install -> browser setup file chọn về setup.exe trong thư mục mới giải nén file ISO trên 
Next chờ playonlinux tự xử. 

### Generate a Public Key from a Private Key Using ssh-keygen

```sh
 ssh-keygen -f <PRIVATE_KEY_FILE>.pem -y
```
### Create a pem file to login without password and without copy local keys to remote server

1. Login with account user (not root)

```
mkdir pem
cd pem
ssh-keygen -b 2048 -f identity -t rsa
```

2. Copy public key contents to authorized_keys

```
cat identity.pub >> ~/.ssh/authorized_keys
```

3. Disable Password Authentication

```
sudo nano /etc/ssh/sshd_config
```

Change to no to disable tunnelled clear text passwords

PasswordAuthentication no

4. Restart SSH

```
sudo service ssh restart
```

5. Download your private key to client side

```
cat ~/.ssh/pem/identity
```

6. Set permission for pem on your local

```
sudo chmod 600 identity.pem
```

7. Test login

```
ssh -i identity.pem user@vps-ip
```

