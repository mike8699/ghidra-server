FROM openjdk:22-jdk-slim

RUN apt-get update && apt-get install -y wget unzip dnsutils --no-install-recommends \
    && wget --progress=bar:force -O /tmp/ghidra.zip https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.2.3_build/ghidra_10.2.3_PUBLIC_20230208.zip \
    && unzip /tmp/ghidra.zip \
    && mv ghidra_10.2.3_PUBLIC /ghidra \
    && chmod +x /ghidra/ghidraRun \
    && apt-get purge -y --auto-remove wget unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives /tmp/* /var/tmp/* /ghidra/docs /ghidra/Extensions/Eclipse /ghidra/licenses

WORKDIR /ghidra

COPY entrypoint.sh /entrypoint.sh
COPY server.conf /ghidra/server/server.conf

EXPOSE 13100 13101 13102

RUN mkdir /repos
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["server"]
