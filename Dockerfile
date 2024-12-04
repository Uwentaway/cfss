FROM alpine
#FROM ubuntu

WORKDIR /app
COPY argo.log cfss  cloudflared-linux-amd64  config.json  entrypoint.sh  geoip.dat  geosite.dat  /app/

RUN chown -R  10001:10001 /app/
USER 10001

ENTRYPOINT [ "/bin/sh", "entrypoint.sh" ]
#ENTRYPOINT [ "/usr/bin/bash", "entrypoint.sh" ]
