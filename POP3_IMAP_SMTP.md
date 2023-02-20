## POP3
    
    - Nhận email từ một server từ xa và gửi tới local client
    - Là giao thức client-server 1 chiều
    - Được coi là một dịch vụ "stor and forward"
        + 110: mặc định không mã hóa
        + 995: sd khi cần kết nối bằng POP3 an toàn
    - Work
        + Bắt đầu bằng việc nghe trên cổng TCP 110
            => client thiết lập kết nối TCP với server host
            => máy chủ POP3 gửi lời chào
            => phiên đi vào trạng thái ủy quyền
        + Trong trạng thái giao dịch => các lệnh và phản hồi trao đổi máy client và server
        + Khi client ban hành lệnh quit
            => phiên đi vào trạng thái update
            => server POP3 phát hành bất cứ tài nguyên nào trong trạng thái giao dịch
            => "goodbye"
            => đóng kết nối TCP
        + Phiên POP3 nhập tình trạng update => server xóa tin
        
## IMAP

    1. Send email: SMTP xác định cách gửi tin nhắn
        - Connect TCP giữa client và email server
            => Connect: server biết để chờ email
        - Client gửi seri lệnh tới server
        - Email server sử dụng một chương trình riêng gọi là MTA
            => check xem bản ghi DNS của email
            => tìm địa chỉ IP của người nhận
        - SMTP tìm kiếm 1 bản ghi MX tương ứng với domain name của người nhận. Nếu ở đây là bản ghi MX => email được gửi tới email server tương ứng
        
    2. Retrieving email: IMAP xác định cách nhận
        - Email có thể truy cập tới email client và đọc từ bất kì thiết bị nào 
        - Vì IMAP là trung gian giữa email client và email server => email chỉ có thể truy cập tới một kết nối Internet
        - Đăng nhập email client => client connect với email server để nhận tin nhắn
        
## POP3&IMAP

| IMAP | POP3 |
|------|------|
| Truy cập mail từ bất kì thiết bị nào | Theo mặc định, email chỉ có thể truy cập từ thiết bị download nó|
| Server lưu trữ email, IMAP hoạt động như một trung gian giữa server và client| Sau khi download => email sẽ bị xóa từ server, trừ khi được cấu hình khác|
| Không thể truy cập offline | Có thể truy cập offline |
| Body không thể download đến khi người dùng click, nhưng dòng chủ đề và tên người dùng thì nhanh chóng được hiển thị trong email client | download mặc định => tn có thể mất nhiều thời gian để load|
| IMAP đòi hỏi nhiều khoảng trống server vì email thì không auto delete từ server | POP3 bảo tồn lưu trữ server vì mail thì auto delete từ server|

## SMTP

    - Khi một SMTP server được thiết lập 
        => email client có thể connect và truyền thông với nó
    - Khi người dùng "send" => email client mở một SMTP connect (SMTP được xđ dựa trên TCP)
    - SMTP sử dụng dòng lệnh để giao tiếp
    - MTA check xem cả client và server có cùng trên dải miền không
        + Nếu cùng => gửi email ngay
        + Nếu không => server sử dụng DNS để nhận dạng domain của người nhận và sau đó gửi

  ![](https://i.imgur.com/WqiVJ60.png)

    - 354: tất cả tn sẽ được gửi lên SMTP server
    - 221: đã đóng kết nối thành công
    
### Một số lỗi SMTP thường gặp
    
    + 4.X.X Persistent Transient Failure: Có lỗi tạm thời với máy chủ thư. Việc lặp lại lệnh 1l nữa có thể loại bỏ lỗi
    + 5.X.X Permanent Error: Kết nối SMTP đã giảm => nếu thử lặp lại lệnh 1l nữa vẫn có thể dẫn đến cùng một lỗi
    
