# Builder stage
FROM linuxmintd/mint20-amd64:latest as builder

ARG MINT_USER_PASSWORD

RUN apt-get update && \
    apt-get install -y xrdp sudo && \
    useradd -m cloud_user && \
    echo "cloud_user:${MINT_USER_PASSWORD}" | chpasswd && \
    echo "cloud_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Final stage
FROM linuxmintd/mint20-amd64:latest

COPY --from=builder /home/cloud_user /home/cloud_user
COPY --from=builder /etc/sudoers /etc/sudoers

RUN apt-get update && \
    apt-get install -y xrdp

EXPOSE 3389

CMD ["/usr/sbin/xrdp", "--nodaemon"] 