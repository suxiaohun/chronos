FROM registry.sensetime.com/infra/kafka-2.12-2.2.2:ca38a55-amd64

ENV KAFKA_DIST="kafka_2.13-3.6.0"
ENV KAFKA_OPTS=""
ENV KAFKA_CLUSTER_ID="Y6uRG8lwQWy2whj2W04YJw"

RUN rm -rf /opt/kafka /opt/kafka_2.12-2.2.2 && mkdir /opt/kafka_2.13-3.6.0 && apt update && apt-get install gettext-base

COPY kafka_2.13-3.6.0 /opt/kafka_2.13-3.6.0

COPY server.properties.template /opt/kafka_2.13-3.6.0/config/kraft/server.properties.template

RUN ln -s /opt/kafka_2.13-3.6.0 /opt/kafka

CMD ["ls"]

