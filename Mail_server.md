# Mailserver ubuntu using postfix dovecot and roundcube
* MAIL SERVER
* Domain: anthanh264.site
* OS: Ubuntu 22.04
* Hostname : mail 
* FQDN: mail.anthanh264.site
* IP: 61.14.233.93
* DNS  Record 



| NAME   | TYPE  | CONTENT                                        |
| ------ | ------ | --------------------------------------------------------- |
| _dmarc | TXT    | v=DMARC1; p=reject; rua=mailto:postmaster@anthanh264.site |
| @      | TXT    | v=spf1 a mx ip4:61.14.233.93 ?all                         |
| @      | MX     | mail.anthanh264.site                                      |
| mail   | A      | 61.14.233.93                                              |
| @      | A      | 61.14.233.93                                              |

## LAMP Required (Linux, Apache, MySQL, PHP)
### Update 
```
sudo apt update && sudo apt -y upgrade
```
### Install Apache Webserver
```
sudo apt install -y apache2
```
### Install a Database Server
```
sudo apt install -y mariadb-server mariadb-client
```
```
sudo mysql_secure_installation
```
### Install PHP
```
sudo apt install -y php
```
```
sudo apt install -y php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl}
```
### Get SSL certificate from Let's Encrypt
```
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --apache
sudo certbot renew --dry-run
```
### MAIL SERVER SETUP
```
hostnamectl set-hostname mail.anthanh264.site
mysql -u root – p 
CREATE DATABASE maildb;
CREATE USER 'mailuser'@'localhost' IDENTIFIED BY 'mailPWD'; 
GRANT ALL PRIVILEGES ON maildb.* TO 'mailuser'@'localhost';  
FLUSH PRIVILEGES;
USE maildb;

CREATE TABLE virtual_Status(
	status_id INT NOT NULL,
	status_desc VARCHAR(50) NOT NULL,
	status_note VARCHAR(100),
	PRIMARY KEY (status_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

### Table Virtual Domain
CREATE TABLE virtual_Domains( 
	domain_name VARCHAR(100) not null,
	domain_desc VARCHAR(100) not null,
	status_id INT NOT NULL DEFAULT 1,
PRIMARY KEY (domain_name), 
FOREIGN KEY (status_id) REFERENCES virtual_Status(status_id) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

### Table Virtual Users
CREATE TABLE virtual_Users (
	domain_name VARCHAR(100) not null,
	email VARCHAR(100) NOT NULL,
	password VARCHAR(106) NOT NULL,
	fullname VARCHAR(50) NOT NULL,
	department VARCHAR(50) NOT NULL,
	status_id INT NOT NULL DEFAULT 1,
PRIMARY KEY (email),
FOREIGN KEY (domain_name) REFERENCES virtual_Domains(domain_name) ON DELETE CASCADE,
FOREIGN KEY (status_id) REFERENCES virtual_Status(status_id) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

### Table Virtual Aliases
CREATE TABLE virtual_Aliases (
	domain_name VARCHAR(100) not null,
	source VARCHAR(100) NOT NULL,
	destination TEXT NOT NULL,
	status_id INT NOT NULL DEFAULT 1,
PRIMARY KEY (source),
FOREIGN KEY (domain_name) REFERENCES virtual_Domains(domain_name) ON DELETE CASCADE,
FOREIGN KEY (status_id) REFERENCES virtual_Status(status_id) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO virtual_Status (status_id,status_desc) VALUES ('1','Enable');

INSERT INTO virtual_Domains (domain_name,domain_desc) VALUES ('anthanh264.site','ANTHANH264.SITE');

INSERT INTO virtual_Users (domain_name,email,password,fullname,department) VALUES ('anthanh264.site','test1@anthanh264.site',TO_BASE64(UNHEX(SHA2('test1', 512))),'Test 1','Test');

INSERT INTO virtual_Users (domain_name,email,password,fullname,department) VALUES ('anthanh264.site','test2@anthanh264.site',TO_BASE64(UNHEX(SHA2('test2', 512))),'Test 2','Test');

INSERT INTO virtual_Aliases (domain_name,source,destination) VALUES ('anthanh264.site','group-test@anthanh264.site','test1@anthanh264.site,test2@anthanh264.site');

sudo apt postfix postfix-mysql -y
# Chọn InternetSite điền domain: anthanh264.site
systemctl start postfix
systemctl enable postfix
cd /etc/postfix/
mv main.cf main.cf.backup
vi main.cf 
# Sửa nội dung thành như sau: https://raw.githubusercontent.com/anthanh264/linuxsetupbasic/main/main.cf.md

vim virtual-domains.cf

user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT 1 FROM virtual_Domains WHERE domain_name='%s' and status_id=1

### Virtual Users

vim virtual-users.cf

user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT 1 FROM virtual_Users WHERE email='%s' and status_id=1

### Virtual Aliases

vim virtual-aliases.cf

user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT destination FROM virtual_Aliases WHERE source='%s' and status_id=1

vim virtual-email2email.cf

user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT email FROM virtual_Users WHERE email='%s' and status_id=1

chmod -R o-rwx /etc/postfix 
postmap -q anthanh264.site mysql:/etc/postfix/virtual-domains.cf 

system restart postfix

sudo apt ufw
ufw enable
ufw status 
ufw allow 110
ufw allow 22
ufw allow 25
ufw allow 80
ufw allow 443
telnet mail.anthanh264.site 25
ehlo mail.anthanh264.site
mail from:<root@anthanh264.site>
rcpt to:<anthanh264@yopmail.com>
data
noidungoday
.
quit
mkdir /var/mail/anthanh264.site
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/mail
chown -R vmail:vmail /var/mail/
apt install dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql -y 
systemctl restart dovecot
systemctl enable dovecot
vi /etc/dovecot/dovecot.conf
* Go to line 25 add protocols = imap pop3 lmtp
* Uncomment line 30 
* Uncomment line 98
vi /etc/dovecot/dovecot-sql.conf.ext
* Go to line 32 uncomment and add : driver = mysql
* Go to line 75 and add: connect = host=127.0.0.1 dbname=maildb user=mailuser password=mailPWD
* Go to line 81 and exit: default_pass_scheme = SHA512 
* Go to line 110 and add: password_query = SELECT email as user, password FROM virtual_Users WHERE email='%u' and status_id=1;
vi /etc/dovecot/conf.d/10-mail.conf
* Comment line 30 and add mail_localtion = mailldir:/var/mail/%d/%n/
* Go to line 114 and uncomment it
vi /etc/dovecot/conf.d/10-auth.conf
* Go to line 10 uncomment and edit mail_location=disable_plaintext_auth=no
* Go to line 100 uncomment and edit auth_mechanisms = plain login
* Go to line 122 & 123 ensure it's uncomment 

vi /etc/dovecot/conf.d/auth-sql.conf.ext
* Comment lines 19,20,21,22
* Uncomment 27,28,29,30 
* Edit line 29: args = uid=vmail home=/var/vmail/%d/%n
vi /etc/dovecot/conf.d/10-master.conf
* Link to sample file https://raw.githubusercontent.com/anthanh264/linuxsetupbasic/main/10-master.conf.md
vi /etc/dovecot/conf.d/10-ssl.conf
* Go to line 6 and edit ssl = no
* Uncomment lines 12 and 13

systemctl restart dovecot
vi /etc/postfix/main.cf
* Add this line to end file
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
systemctl restart postfix

telnet mail.anthanh264.site 25
user test1@anthanh264.site
pass test1
```
