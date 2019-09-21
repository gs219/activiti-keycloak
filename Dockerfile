FROM jboss/keycloak:latest
MAINTAINER https://gitter.im/Activiti/Activiti7

RUN /opt/jboss/keycloak/bin/add-user.sh -u admin -p admin
RUN /opt/jboss/keycloak/bin/add-user-keycloak.sh -r master -u admin -p admin

ADD activiti-realm.json /opt/jboss/keycloak/

ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]

ENV PORT_OFFSET 100
ENV DB_VENDOR mariadb

EXPOSE 8180 30081

CMD ["-b", "0.0.0.0", "-Dkeycloak.import=/opt/jboss/keycloak/activiti-realm.json -Djboss.socket.binding.port-offset=${env.PORT_OFFSET}"]
