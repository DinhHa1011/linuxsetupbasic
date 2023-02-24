# Mailserver ubuntu using postfix dovecot and roundcube
* MAIL SERVER
* Domain: anthanh264.site
* OS: Ubuntu 22.04
* Hostname : mail 
* FQDN: mail.anthanh264.site
* IP: 61.14.233.93
* DNS  Record 
ID	Name	Type	Content
1	@	TXT	v=spf1 a mx ip4:61.14.233.93 ?all
2	@	A	61.14.233.93
3	mail	A	61.14.233.93
4	@	MX	mail.anthanh264.site
5	_dmarc	TXT	v=DMARC1; p=reject; rua=mailto:postmaster@anthanh264.site
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