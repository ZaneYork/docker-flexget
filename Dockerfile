FROM python
ENV PYTHONUNBUFFERED 1

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y gcc

WORKDIR /wheels
RUN pip install -U pip && \
    pip wheel flexget && \
    pip wheel 'transmission-rpc>=3.0.0,<4.0.0' && \
    pip wheel deluge-client && \
    pip wheel python-telegram-bot==12.8 && \
    pip wheel chardet && \
    pip wheel baidu-aip && \
    pip wheel pillow && \
    pip wheel pandas && \
    pip wheel matplotlib && \
    pip wheel fuzzywuzzy && \
    pip wheel python-Levenshtein && \
    pip wheel colorama
FROM python
LABEL maintainer="madwind.cn@gmail.com" \
      org.label-schema.name="flexget"
ENV PYTHONUNBUFFERED 1

COPY --from=0 /wheels /wheels
COPY root/ /

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
                    ca-certificates && \
    pip install -U pip && \
    pip install --no-cache-dir \
                --no-index \
                -f /wheels \
                flexget \
                'transmission-rpc>=3.0.0,<4.0.0' \
                deluge-client \
                python-telegram-bot==12.8 \
                chardet \
                baidu-aip \
                pillow \
                pandas \
                matplotlib \
                fuzzywuzzy \
                python-Levenshtein \
                colorama && \
    echo "**** create flexget user and make our folders ****" && \
    mkdir /home/flexget && \
    groupmod -g 1000 users && \
    useradd -u 911 -U -d /home/flexget -s /bin/sh flexget && \
    usermod -G users flexget && \
    chown -R flexget:flexget /home/flexget && \
    chmod +x /usr/bin/entrypoint.sh && \
    rm -rf /wheels \
           /var/lib/apt/lists/*

# add default volumes
VOLUME /config /downloads
WORKDIR /config

# expose port for flexget webui
EXPOSE 3539 3539/tcp

ENTRYPOINT ["sh","-c","/usr/bin/entrypoint.sh"]
