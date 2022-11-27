ARG OPENJDK_VERSION=11
FROM openjdk:${OPENJDK_VERSION}-jre-slim

WORKDIR /opt

ENV HADOOP_VERSION=3.3.4
ENV METASTORE_VERSION=3.1.3

ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive

ENV MYSQL_JAVA_VERSION=8.0.19
ENV PG_JAVA_VERSION=8.0.19

RUN curl -L https://www-us.apache.org/dist/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_JAVA_VERSION}.tar.gz | tar zxf - && \
    mv mysql-connector-java-${MYSQL_JAVA_VERSION}/mysql-connector-java-${MYSQL_JAVA_VERSION}.jar ${HIVE_HOME}/lib/ && \
    rm -rf  mysql-connector-java-${MYSQL_JAVA_VERSION} \
    curl -L https://jdbc.postgresql.org/download/postgresql-${PG_JAVA_VERSION}.jar -o $HIVE_HOME/lib/postgresql-jdbc.jar

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME}

USER hive
EXPOSE 9083

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENTRYPOINT ["/tini", "--", "${HIVE_HOME}/bin/start-metastore"]
CMD ["--help"]
