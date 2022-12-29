FROM ubuntu:16.04 as jlink-builder

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#配置代理 不需要可以移除
ENV http_proxy http://127.0.0.1:7890
ENV https_proxy http://127.0.0.1:7890

RUN apt-get -y update && \
    apt-get -y install python \
                       python3 \
                       sudo
RUN rm /usr/bin/python && ln -s /usr/bin/python2 /usr/bin/python
ADD . /build_tools
WORKDIR /build_tools

RUN cd tools/linux && \
    python3 ./automate.py server

#移除代理
RUN unset http_proxy && unset https_proxy

FROM onlyoffice/documentserver:latest
LABEL maintainer="falcon2014@163.com"

COPY --from=jlink-builder /build_tools/out /var/www/onlyoffice/documentserver

ENTRYPOINT ["/app/ds/run-document-server.sh"]