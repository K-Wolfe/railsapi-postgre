FROM centos:7


LABEL Remarks="Centos7 based Rails API with Nginx"

ENV nginxversion="1.14.0-1" \
    os="centos" \
    osversion="7" \
    elversion="7_4"

# rubyとrailsのバージョンを指定
ENV ruby_ver="2.7.2"
ENV rails_ver="6.1.0"

RUN yum -y update &&\
    yum install -y wget openssl sed &&\
    yum -y install git make autoconf curl &&\
    yum -y install epel-release &&\
    yum -y autoremove &&\
    wget http://nginx.org/packages/$os/$osversion/x86_64/RPMS/nginx-$nginxversion.el$elversion.ngx.x86_64.rpm &&\
    rpm -iv nginx-$nginxversion.el$elversion.ngx.x86_64.rpm &&\
    yum install -y ruby &&\
    yum install -y gcc &&\
    yum -y install gcc-c++ glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel sqlite-devel bzip2 &&\
    yum install -y postgresql-devel &&\
    yum clean all

# rubyとbundleをダウンロード
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# RUN gem update --system ${ruby_ver} 
# コマンドでrbenvが使えるように設定
RUN echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init --no-rehash -)"' >> /etc/profile.d/rbenv.sh

# rubyとrailsをインストール
RUN source /etc/profile.d/rbenv.sh; rbenv install ${ruby_ver}; rbenv global ${ruby_ver}; rbenv local ${ruby_ver}
RUN source /etc/profile.d/rbenv.sh; gem update --system; gem install --version ${rails_ver} -N rails; gem install bundle
RUN source /etc/profile.d/rbenv.sh; gem install rails; gem install sass-rails
RUN source /etc/profile.d/rbenv.sh; gem install pg

# COPY nginx.conf /etc/nginx/nginx.conf
# COPY index.html /data/www/index.html
VOLUME [ "/data/www" ]
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]