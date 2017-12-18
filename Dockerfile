FROM jupyter/all-spark-notebook

# Set env vars for pydoop
ENV HADOOP_HOME /usr/local/hadoop-2.6.5
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_CONF_HOME /usr/local/hadoop-2.6.5/etc/hadoop
ENV HADOOP_CONF_DIR  /usr/local/hadoop-2.6.5/etc/hadoop

ENV PYSPARK_DRIVER_PYTHON "jupyter"
ENV PYSPARK_DRIVER_PYTHON_OPTS "notebook --allow-root"

USER root
# Add proper open-jdk-8 not just the jre, needed for pydoop
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y krb5-user libpam-krb5 libpam-ccreds auth-client-config && \
    apt-get install --no-install-recommends  -y openjdk-8-jdk python python-pip openssl && \
   # rm /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/ && \
# Add hadoop binaries
    wget http://mirror.cc.columbia.edu/pub/software/apache/hadoop/common/hadoop-2.6.5/hadoop-2.6.5.tar.gz  && \
    tar zxvf hadoop-2.6.5.tar.gz -C /usr/local && \
    chown -R $NB_USER:users /usr/local/hadoop-2.6.5 && \
    rm -f hadoop-2.6.5.tar.gz && \
# Install os dependencies required for pydoop, pyhive
    apt-get update && \
    apt-get install --no-install-recommends -y build-essential python-dev libsasl2-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
# Remove the example hadoop configs and replace
# with those for our cluster.
# Alternatively this could be mounted as a volume
    rm -f /usr/local/hadoop-2.6.5/etc/hadoop/*

# Download this from ambari / cloudera manager and copy here
COPY hadoop-conf/ /usr/local/hadoop-2.6.5/etc/hadoop/


# Spark-Submit doesn't work unless I set the following
RUN echo "spark.driver.extraJavaOptions -Dhdp.version=2.6.5" >> /usr/local/spark/conf/spark-defaults.conf  && \
    echo "spark.yarn.am.extraJavaOptions -Dhdp.version=2.6.5" >> /usr/local/spark/conf/spark-defaults.conf && \
    echo "spark.master=yarn" >>  /usr/local/spark/conf/spark-defaults.conf && \
    echo "spark.hadoop.yarn.timeline-service.enabled=false" >> /usr/local/spark/conf/spark-defaults.conf && \
    chown -R $NB_USER:users /usr/local/spark/conf/spark-defaults.conf && \
    # Create an alternative HADOOP_CONF_HOME so we can mount as a volume and repoint
    # using ENV var if needed
    mkdir -p /etc/hadoop/conf/ && \
    chown $NB_USER:users /etc/hadoop/conf/

USER $NB_USER

# Install useful jupyter extensions and python libraries like :
# - Dashboards
# - PyDoop
# - PyHive
RUN pip install --upgrade pip && \
    pip install jupyter_dashboards faker && \
    jupyter dashboards quick-setup --sys-prefix && \
    pip install setuptools virtualenv && \
    pip install gssapi && \
    pip install krbcontext --use-wheel && \
    pip install pyhive thrift sasl thrift_sasl faker && \
    pip install toree && \
    pip install pyhdfs snakebite
    #/usr/bin/pip install setuptools && \
    #/usr/bin/pip install pydoop
    #pip2 install pyhive pydoop thrift sasl thrift_sasl faker

#RUN conda install krb5 -c conda-forge

RUN conda install hdfs3 -c conda-forge
RUN conda install knit -c conda-forge

USER root
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Ensure we overwrite the kernel config so that toree connects to cluster
ENTRYPOINT ["docker-entrypoint.sh"]

USER $NB_USER
