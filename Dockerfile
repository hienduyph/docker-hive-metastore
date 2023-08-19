FROM docker.io/eclipse-temurin:11-jre

RUN apt-get update \
    && apt-get install -y netcat procps curl \
    && apt-get autoremove -y \
    && apt-get clean

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENV HIVE_HOME=/opt/hive
ENV PATH=${HIVE_HOME}/bin:${PATH}

ARG METASTORE_VERSION
ENV METASTORE_VERSION=${METASTORE_VERSION:-3.1.3}

RUN mkdir -p $HIVE_HOME && set -ex && export MYSQL_JAVA_VERSION=8.1.0 PG_JAVA_VERSION=42.6.0  HIVE_MIRROR=https://repo1.maven.org/maven2/org/apache \
  && curl -fsSL ${HIVE_MIRROR}/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | \
  tar xz -C ${HIVE_HOME} --strip-components=1 \
  && curl -L https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_JAVA_VERSION}/mysql-connector-j-${MYSQL_JAVA_VERSION}.jar -o ${HIVE_HOME}/lib/mysql-connector-j-${MYSQL_JAVA_VERSION}.jar \
  && curl -L https://jdbc.postgresql.org/download/postgresql-${PG_JAVA_VERSION}.jar -o ${HIVE_HOME}/lib/postgresql-jdbc.jar

ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
RUN mkdir -p ${HADOOP_HOME} && export HADOOP_MIRROR=https://dlcdn.apache.org/ \
  && curl -fsSL ${HADOOP_MIRROR}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar xz -C ${HADOOP_HOME} --strip-components=1


RUN set -ex && cd $HIVE_HOME/lib/ && export AWS_VERSION=1.12.532 \
  && curl -LO https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_VERSION}/aws-java-sdk-bundle-${AWS_VERSION}.jar  \
  && curl -LO https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME}

WORKDIR $HIVE_HOME
EXPOSE 9083

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER hive
ENTRYPOINT ["/tini", "--"]
CMD ["/entrypoint.sh"]
