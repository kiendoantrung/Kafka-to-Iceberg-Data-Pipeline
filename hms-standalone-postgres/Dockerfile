FROM ghcr.io/criccomini/hive-metastore-standalone:0.3.1

RUN apt-get update && apt-get install -y curl rlwrap vim postgresql-client

# Download PostgreSQL JDBC driver and other required JARs
RUN cd /opt/hive-metastore/lib && \
    curl https://jdbc.postgresql.org/download/postgresql-42.7.3.jar -O && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar -O && \
    curl https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.20.18/bundle-2.20.18.jar -O && \
    curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.648/aws-java-sdk-bundle-1.12.648.jar -O

COPY conf/hive-site.xml /opt/hive-metastore/conf/hive-site.xml

# Copy initialization script
COPY init-schema.sh /opt/hive-metastore/bin/init-schema.sh
RUN chmod +x /opt/hive-metastore/bin/init-schema.sh

# Set entrypoint to initialize schema and start metastore
ENTRYPOINT ["/opt/hive-metastore/bin/init-schema.sh"]
