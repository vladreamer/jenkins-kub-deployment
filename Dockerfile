FROM httpd:2.4
RUN apt-get -y update
RUN apt-get -y install git
COPY ./index.html /usr/local/apache2/htdocs/
