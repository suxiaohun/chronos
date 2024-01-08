FROM 10.4.243.51:5000/kafka-2.12-2.2.2:ca38a55-amd64

ARG KAFKA_DIR="kafka_2.13-3.6.1"
ENV KAFKA_DIST="kafka_2.13-3.6.1"
ENV KAFKA_OPTS=""
ENV KAFKA_CLUSTER_ID="Y6uRG8lwQWy2whj2W04YJw"

RUN apt update && apt install -y gettext && rm -rf /opt/kafka /opt/kafka_2.12-2.2.2 && mkdir /opt/$KAFKA_DIR

COPY $KAFKA_DIR /opt/$KAFKA_DIR

COPY run.sh /

RUN ln -s /opt/$KAFKA_DIR /opt/kafka

CMD ["ls"]


