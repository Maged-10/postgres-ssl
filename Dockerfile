FROM postgres:16

# Install OpenSSL, sudo, and build pgvector extension
RUN apt-get update && \
	apt-get install -y openssl sudo postgresql-server-dev-16 git build-essential && \
	git clone --branch v0.7.0 https://github.com/pgvector/pgvector.git /tmp/pgvector && \
	cd /tmp/pgvector && make && make install && \
	rm -rf /tmp/pgvector

# Allow the postgres user to execute certain commands as root without a password
RUN echo "postgres ALL=(root) NOPASSWD: /usr/bin/mkdir, /bin/chown, /usr/bin/openssl" > /etc/sudoers.d/postgres

# Add init scripts while setting permissions
COPY --chmod=755 init-ssl.sh /docker-entrypoint-initdb.d/init-ssl.sh
COPY --chmod=755 wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]
CMD ["postgres", "--port=5432"]
