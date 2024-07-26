Percona XtraDB Cluster là một giải pháp mã nguồn mở hoàn toàn và có tính năng khả dụng cao cho Mysql.

Nó tích hợp Percona Server và Perocna XtraBackup với thư viện Galera cho phép sao chép đa nguồn đồng bộ.

Một cluster bao gồm các node, trong mỗi node chứa cùng một tập dữ liệu đực đồng bộ giữa các node. Cấu hình được đề xuất là có ít nhất 3 node, nhưng bạn cũng có thể có 2 node.

Bạn có thể chuyển đổi một phiên bản MySQL Server hiện có thành một node trong cluster. Ngoài ra bạn có thể tách bất kỳ node nào ra khỏi cụm cluster và sử dụng nó như một phiên bản Mysql Server thông thường.

<img width="349" alt="image" src="https://github.com/user-attachments/assets/4a84beae-ee26-4204-b018-d6467d39dca4">



Ý nghĩa các thông số:
* wsrep_provider: Chỉ định đường dẫn đến thư viện Galera. Vị trí tùy thuộc vào hệ điều hành
    + Debian/Ubuntu: /usr/lib/galera4/libgalera_smm.so
    + Red Hat/CentOS: /usr/lib64/galera4/libgalera_smm.so
* wsrep_cluster_address: Chỉ định địa chỉ IP của các node trong cụm cluster. Phải có ít nhất một node để tham gia vào cụm, nhưng nên liệt kê tất cả các địa chỉ.
* wresp_cluster_name: Chỉ định tên cụm cluster, tất cả các node trong cụm phải có tên giống nhau
* wresp_node_address: Chỉ định địa chỉ node
* wresp_node_name: Tên node, nếu như biến này không được được chỉ định, hostname của server được sử dụng
* pxc_strict_mode: Quy mẫu nghiêm khắc PXC được thiết lập mặc định ở chế độ ENFORCING.

Khởi động node
```
systemctl start mysql@bootstrap.service
```

Kiểm tra xem node đã hoạt động chưa
```
show status like 'wsrep%';
```




