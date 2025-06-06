FROM owasp/dependency-check:7.4.4
USER root
WORKDIR /opt/action
COPY --chmod=0755 entrypoint.sh .

# Invoca siempre la copia en /opt/action, independientemente del workdir que pongan
ENTRYPOINT ["sh", "/opt/action/entrypoint.sh"]
