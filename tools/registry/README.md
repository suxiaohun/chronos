# build private registry with docker

## 1.get image
- `docker pull registry:2.8.2`
## 2.run base container
- `docker run -d -p 5000:5000 --restart=always --name registry registry:2.8.2`
## 3.run with local storage
- `docker run -d -p 5000:5000 --restart=always --name registry -v /sususu/registry:/var/lib/registry registry:2.8.2`
## 4.use certificate
- gen certs
  - `mkdir certs`
  - `openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/registry.key -addext "subjectAltName = DNS:10.4.243.51" -x509 -days 36500 -out certs/registry.crt`
- 
