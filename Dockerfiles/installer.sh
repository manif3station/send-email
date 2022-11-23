cd /app/src/plugins/web-send-email/Dockerfiles;
HOME=/tmp cpanm --noinstall --installdeps .
rm -fr /tmp/.cpanm
