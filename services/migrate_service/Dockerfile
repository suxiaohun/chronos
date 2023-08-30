FROM 10.4.243.51:5000/ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive TZ=Asia/Shanghai apt update && apt install -y tzdata
WORKDIR /

COPY migrate-amd64 ./

COPY migrations ./migrations

RUN chmod 777 /migrate-amd64

CMD ["/migrate-amd64"]