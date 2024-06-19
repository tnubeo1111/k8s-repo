# Yêu cầu đầu tiên để tạo ingress là k8s phải có service loadbalancer
# Nếu để tạo Ingress với domain mà add vào helm những service đã trong helm đã được setup sẳn ingress.
# Thì  chúng ta chỉ cần tìm trong file values.yaml tìm đến mục type chọn ingress trong ingress sẽ có chỗ nhập domain và tls=enable/true và trong tls sẽ có chỗ cho nhập secret thì chúng ta chỉ cần làm theo những bước như hướng dẫn ở secret.sh nhé rồi sau đó add domain và secret name vào file values trong helm thôi.

# Nếu trường hợp chúng ta tạo một ingress cho service trong k8s mà không phải helm nhé.

# sau khi service, deploy, pod đã được running

# tiếp tục chúng ta tải file 

wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml

# Lưu ý nên tải file về chung với nhưng file service của chugns ta vì chúng sẽ chạy chung một namespace thì file deply.yaml của ngixn controller cũng như thế

# Sau khi tải về chúng ta vào file deploy.yaml sẽ lại toàn bộ namespace giống với namespace đang chạy các service, deploy, pod,... 

# sau khi sữa xong bắt đầu chúng ta  apply 

kubectl apply -f  deploy.yaml

# sau đó kiểm tra xem thử nginx-controller này đã được cấp extenal IP chưa (hay còn gọi là loadbalancer đó) 
# ** Lưu ý phải cùng namespace với các service mà chúng ta cần tạo ingress nhé.

# Sau khi có IP rồi chúng ta bắt đầu tạo secret cho domain như hươngs dẫn secret.sh nhé

# sau đó chúng ta bắt đầy tạo một file yaml với kind là ingress.

# Ví dụ tạo file ingress-test.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-test 
  namespace: #namespace chung với các service đang chạy muốn tạo ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - yourdomain.com
    secretName: # secret đã tạo như hướng dẫn ở secret.sh
  rules:
  - host: yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: # Tên của service muốn chạy
            port:
              number: 80

# Sau đó apply vào thôi


# Ví dụ một file cụ thể 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: my-ingress-namespace
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: my-ingress-namespace
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  namespace: my-ingress-namespace
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - yourdomain.com
    secretName: my-ssl-cert
  rules:
  - host: yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80