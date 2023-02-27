## DNS (Domain Name System)

- DNS là hệ thống phân giải tên miền, là nơi internet domain name được định vị dịch sang địa chỉ IP 
    
        VD: "google.com" => 8.8.8.8
        
![](https://i.imgur.com/nL56lfX.png)

- Khi người dùng enter 1 địa chỉ của một browser DNS làm việc ngay lập tức
        => search thông qua Internet để tìm đ/c IP liên kết với tên miền
        => hướng dẫn browser của ng dùng để connect
        
- Bước đầu DNS thực hiện là gửi 1 truy vấn DNS đến 1 số máy chủ DNS.
    - Một DNS gồm nhiều máy chủ được phân phối trên toàn cầu trên một mạng DNS, lưu trữ thư mục địa chỉ IP một cách phân tán
- Tất cả DNS server làm việc cùng nhau để tham gia vào hàng tỷ tên miền yêu cầu
- Chủ yếu có 4 máy chủ làm việc cùng nhau để dịch địa chỉ website sang địa chỉ IP có thể đọc được trên máy tính cụ thể là:
        + DNS resolver Server: là máy chủ dịch hầu hết các quy trình trong dịch 1 domain sang đ/c IP. Nó nhận truy vấn DNS và lần lượt hoạt động giống như một máy khách để truy vấn 3 DNS server khác
        + Root Server: đầu tiên nó truy vấn root server và root server trả lời truy vấn bằng cách trả lại đ/c IP của TLD server (.com, .net, .org)
        + Top-Lever Domain (TLD): 1 TLD server lưu trữ thông tin cho domain của nó, và sẽ return địa chỉ IP của Authoritation Name Server cho DNS resolver.
        + Authoritative Name Server

#### Address Record (A Record)

- A record là một bản ghi DNS được sử dụng để trỏ một domain name hoặc tên miền phụ tới một địa chỉ IP tĩnh
- A record chỉ định IP nào được chỉ định cho một tên miền nhất định 
- Tất cả các máy chủ kết nối trên Internet được thiết kế một địa chỉ IP cụ thể. Bản ghi A liên kết tên vào đ/c IP của server
        => cho phép mọi người sử dụng tên miền dễ nhớ thay vì địa chỉ IP khó nhớ khi comment website. 
               VD. Người dùng có thể type địa chỉ 216.168.224.69 vào thanh địa chỉ để truy cập trang chủ của google hoặc có thể truy cập www.goole.com
- Người dùng có thể thiết lập bản ghi A bằng các công cụ DNS cụ thể, nơi mà có thể khác nhau giữa người dùng

#### MX Record

- MX record là một bản ghi trong DNS. Nó thực hiện việc định vị máy chủ mail cho tên miền. Một tên miền có thể gán nhiều MX record
=> Dù email tạm thời bị gián đoạn họăc không hoạt động trong một thời gian, nhưng dữ liệu vẫn k hề bị mất

#### TXT record

- Hầu hết các DNS record đều chứa dữ liệu bằng ngôn ngữ máy. Mặt khác, bản ghi TXT cho phép thêm các hướng dẫn cả người và máy có thể đọc được
- Loại record này phục vụ nhiều mục đích khác nhau:
     + Ngăn chặn spam email
     + Xác minh quyền sở hữu miền và các chính sách khung
     + Cung cấp thông tin chung và đầu mối liên hệ miền
- TXT record không dành cho lượng lớn dữ liệu. Nếu giá trị dài hơn 255 ký tự, cần chia giá trị thành nhiều phần với mỗi phần trên 255 ký tự được đặt trong dấu ngoặc kép " " => sau đó cả 2 sẽ được thêm vào TXT record

 ##### 1. Sử dụng TXT record để ngăn chặn thư rác

- TXT record hoạt động như một trình xác thực mail. TXT record thiết lập một email có nguồn đáng tin cậy vì nó bao gồm tất cả máy chủ được ủy quyền để gửi thư thay mặt cho một miền
- Được sử dụng để giữ thông tin khóa công khai và lưu trữ các chính sách khác nhau, chẳng hạn như xác thực thông báo dựa trên miền báo cáo và tuân thủ "DMARC" và khung chính sách người gửi (SPF)

##### 2. TXT record để xác minh quyền sở hữu miền
##### 3. TXT record để đảm bảo bảo mật email

- TXT record với Google Workspace để ngăn lừa đảo, gửi thư rác và các hoạt động độc hại khác
     + SPF record bảo vệ miền không bị sử dụng để gửi thư rác
     + DKIM sử dụng mã hóa để bảo mật nội dung mail
     + DMARC: cho phép kiểm soát các chính sách SPF,  DKIM
     + MFA-STS: tăng tính bảo mật cho các kết nối SMTP khi cả máy chủ gửi và nhận đều sử dụng tiêu chuẩn này

#### DKIM

- Một bản ghi DKIM là một bản ghi DNS TXT được định dạng đặc biệt, nó lưu trữ khóa công khai mà mail server sẽ nhận để xác minh chữ kí của tin nhắn
- DKIM là một chuẩn bảo mật mà giúp phát hiện các tin nhắn có bị thay đổi trong quá trình vận chuyển thư giữa gửi và nhận thư
- Một bản ghi DKIM được hình thành bởi 1 tên, version, loaị key và chính chìa khóa công khai, và thường được cung cấp bởi nhà cung cấp đang gửi email của bạn
- DKIM xác nhận tính hợp pháp với tư cách là người gửi 
     + Email giả mạo từ các miền đáng tin cậy là môt kỹ thuật phổ biến cho các chiến dịch spam và lửa đảo độc hại, và DKIM khiến cho việc giả mạo email từ các miền sử dụng nó khó khăn hơn
     + Mặc dù DKIM không bắt buộc nhưng các email được ký hợp đồng với DKIM có vẻ hợp pháp hơn vói người nhận của bạn và có ít khả năng kết thúc trong các thư mục rác hoặc thư rác
- Nó giúp xây dựng danh tiếng lâu dài của bạn 
     + Môt lợi ích bổ sung của DKIM là ISP sử dụng để xây dựng danh tiếng miền theo thời gian

#### SPF record
- SPF record giúp chứng minh một email thực sự đến từ các mail server tên miền của bạn
- Nếu tên miền không có SPF record, một số người nhận có thể từ chối tin nhắn bởi họ không thể chắc chắn tin nhắn này đến từ một server mail được ủy quyền hay không?
- SPF record là một loại bản ghi của hệ thống phân giải tên miền DNS. Bản ghi này đi cùng để xác định mail server có quyền gửi email đại diện cho tên miền của bạn. SPF ra đời với mục đích ngăn chặn tin nhắn mạo danh từ địa chỉ tên miền. Người nhận có thể xác định nội dung tin nhắn đến từ tên miền của bạn và được máy chủ mail cho phép hay chưa
- SPF record tường được xác định bằng cách sử dụng định dạng TXT

#### DMARC (Domain-based Message Authentication Reporting and Conformance)

- Báo cáo xác thực tin nhắn dựa trên tên miền và sự phù hợp
- DMARC là một hệ thống xác thực email được thiết kế để bảo vệ miền của email công ty khỏi được sử dụng để giả mạo email, lừa đảo và các tội phạm mạng khác. DMARC tận dụng SPF và DKIM
- DMARC có thêm một chức năng quan trọng => khi một chủ sở hữu xuất bản một bản ghi DMARC vào hồ sơ DNS => họ sẽ hiểu về người đang gửi email thay mặt cho tên miền => chủ sở hữu sẽ  kiểm soát email được gửi thay mặt anh ta
