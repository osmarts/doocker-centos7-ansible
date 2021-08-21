FROM centos:7
ENV container=docker

ENV pip_packages "ansible selinux"


COPY CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo


RUN mkdir /root/.pip
COPY pip.conf /root/.pip/pip.conf

RUN yum -y update;yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements.
RUN yum makecache fast \
 && yum -y install deltarpm epel-release initscripts \
 && sed -i 's|^#baseurl=http://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel* \
 && sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel* \
 && yum -y update \
 && yum -y install \
      sudo \
      which \
      python-pip \
     crontabs \
      vim \
      wget \
      sudo \
      which \
      hostname \
      unzip \
      git \
 && yum clean all


# Install Ansible via Pip.
RUN pip install --upgrade "pip < 21.0"


# Install Ansible via Pip.
RUN pip install $pip_packages

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

RUN mkdir -p /var/lib/cloud/data \
    && echo "qwer1234!" > /var/lib/cloud/data/instance-id

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
