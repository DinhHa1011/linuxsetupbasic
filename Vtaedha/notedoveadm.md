```


doveadm fetch -u test1@anthanh264.site "mailbox date.sent" \mailbox-guid 0514a7185a00fb639b1800006ba78add uid 2
```
## fetch
Lệnh fetch data nội dung và metadata của mail 
Cấu trúc : doveadm fetch -u <Username> "<Tên mailbox> <Trường cần lọc>" \mailbox-guid <GUID> uid <UID>
<Tên mailbox>: trong file 10-mail.conf ở /etc/dovecot/conf.d
<Trường cần lọc>: bên tiếng anh là field xem ở [đây](https://wiki.dovecot.org/Tools/Doveadm/Fetch#section_synopsis:~:text=logged%20in%20user.-,Arguments,-%E2%98%9C) 
GUID và UID lấy từ câu lệnh doveadm search 


![](https://i.imgur.com/VbQkBjp.png)

![](https://i.imgur.com/9LRetdO.png)

## deduplicate
```
doveadm -f table fetch -u test2@anthanh264.site 'guid uid' mailbox INBOX | sort 
```  
Câu lệnh fetch list mail 
```
doveadm deduplicate -u test2@anthanh264.site mailbox INBOX
doveadm -f table fetch -u test2@anthanh264.site 'guid uid' mailbox INBOX | sort
```
Dùng lệnh deduplicate để lọc trùng xóa đi cái trùng mới nhất để lại cái cũ nhất 
    
    
    
    doveadm fetch -u test1@anthanh264.site "mailbox date.sent" \mailbox-guid 0514a7185a00fb639b1800006ba78add uid 2

//Lệnh fetch data nội dung và metadata của mail 
Cấu trúc : doveadm fetch -u <Username> "<Tên mailbox> <Trường cần lọc>" \mailbox-guid <GUID> uid <UID>
<Tên mailbox>: trong file 10-mail.conf ở /etc/dovecot/conf.d
<Trường cần lọc>: bên tiếng anh là field xem ở đây https://wiki.dovecot.org/Tools/Doveadm/Fetch#section_synopsis:~:text=logged%20in%20user.-,Arguments,-%E2%98%9C 
GUID và UID lấy từ câu lệnh doveadm search 

doveadm move -u test1@anthanh264.site BEFORE mailbox INBOX Archives \ 01-Mar-2023 SINCE 01-Feb-2023
doveadm move -u dinhha1011@anthanh264.site Archives\2023 mailbox INBOX BEFORE\ 01-Mar-2023 SINCE 01-Feb-2023

doveadm move -u dinhha1011@anthanh264.site Archives mailbox INBOX BEFORE \01-Mar-2023 SINCE 01-Feb-2023

doveadm -f table fetch -u test2@anthanh264.site 'guid uid' mailbox INBOX | sort 
Câu lệnh fetch list mail 

doveadm deduplicate -u test2@anthanh264.site mailbox INBOX
doveadm -f table fetch -u test2@anthanh264.site 'guid uid' mailbox INBOX | sort

Dùng lệnh deduplicate để lọc trùng xóa đi cái trùng mới nhất để lại cái cũ nhất 

doveadm expunge -u test1@anthanh264.site mailbox Inbox savedbefore 2d
Xóa mail inbox đã lưu trc đó 2 ngày

doveadm fetch -u test1@anthanh264.site 'uid flags' mailbox  uid 3
doveadm flags remove -u test1@anthanh264.site Seen mailbox dovecot uid 81563