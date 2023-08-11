# build private registry with docker

## 1.get image
- `docker pull registry:2.8.2`
## 2.run base container
- `docker run -d -p 5000:5000 --restart=always --name registry registry:2.8.2`
## 3.run with local storage
- `docker run -d -p 5000:5000 --restart=always --name registry -v /sususu/registry:/var/lib/registry registry:2.8.2`
## 4.config docker to use --insecure-registry option
- `vim /etc/docker/daemon.json`
- add config: `{ "insecure-registries" : ["myregistrydomain.com:5000"]}`
- restart docker: `sudo systemctl restart docker.service`

> But since v1.20, k8s use containerd as the default cr, so you must config containerd can pull/push images from insecure registry

- `containerd config default > config.toml`
- change these lines below:
```toml
  [plugins."io.containerd.grpc.v1.cri".registry.configs]
    [plugins."io.containerd.grpc.v1.cri".registry.configs."10.4.243.51:5000"]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."10.4.243.51:5000".tls]
          ca_file = ""
          cert_file = ""
          insecure_skip_verify = true
          key_file = ""

  [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."10.4.243.51:5000"]
      endpoint = ["http://10.4.243.51:5000"]
```
- restart containerd: `sudo systemctl restart containerd`

Above all, you can pull and push images by the private registry

---






---
-----not used now-----

## 5.use certificate
- gen certs
  - `mkdir certs`
  - `openssl req -newkey rsa:4096 -nodes -sha256 -subj "/C=CN/OU=Registry/O=Chronos" -keyout certs/registry.key -addext "subjectAltName=IP:10.4.243.51,IP:10.158.137.11" -x509 -days 36500 -out certs/registry.crt`
## 6.use basic auth
- https://docs.docker.com/registry/configuration/
- https://docs.docker.com/registry/insecure/
