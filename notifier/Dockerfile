ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base, install pulseaudio & sox package
RUN apk add --no-cache \
    jq \
    pulseaudio \
    alsa-plugins-pulse \
    sox 

# Copy data
COPY data/run.sh /
COPY data/zgb.wav /
RUN chmod a+x /run.sh
RUN chmod a+x /zgb.wav

WORKDIR /
CMD [ "/run.sh" ]
