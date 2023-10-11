#!/bin/sh
############################################
##### Replace : anthanh264.site = YOUR-DOMAIN  #####
############################################
hostname --fqdn > /etc/mailname
echo "Installing programs..."
apt install -y dialog apache2 postfix postfix-mysql mariadb-server mariadb-client php dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql
echo "Apache, Postfix, MySQL, Dovecot | DONE"
apt install -y php
apt install -y php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl}
echo "PHP | DONE"
echo "Configuring MySQL"
echo "Leave current password empty
Set root password N
Remove anonymous users Y
Disallow root login remotely N
Remove test database and access to it Y
Reload privilege tables now Y"
mysql_secure_installation
echo "Creating database"
echo "\
CREATE DATABASE maildb;
CREATE USER 'mailuser'@'localhost' IDENTIFIED BY 'mailPWD'; 
GRANT ALL PRIVILEGES ON maildb.* TO 'mailuser'@'localhost';
FLUSH PRIVILEGES;
USE maildb;
CREATE TABLE \`virtual_Status\` (
	\`status_id\` INT NOT NULL,
	\`status_desc\` VARCHAR(50) NOT NULL,
	\`status_note\` VARCHAR(100),
	PRIMARY KEY (\`status_id\`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE \`virtual_Domains\` ( 
	\`domain_name\` VARCHAR(100) not null,
	\`domain_desc\` VARCHAR(100) not null,
	\`status_id\` INT NOT NULL DEFAULT 1,
PRIMARY KEY (\`domain_name\`), 
FOREIGN KEY (\`status_id\`) REFERENCES \`virtual_Status\`(\`status_id\`) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE \`virtual_Users\` (
	\`domain_name\` VARCHAR(100) not null,
	\`email\` VARCHAR(100) NOT NULL,
	\`password\` VARCHAR(106) NOT NULL,
	\`fullname\` VARCHAR(50) NOT NULL,
	\`department\` VARCHAR(50) NOT NULL,
	\`status_id\` INT NOT NULL DEFAULT 1,
PRIMARY KEY (\`email\`),
FOREIGN KEY (\`domain_name\`) REFERENCES \`virtual_Domains\`(\`domain_name\`) ON DELETE CASCADE,
FOREIGN KEY (\`status_id\`) REFERENCES \`virtual_Status\`(\`status_id\`) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE \`virtual_Aliases\` (
	\`domain_name\` VARCHAR(100) not null,
	\`source\` VARCHAR(100) NOT NULL,
	\`destination\` TEXT NOT NULL,
	\`status_id\` INT NOT NULL DEFAULT 1,
PRIMARY KEY (\`source\`),
FOREIGN KEY (\`domain_name\`) REFERENCES \`virtual_Domains\`(\`domain_name\`) ON DELETE CASCADE,
FOREIGN KEY (\`status_id\`) REFERENCES \`virtual_Status\`(\`status_id\`) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO \`maildb\`.\`virtual_Status\` 
(\`status_id\`, \`status_desc\`, \`status_note\`) 
VALUES
(1, 'Enable', NULL);

INSERT INTO \`maildb\`.\`virtual_Domains\` 
(\`domain_name\`,\`domain_desc\`) 
VALUES 
('hadt.space','HADT.SPACE');

INSERT INTO \`maildb\`.\`virtual_Users\` 
(\`domain_name\`,\`email\`,\`password\`,\`fullname\`,\`department\`) 
VALUES 
('hadt.space','test1@hadt.space','JsZpzQgUrEDlModSshxKpkUNFileTuwwNWoGqRHCOYOq6+EtXaOO7r/BshO+ZQSY34QZGU1aJsfg\r\npQrxVoU8eQ==','Test 1','Test');

INSERT INTO \`maildb\`.\`virtual_Aliases\` 
(\`domain_name\`,\`source\`,\`destination\`) 
VALUES 
('hadt.space','group-test@hadt.space','test1@hadt.space,test2@hadt.space');
" | mysql -u root
echo "Config MYSQL | DONE"
echo "Configuring Postfix"
systemctl start postfix
systemctl enable postfix
cd /etc/postfix/
mv main.cf main.cf.backup
echo "# See /usr/share/postfix/main.cf.dist for a commented, more complete version

# Debian specific:  Specifying a file name will cause the first
# line of that file to be used as the name.  The Debian default
# is /etc/mailname.
#myorigin = /etc/mailname

smtpd_banner = $myhostname ESMTP $mail_name (HappyGhost)
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

readme_directory = no

# See http://www.postfix.org/COMPATIBILITY_README.html -- default to 2 on
# fresh installs.
compatibility_level = 2

###Enabling SMTP for authenticated users,and handing off authentication to Dovecot 

smtpd_sasl_auth_enable = yes

broken_sasl_auth_clients = yes

smtpd_sasl_authenticated_header = yes

virtual_transport = lmtp:unix:private/dovecot-lmtp

# Restrictions
smtpd_helo_restrictions =
        permit_mynetworks,
        permit_sasl_authenticated,
        reject_invalid_helo_hostname,
        reject_non_fqdn_helo_hostname
smtpd_recipient_restrictions =
        permit_mynetworks,
        permit_sasl_authenticated,
        reject_non_fqdn_recipient,
        reject_unknown_recipient_domain,
        reject_unlisted_recipient,
        reject_unauth_destination
smtpd_sender_restrictions =
        permit_mynetworks,
        permit_sasl_authenticated,
        reject_non_fqdn_sender,
        reject_unknown_sender_domain
smtpd_relay_restrictions =
        permit_mynetworks,
        permit_sasl_authenticated,
        defer_unauth_destination


#smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = mail.anthanh264.site
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = 
relayhost = 
mailbox_size_limit = 
recipient_delimiter = 
inet_interfaces = all
inet_protocols = ipv4
# Virtual domains, users, and aliases
# These files contain the connection information for the MySQL lookup tables created in the MySQL in the Part 2
virtual_mailbox_domains = mysql:/etc/postfix/virtual-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/virtual-users.cf
virtual_alias_maps = mysql:/etc/postfix/virtual-aliases.cf,
        mysql:/etc/postfix/virtual-email2email.cf

# Even more Restrictions and MTA params
disable_vrfy_command = yes
strict_rfc821_envelopes = yes
#smtpd_etrn_restrictions = reject
#smtpd_reject_unlisted_sender = yes
#smtpd_reject_unlisted_recipient = yes
smtpd_delay_reject = yes
smtpd_helo_required = yes
smtp_always_send_ehlo = yes
#smtpd_hard_error_limit = 1
smtpd_timeout = 30s
smtp_helo_timeout = 15s
smtp_rcpt_timeout = 15s
smtpd_recipient_limit = 40
minimal_backoff_time = 180s
maximal_backoff_time = 3h

# Reply Rejection Codes
invalid_hostname_reject_code = 550
non_fqdn_reject_code = 550
unknown_address_reject_code = 550
unknown_client_reject_code = 550
unknown_hostname_reject_code = 550
unverified_recipient_reject_code = 550
unverified_sender_reject_code = 550
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes" > /etc/postfix/main.cf

echo "## Postfix master process configuration file.  
smtp      inet  n       -       y       -       -       smtpd
# -o content_filter=spamassassin
#smtp      inet  n       -       y       -       1       postscreen
#smtpd     pass  -       -       y       -       -       smtpd
#dnsblog   unix  -       -       y       -       0       dnsblog
#tlsproxy  unix  -       -       y       -       0       tlsproxy
submission inet n       -       y       -       -       smtpd
  -o syslog_name=postfix/submission
#  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_tls_auth_only=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=$mua_client_restrictions
#  -o smtpd_helo_restrictions=$mua_helo_restrictions
#  -o smtpd_sender_restrictions=$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
smtps     inet  n       -       y       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=$mua_client_restrictions
#  -o smtpd_helo_restrictions=$mua_helo_restrictions
#  -o smtpd_sender_restrictions=$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
#628       inet  n       -       y       -       -       qmqpd
pickup    unix  n       -       y       60      1       pickup
cleanup   unix  n       -       y       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
#qmgr     unix  n       -       n       300     1       oqmgr
tlsmgr    unix  -       -       y       1000?   1       tlsmgr
rewrite   unix  -       -       y       -       -       trivial-rewrite
bounce    unix  -       -       y       -       0       bounce
defer     unix  -       -       y       -       0       bounce
trace     unix  -       -       y       -       0       bounce
verify    unix  -       -       y       -       1       verify
flush     unix  n       -       y       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       y       -       -       smtp
relay     unix  -       -       y       -       -       smtp
        -o syslog_name=postfix/$service_name
#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5
showq     unix  n       -       y       -       -       showq
error     unix  -       -       y       -       -       error
retry     unix  -       -       y       -       -       error
discard   unix  -       -       y       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       y       -       -       lmtp
anvil     unix  -       -       y       -       1       anvil
scache    unix  -       -       y       -       1       scache
postlog   unix-dgram n  -       n       -       1       postlogd
#
# ====================================================================
# Interfaces to non-Postfix software. Be sure to examine the manual
# pages of the non-Postfix software to find out what options it wants.
#
# Many of the following services use the Postfix pipe(8) delivery
# agent.  See the pipe(8) man page for information about ${recipient}
# and other message envelope options.
# ====================================================================
#
# maildrop. See the Postfix MAILDROP_README file for details.
# Also specify in main.cf: maildrop_destination_recipient_limit=1
#
maildrop  unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail argv=/usr/bin/maildrop -d ${recipient}
#
# ====================================================================
#
# Recent Cyrus versions can use the existing "lmtp" master.cf entry.
#
# Specify in cyrus.conf:
#   lmtp    cmd="lmtpd -a" listen="localhost:lmtp" proto=tcp4
#
# Specify in main.cf one or more of the following:
#  mailbox_transport = lmtp:inet:localhost
#  virtual_transport = lmtp:inet:localhost
#
# ====================================================================
#
# Cyrus 2.1.5 (Amos Gouaux)
# Also specify in main.cf: cyrus_destination_recipient_limit=1
#
#cyrus     unix  -       n       n       -       -       pipe
#  user=cyrus argv=/cyrus/bin/deliver -e -r ${sender} -m ${extension} ${user}
#
# ====================================================================
# Old example of delivery via Cyrus.
#
#old-cyrus unix  -       n       n       -       -       pipe
#  flags=R user=cyrus argv=/cyrus/bin/deliver -e -m ${extension} ${user}
#
# ====================================================================
#
# See the Postfix UUCP_README file for configuration details.
#
uucp      unix  -       n       n       -       -       pipe
  flags=Fqhu user=uucp argv=uux -r -n -z -a$sender - $nexthop!rmail ($recipient)
#
# Other external delivery methods.
#
ifmail    unix  -       n       n       -       -       pipe
  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r $nexthop ($recipient)
bsmtp     unix  -       n       n       -       -       pipe
  flags=Fq. user=bsmtp argv=/usr/lib/bsmtp/bsmtp -t$nexthop -f$sender $recipient
scalemail-backend unix	-	n	n	-	2	pipe
  flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store ${nexthop} ${user} ${extension}
mailman   unix  -       n       n       -       -       pipe
  flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py
  ${nexthop} ${user}" > /etc/postfix/master.cf

echo "user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT 1 FROM virtual_Domains WHERE domain_name='%s' and status_id=1" > /etc/postfix/virtual-domains.cf


echo "user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT 1 FROM virtual_Users WHERE email='%s' and status_id=1" > /etc/postfix/virtual-users.cf

echo "user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT destination FROM virtual_Aliases WHERE source='%s' and status_id=1" > /etc/postfix/virtual-aliases.cf

echo "user = mailuser
password = mailPWD
hosts = 127.0.0.1
dbname = maildb
query = SELECT email FROM virtual_Users WHERE email='%s' and status_id=1" > /etc/postfix/virtual-email2email.cf

chmod -R o-rwx /etc/postfix 

echo "Check 1 = OK "
postmap -q anthanh264.site mysql:/etc/postfix/virtual-domains.cf 
echo "Configure Postfix | DONE"
echo "Configuring Dovecot"
mkdir /var/mail/anthanh264.site
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/mail
chown -R vmail:vmail /var/mail/ 

systemctl restart dovecot
systemctl enable dovecot

mv /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.backup
mv /etc/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext.backup
mv /etc/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf.backup
mv /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.backup
mv /etc/dovecot/conf.d/auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext.backup
mv /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.backup
mv /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.backup
echo "!include_try /usr/share/dovecot/protocols.d/*.protocol
mail_debug = yes
auth_debug = yes
protocols = imap lmtp pop3
listen = *
namespace inbox {
    inbox = yes
    mailbox Drafts {
        special_use = \Drafts
        auto = subscribe
    }
    mailbox Junk {
        special_use = \Junk
        auto = subscribe
        autoexpunge = 30d
    }
    mailbox Sent {
        special_use = \Sent
        auto = subscribe
    }
    mailbox Trash {
        special_use = \Trash
    }
    mailbox Archive {
        special_use = \Archive
    }
}

!include_try local.conf
!include conf.d/*.conf" > /etc/dovecot/dovecot.conf

echo "driver = mysql
connect = host=127.0.0.1 dbname=maildb user=mailuser password=mailPWD
default_pass_scheme = SHA512 
password_query = SELECT email as user, password FROM virtual_Users WHERE email='%u' and status_id=1;
user_query = SELECT CONCAT('/var/mail','/','%d','/','%n') as home, 'vmail' as uid, 'vmail'as gid, CONCAT('/var/mail','/','%d','/','%n') as mail FROM virtual_Users WHERE email= '%u';
iterate_query = SELECT email as user FROM virtual_Users;" > /etc/dovecot/dovecot-sql.conf.ext

echo "##
## Authentication processes
##
disable_plaintext_auth = no
auth_mechanisms = plain login
!include auth-sql.conf.ext" > /etc/dovecot/conf.d/10-auth.conf

echo "##
## Mailbox locations and namespaces
##
mail_location = maildir:/var/mail/%d/%n/
namespace inbox {
  inbox = yes
}
mail_privileged_group = mail
protocol !indexer-worker {
}" > /etc/dovecot/conf.d/10-mail.conf

echo "# Authentication for SQL users. Included from 10-auth.conf.
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
  driver = static
  args = uid=vmail gid=vmail home=/var/vmail/%d/%n
}" > /etc/dovecot/conf.d/auth-sql.conf.ext

echo "service imap-login {
  inet_listener imap {
    port = 143
  }
  inet_listener imaps {
    #port = 993
    #ssl = yes
  }
}

service pop3-login {
  inet_listener pop3 {
    port = 110
  }
  inet_listener pop3s {
    #port = 995
    #ssl = yes
  }
}

service submission-login {
  inet_listener submission {
    #port = 587
  }
}

service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    mode = 0600
    user = postfix
    group = postfix
  }
}

service imap {
}

service pop3 {
}

service submission {
}

service auth {
  unix_listener auth-userdb {
    mode = 0600
    user = vmail
    #group = 
  }
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }
  user = dovecot
}

service auth-worker {
  user = vmail
}

service dict {
  unix_listener dict {
  }
}" > /etc/dovecot/conf.d/10-master.conf


echo "ssl = no
ssl_client_ca_dir = /etc/ssl/certs
ssl_dh = </usr/share/dovecot/dh.pem" > /etc/dovecot/conf.d/10-ssl.conf

echo "Configure Dovecot | DONE"

echo "Installing Roundcube"
apt install -y roundcube
mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.backup
echo "Configuring Roundcube"
echo "<VirtualHost *:80>
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

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" > /etc/apache2/sites-enabled/000-default.conf

systemctl restart postfix dovecot apache2

printf "\033[32m
  ______   _______  __    _  _______ 
|      | |       ||  |  | ||       |
|  _    ||   _   ||   |_| ||    ___|
| | |   ||  | |  ||       ||   |___ 
| |_|   ||  |_|  ||  _    ||    ___|
|       ||       || | |   ||   |___ 
|______| |_______||_|  |__||_______|
\033[0m"
printf "


Add these three records to your DNS TXT records on either your registrar's site
or your DNS server:
\033[31m
| NAME   | TYPE  | CONTENT                                                    |
| ------ | ------ | --------------------------------------------------------- |
| _dmarc | TXT    | v=DMARC1; p=reject; rua=mailto:postmaster@anthanh264.site |
| @      | TXT    | v=spf1 a mx ip4:YourServerIP mx:anthanh264.site ~all      |
| @      | MX     | mail.anthanh264.site                                      |
| mail   | A      | YourServerIP                                              |
| @      | A      | YourServerIP                                              |

\033[0m
"
echo -e "Webmail: \033[4m\033[32mhttp://anthanh264/mail\033[0m \033[0m"
printf "User:\033[32m test1@anthanh264.site\033[0m | Pass:\033[32m demo \033[0m \n"
