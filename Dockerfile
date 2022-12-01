ARG OPENJDK_VERSION=11
FROM openjdk:${OPENJDK_VERSION}-jre-slim

RUN apt-get update && \
    apt-get install -y netcat procps curl && \
    apt-get autoremove -y && \
    apt-get clean

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENV HIVE_HOME=/opt/hive
ENV PATH=${HIVE_HOME}/bin:${PATH}
ENV METASTORE_VERSION=3.0.0

ENV MYSQL_JAVA_VERSION=8.0.19
ENV PG_JAVA_VERSION=42.5.1
ARG HIVE_MIRROR=https://dlcdn.apache.org/


RUN mkdir -p $HIVE_HOME && set -ex && \
  curl -fsSL $HIVE_MIRROR/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | \
  tar xz -C $HIVE_HOME --strip-components=1  && \
  curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_JAVA_VERSION}.tar.gz | tar xz -C ${HIVE_HOME}/lib --strip-components=1 && \
  curl -L https://jdbc.postgresql.org/download/postgresql-${PG_JAVA_VERSION}.jar -o $HIVE_HOME/lib/postgresql-jdbc.jar

ENV HADOOP_VERSION=3.3.4
ENV HADOOP_HOME=/opt/hadoop
RUN mkdir -p $HADOOP_HOME && \
  curl -fsSL $HIVE_MIRROR/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar xz -C $HADOOP_HOME --strip-components=1


RUN cd $HIVE_HOME/lib/ &&\
  curl -LO https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.352/aws-java-sdk-bundle-1.12.352.jar &&\
  curl -LO https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME}

WORKDIR $HIVE_HOME
EXPOSE 9083

USER hive
ENTRYPOINT ["/tini", "--"]
CMD []
