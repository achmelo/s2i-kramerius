FROM openshift/base-centos7

MAINTAINER Martin Rumanek <martin@rumanek.cz>
ENV GRADLE_VERSION=2.12
ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.27
ENV CATALINA_HOME /usr/local/tomcat
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

# check https://github.com/ceskaexpedice/kramerius/issues/470
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

ENV JDBC_DRIVER_DOWNLOAD_URL https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar
ENV LANG en_US.UTF-8

# Set the labels that are used for Openshift to describe the builder image.
LABEL io.k8s.description="Kramerius" \
    io.k8s.display-name="Kramerius" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,kramerius" \
    io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

RUN INSTALL_PKGS="tar zip" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    wget -nv  https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip -O gradle.zip && \
    unzip -qq gradle.zip -d /usr/local && \
    rm gradle.zip

RUN  ln -sf /usr/local/gradle-$GRADLE_VERSION/bin/gradle /usr/local/bin/gradle

RUN yum install -y java-1.8.0-openjdk
RUN yum install -y java-1.8.0-openjdk-devel

WORKDIR $CATALINA_HOME

RUN  curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz && \
	tar -xvf tomcat.tar.gz --strip-components=1 && \
	rm bin/*.bat && \
	rm tomcat.tar.gz*

RUN curl -fsL "$JDBC_DRIVER_DOWNLOAD_URL" -o $CATALINA_HOME/lib/postgresql-9.4.1208.jar

RUN curl -fsL  https://github.com/ceskaexpedice/kramerius/releases/download/v5.3.6/kramerius-5.3.6.zip -o /tmp/kramerius-5.3.6.zip && \
    unzip /tmp/kramerius-5.3.6.zip -d editors  && \
    mv editors/rightseditor.war $CATALINA_HOME/webapps/ && \
    mv editors/editor.war $CATALINA_HOME/webapps/ && \
    rm /tmp/kramerius-5.3.6.zip && \
    rm -rf /tmp/editors

ADD context.xml $CATALINA_HOME/conf/context.xml
ADD search.xml $CATALINA_HOME/conf/Catalina/localhost/search.xml
ADD web.xml $CATALINA_HOME/conf/web.xml


# Kramerius auth
ENV JAAS_CONFIG=$CATALINA_HOME/conf/jaas.config
ADD jaas.conf $CATALINA_HOME/conf/jaas.config
ENV JAVA_OPTS -Djava.awt.headless=true -Dfile.encoding=UTF8  -Djava.security.auth.login.config=$JAAS_CONFIG -Duser.home=$HOME

ADD rewrite.config $CATALINA_HOME/conf/Catalina/localhost/
ADD server.xml $CATALINA_HOME/conf/

COPY  ["run", "assemble", "save-artifacts", "usage", "/usr/libexec/s2i/"]

ADD robotScript.sh /tmp/robotScript.sh

RUN wget --no-verbose https://github.com/ceskaexpedice/kramerius/releases/download/v5.1.0/Installation-5.1.zip && \
    unzip -j Installation-5.1.zip Installation-5.1/fedora/* -d /tmp/fedora

ENV TOMCAT_USER tomcat
ENV TOMCAT_UID 8983
RUN groupadd -r $TOMCAT_USER && \
    useradd -r -u $TOMCAT_UID -g $TOMCAT_USER $TOMCAT_USER -d $HOME

RUN mkdir -p $HOME/.kramerius4/lp/
RUN chown -R $TOMCAT_USER:$TOMCAT_USER $HOME $CATALINA_HOME

RUN chmod -R ugo+rwx $HOME $CATALINA_HOME

USER 8983
EXPOSE 8080

CMD ["/usr/libexec/s2i/usage"]
