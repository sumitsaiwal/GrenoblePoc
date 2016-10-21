FROM sumitsaiwal/tomcat

COPY /target/grenoble.war /opt/apache-tomcat-7.0.69/webapps/grenoble.war

ENV JAVA_HOME /usr/lib/jvm/default-java
ENV CATALINA_HOME /opt/apache-tomcat-7.0.69
ENV PATH $CATALINA_HOME/bin:$PATH

EXPOSE 8080

CMD ["catalina.sh", "run"]
