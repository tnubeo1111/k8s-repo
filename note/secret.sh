# Ví dụ về trường hợp SSL/TLS

# Nếu bạn có một domain và get SSL từ nhà cung cấp bên ngoài ví dụ: ZeroSSL,... 

# (VD của domain cuar tôi là: vcr.thanhtha.name.vn)

# Sau khi tải file zip SSL về bạn sẽ giải nén gồm 3 file như sau: 

# ca_bundle.crt  certificate.crt   private.key

# Nếu thường mặc định chúng ta tạo một scret trên k8s với command như sau:

kubectl create secret tls vcr.thanhtha.name.vn   --cert=certificate.crt   --key=private.key -n harbor #--> thì có khả năng sẽ bị lỗi  "tls: failed to verify certificate: x509: certificate is valid for ingress.local, not hni.thanhtha.name.vn"

# Lúc này trường hợp chúng ta sẽ fix như sau: 

cat certificate.crt ca_bundle.crt > fullchain.crt

kubectl create secret tls thanhtha-harbor   --cert=fullchain.crt   --key=private.key   -n harbor 

# Để kiểm tra chứng chỉ có hoạt động đúng không có thể sử dụng command sau:
openssl s_client -connect vcr.thanhtha.name.vn:443 -showcerts 
# Nếu log ra như sau "Verify return code: 0 (ok)" thì đã oke nhé.

#** Lưu ý khi chúng tao scret ở namespace nào thì khi đó server của bạn cũng phải tạo ở namespace đó nhé hoặc ngược lại. Nếu khác namespace sẽ bị thông báo như sau: "Kubernetes Ingress Controller Fake Certificate
#"


