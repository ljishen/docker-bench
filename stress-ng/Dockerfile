FROM debian:jessie

ENV STRESS_NG_VERSION V0.06.12

RUN apt-get update && \
    apt-get install -y make gcc g++ wget python python-yaml && \
    wget --no-check-certificate https://github.com/ColinIanKing/stress-ng/archive/$STRESS_NG_VERSION.tar.gz && \
    tar xfz $STRESS_NG_VERSION.tar.gz && \
    mv stress-ng* /stress-ng && \
    make -C /stress-ng && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN mv /stress-ng/stress-ng /usr/bin
ADD postprocess.py /
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
