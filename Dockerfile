FROM ghcr.io/bodagenomic/hisat2:1.0

COPY gtf2bed.pl /opt/gtf2bed.pl
COPY Makefile /opt/Makefile

# Code file to execute when the docker container starts up (`entrypoint.sh`)
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]