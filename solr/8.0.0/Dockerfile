FROM solr:8.1.1

MAINTAINER Andrej Chmelo <andrej.chmelo@cgi.com>

USER root
ADD lib/ /var/solr/data/lib/
ADD kramerius /kramerius
ADD oai/ /var/solr/data/oai

RUN chown -R $SOLR_USER:$SOLR_USER /kramerius 
USER $SOLR_USER
