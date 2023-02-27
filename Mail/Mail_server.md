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
## MAIL SERVER SETUP
### Set Hostname
```
hostnamectl set-hostname mail.anthanh264.site
```
### Sử dụng mysql tạo database maildb, tạo user mailuser và cấp quyền
```
mysql -u root – p 
CREATE DATABASE maildb;
CREATE USER 'mailuser'@'localhost' IDENTIFIED BY 'mailPWD'; 
GRANT ALL PRIVILEGES ON maildb.* TO 'mailuser'@'localhost';  
FLUSH PRIVILEGES;
```
### Sử dụng mysql trên database maildb để tạo các bảng
```
USE maildb;
### Table Virtual_Status
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

```
### Thêm dữ liệu vào các bảng: Chú ý đổi anthanh264.site thành tên domain của bạn
```
INSERT INTO virtual_Status (status_id,status_desc) VALUES ('1','Enable');

INSERT INTO virtual_Domains (domain_name,domain_desc) VALUES ('anthanh264.site','ANTHANH264.SITE');

INSERT INTO virtual_Users (domain_name,email,password,fullname,department) VALUES ('anthanh264.site','test1@anthanh264.site',TO_BASE64(UNHEX(SHA2('test1', 512))),'Test 1','Test');

INSERT INTO virtual_Users (domain_name,email,password,fullname,department) VALUES ('anthanh264.site','test2@anthanh264.site',TO_BASE64(UNHEX(SHA2('test2', 512))),'Test 2','Test');

INSERT INTO virtual_Aliases (domain_name,source,destination) VALUES ('anthanh264.site','group-test@anthanh264.site','test1@anthanh264.site,test2@anthanh264.site');

EXIT;
```
### Cài Postfix
```
sudo apt install postfix postfix-mysql -y
#Chọn 2 Internet Site điền domain: anthanh264.site 
```
### Cấu hình postfix
```
systemctl start postfix
systemctl enable postfix
cd /etc/postfix/
mv main.cf main.cf.backup
vi main.cf 
```
##### Sửa nội dung file main.cf thành như sau: [main.cf](https://raw.githubusercontent.com/anthanh264/linuxsetupbasic/main/main.cf.md )

#### Tạo các file cần thiết cho postfix
```
vim virtual-domains.cf

user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT 1 FROM virtual_Domains WHERE domain_name='%s' and status_id=1


vim virtual-users.cf

user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT 1 FROM virtual_Users WHERE email='%s' and status_id=1


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
```
#### Cấp quyền thư mục postfix
```
chmod -R o-rwx /etc/postfix 
```
#### Câu lệnh test nếu kết quả trả về là 1 là oke
```
postmap -q anthanh264.site mysql:/etc/postfix/virtual-domains.cf 
```
#### Restart postfix để apply cấu hình
```
system restart postfix
```
### Cấu hình firewall
```
sudo apt install ufw
ufw enable
ufw status 
ufw allow 110
ufw allow 22
ufw allow 25
ufw allow 80
ufw allow 443
```
#### Test postfix 
Nếu chứ có telnet thì cài bằng lệnh sau
``` 
sudo apt install telnet 
```
```
telnet mail.anthanh264.site 25
ehlo mail.anthanh264.site
mail from:<root@anthanh264.site>
rcpt to:<anthanh264@yopmail.com>
data
noidungoday
.
quit
```
Dữ liệu mẫu trả về như thế này là oke
```
root@mail:~# telnet mail.anthanh264.site 25
Trying 61.14.233.93...
Connected to mail.anthanh264.site.
Escape character is '^]'.
220 mail.anthanh264.site ESMTP Postfix (HappyGhost)
ehlo mail.anthanh264.site
250-mail.anthanh264.site
250-PIPELINING
250-SIZE 10240000
250-ETRN
250-AUTH PLAIN LOGIN
250-AUTH=PLAIN LOGIN
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-DSN
250-SMTPUTF8
250 CHUNKING
mail from:<root@anthanh264.site>
250 2.1.0 Ok
rcpt to:<anthanh264@yopmail.com>
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
noidungoday
.
250 2.0.0 Ok: queued as 5AA8C437FE
quit
221 2.0.0 Bye
Connection closed by foreign host.
```
### DOVECOT
#### Tạo thư mục lưu mail và group vmail 
```
mkdir /var/mail/anthanh264.site
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/mail
chown -R vmail:vmail /var/mail/
```
#### Cài đặt dovecot
```
sudo apt install dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql -y 
systemctl restart dovecot
systemctl enable dovecot
```
#### Cấu hình dovecot
```
vi /etc/dovecot/dovecot.conf
* Go to line 25 and add protocols = imap pop3 lmtp
* Uncomment line 30 
* Uncomment line 98

vi /etc/dovecot/dovecot-sql.conf.ext
* Go to line 32 uncomment and add : 
driver = mysql
* Go to line 75 and add: 
connect = host=127.0.0.1 dbname=maildb user=mailuser password=mailPWD
* Go to line 81 and edit: 
default_pass_scheme = SHA512 
* Go to line 110 and add: 
password_query = SELECT email as user, password FROM virtual_Users WHERE email='%u' and status_id=1;

vi /etc/dovecot/conf.d/10-mail.conf
* Comment line 30 and add 
mail_location = maildir:/var/mail/%d/%n/
* Go to line 114 and uncomment it

vi /etc/dovecot/conf.d/10-auth.conf
* Go to line 10 uncomment and edit 
disable_plaintext_auth=no
* Go to line 100 uncomment and edit 
auth_mechanisms = plain login
* Go to line 122 & 123 ensure it's uncomment 

vi /etc/dovecot/conf.d/auth-sql.conf.ext
* Comment lines 19,20,21,22
* Uncomment 27,28,29,30 
* Edit line 29: 
args = uid=vmail gid=vmail home=/var/vmail/%d/%n

vi /etc/dovecot/conf.d/10-master.conf
* Link to sample file
https://raw.githubusercontent.com/anthanh264/linuxsetupbasic/main/10-master.conf.md

vi /etc/dovecot/conf.d/10-ssl.conf
* Go to line 6 and edit 
ssl = no
* Uncomment lines 12 and 13
```
#### Restart dovecot để apply cấu hình
```
systemctl restart dovecot
```
#### Chỉnh sửa để postfix làm việc với dovecot
```
vi /etc/postfix/main.cf

* Add this line to end file
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
```
#### Restart postfix để apply cấu hình
```
system restart postfix
```
#### Test Dovecot
```
telnet mail.anthanh264.site 110
user test1@anthanh264.site
pass test1
```
Dữ liệu mẫu trả về như thế này là oke
```
root@mail:~# telnet mail.anthanh264.site 110
Trying 61.14.233.93...
Connected to mail.anthanh264.site.
Escape character is '^]'.
+OK Dovecot (Ubuntu) ready.
user test1@anthanh264.site
+OK
pass test1
+OK Logged in.
```
## Roundcube
```
sudo apt install -y roundcube
````
* Chọn yes để cấu hình database cho roundcube
* Nhập pass mysql dành cho roundcube
```
vi /etc/apache2/site-enabled/000-default.conf
```
Thêm 
```
Alias /mail /usr/share/roundcube
```
vào trên dòng ErrorLog ${APACHE_LOG_DIR}/error.log

File 000-default.conf sẽ có dạng như thế này
```
<VirtualHost *:80>
	# The ServerName directive sets the request scheme, hostname and port that
	# the server uses to identify itself. This is used when creating
	# redirection URLs. In the context of virtual hosts, the ServerName
	# specifies what hostname must appear in the request's Host: header to
	# match this virtual host. For the default virtual host (this file) this
	# value is not decisive as it is used as a last resort host regardless.
	# However, you must set it for any further virtual host explicitly.
	#ServerName www.example.com

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html
	
  Alias /mail /usr/share/roundcube 
 
	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	# error, crit, alert, emerg.
	# It is also possible to configure the loglevel for particular
	# modules, e.g.
	#LogLevel info ssl:warn

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

	# For most configuration files from conf-available/, which are
	# enabled or disabled at a global level, it is possible to
	# include a line for only one particular virtual host. For example the
	# following line enables the CGI configuration for this host only
	# after it has been globally disabled with "a2disconf".
	#Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```
### Restart apache2 để apply cấu hình
```
systemctl restart apache2
```

## FINISHED
MAIL SERVER UBUNTU WITH POSTFIX, DOVECOT, ROUNDCUBE (Without SSL)
## TEST
Truy cập vào  http://mail.anthanh264.site/mail
* Username: test1@anthanh264.site
* Password: test1
* Server: mail.anthanh264.site
