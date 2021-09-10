FROM quay.io/baselibrary/ubuntu:14.04

USER root

RUN apt-get -m update -y && apt-get upgrade -y && apt-get install -y wget samtools
RUN wget "https://github.com/brentp/mosdepth/releases/download/v0.3.2/mosdepth"
RUN cp ./mosdepth /usr/local/bin/
RUN chmod a+x /usr/local/bin/mosdepth

# RUN chmod a+x mosdepth



RUN groupadd -r -g 1000 ubuntu && useradd -r -g ubuntu -u 1000 ubuntu
USER ubuntu

CMD ["/bin/bash"]