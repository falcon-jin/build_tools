FROM ubuntu:16.04 as jlink-builder

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#配置代理 不需要可以移除
ENV http_proxy http://127.0.0.1:7890
ENV https_proxy http://127.0.0.1:7890
ENV all_proxy socks5://127.0.0.1:7890


RUN apt-get -y update && \
    apt-get -y install python git \
                       python3 \
                       sudo
RUN rm /usr/bin/python && ln -s /usr/bin/python2 /usr/bin/python
ADD . /build_tools



RUN cd /build_tools/../../ && rm -rf server web-apps  && git clone https://github.com/ONLYOFFICE/web-apps.git \
      && git clone https://github.com/ONLYOFFICE/server.git \
        && git clone https://github.com/ONLYOFFICE/document-templates.git \
    && git clone https://github.com/ONLYOFFICE/core.git \
    && git clone https://github.com/ONLYOFFICE/core-fonts.git \
    && git clone https://github.com/ONLYOFFICE/dictionaries.git \
     && git clone https://github.com/ONLYOFFICE/sdkjs.git \
    && git clone https://github.com/ONLYOFFICE/document-server-integration.git


WORKDIR /build_tools

RUN cd tools/linux && \
    python3 ./automate.py server

#移除代理
RUN unset http_proxy && unset https_proxy && unset all_proxy

FROM onlyoffice/documentserver:latest
LABEL maintainer="falcon2014@163.com"

COPY --from=jlink-builder /build_tools/out /var/www/onlyoffice/documentserver

ENTRYPOINT ["/app/ds/run-document-server.sh"]