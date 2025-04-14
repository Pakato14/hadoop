FROM krallin/centos-tini:centos7
MAINTAINER Michael J. Stealey <michael.j.stealey@gmail.com>

ARG HADOOP_VERSION=2.9.0

# Definir variáveis de ambiente padrão
ENV HOME=/root \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Copia o JDK baixado para o contêiner
COPY jdk-8u202-linux-x64.rpm /tmp/jdk.rpm

# Instala o JDK e define a variável de ambiente JAVA_HOME
RUN rpm -Uvh /tmp/jdk.rpm && rm /tmp/jdk.rpm \
    && echo "export JAVA_HOME=/usr/java/default" > /etc/profile.d/java_home.sh \
    && echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java_home.sh

ENV JAVA_HOME=/usr/java/default
ENV PATH="$JAVA_HOME/bin:$PATH"

# Instala dependências básicas + python3
ARG HADOOP_INSTALL_DIR=/home/hadoop
RUN sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo && \
    yum makecache fast && yum install -y \
    openssh-server \
    openssh-clients \
    which \
    tar \
    curl \
    python3 \
    && yum clean all

# Cria o usuário hadoop
RUN adduser -m -d $HADOOP_INSTALL_DIR hadoop

# Cria pasta bin pessoal e linka python3 para garantir visibilidade
RUN mkdir -p $HADOOP_INSTALL_DIR/bin && \
    ln -s /usr/bin/python3 $HADOOP_INSTALL_DIR/bin/python3 && \
    chown -R hadoop:hadoop $HADOOP_INSTALL_DIR/bin

# Instala Hadoop como hadoop
WORKDIR $HADOOP_INSTALL_DIR
USER hadoop
RUN curl -o hadoop-$HADOOP_VERSION.tar.gz "https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
    && tar xzf hadoop-$HADOOP_VERSION.tar.gz \
    && mv hadoop-$HADOOP_VERSION hadoop \
    && rm -f hadoop-$HADOOP_VERSION.tar.gz 

# Volta para root para configurar SSH
USER root
WORKDIR /root/
RUN ssh-keygen -q -N '' -t rsa -f /root/.ssh/id_rsa \
    && ssh-keygen -q -N '' -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && ssh-keygen -q -N '' -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -q -N '' -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -q -N '' -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
    && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
    && chmod 0600 /root/.ssh/authorized_keys

# Definições das variáveis de ambiente do Hadoop
ENV HADOOP_USER_HOME=${HADOOP_INSTALL_DIR} \
    HADOOP_PREFIX=${HADOOP_INSTALL_DIR}/hadoop \
    HADOOP_INSTALL=${HADOOP_PREFIX} \
    HADOOP_MAPRED_HOME=${HADOOP_PREFIX} \
    HADOOP_COMMON_HOME=${HADOOP_PREFIX} \
    HADOOP_HDFS_HOME=${HADOOP_PREFIX} \
    YARN_HOME=${HADOOP_PREFIX} \
    HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native \
    HADOOP_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop \
    PATH=$PATH:${HADOOP_PREFIX}/sbin:${HADOOP_PREFIX}/bin:${HADOOP_INSTALL_DIR}/bin

# Configurações do cluster
ENV IS_NODE_MANAGER=true \
    IS_NAME_NODE=true \
    IS_SECONDARY_NAME_NODE=true \
    IS_DATA_NODE=true \
    IS_RESOURCE_MANAGER=true \
    CLUSTER_NODES=localhost

# Volumes externos
VOLUME ["/site-files", "/home/hadoop/public"]

# Copia o entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Exposição da porta SSH
EXPOSE 22

ENTRYPOINT ["/usr/local/bin/tini", "--", "/docker-entrypoint.sh"]
