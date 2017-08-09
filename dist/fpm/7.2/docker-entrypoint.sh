#!/bin/bash

set -e

# if command starts with an option, prepend it to command
if [ "${1:0:1}" = '-' ]; then
  set -- php-fpm "$@"
fi

HOST_IP=`ip route | awk '/default/ { print $3 }'`
sed -i "s/xdebug.remote_host\s*=.*/xdebug.remote_host = ${HOST_IP}/" $PHP_INI_DIR/conf.d/zz-xdebug.ini

if [ ! -z "${XDEBUG_DISABLE}" ] && [ "${XDEBUG_DISABLE}" -ne "0" ]; then
  sed -i "s/zend_extension/;zend_extension/" $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
fi

if [ ! -z "${XDEBUG_REMOTE_HOST}" ]; then
  sed -i "s/xdebug.remote_host\s*=.*/xdebug.remote_host = ${XDEBUG_REMOTE_HOST}/" $PHP_INI_DIR/conf.d/zz-xdebug.ini
fi

if [ ! -z "${XDEBUG_REMOTE_PORT}" ]; then
  sed -i "s/xdebug.remote_port\s*=.*/xdebug.remote_port = ${XDEBUG_REMOTE_PORT}/" $PHP_INI_DIR/conf.d/zz-xdebug.ini
fi

if [ ! -z "${XDEBUG_REMOTE_AUTOSTART}" ]; then
  sed -i "s/xdebug.remote_autostart\s*=.*/xdebug.remote_autostart = ${XDEBUG_REMOTE_AUTOSTART}/" $PHP_INI_DIR/conf.d/zz-xdebug.ini
fi

if [ ! -z "${XDEBUG_IDE_KEY}" ]; then
  sed -i "s/;\?xdebug.idekey\s*=.*/xdebug.idekey = ${XDEBUG_IDE_KEY}/" $PHP_INI_DIR/conf.d/zz-xdebug.ini
fi

if [ ! -z "${XDEBUG_FILE_LINK_FORMAT}" ]; then
  case "${XDEBUG_FILE_LINK_FORMAT}" in
      "phpstorm")
      FORMAT="phpstorm://open?file=%f&line=%l"
      ;;
    "idea")
      FORMAT="idea://open?file=%f&line=%l"
      ;;
    "sublime")
      FORMAT="subl://open?url=file://%f&line=%l"
      ;;
    "textmate")
      FORMAT="txmt://open?url=file://%f&line=%l"
      ;;
    "emacs")
      FORMAT="emacs://open?url=file://%f&line=%l"
      ;;
    "macvim")
      FORMAT="mvim://open/?url=file://%f&line=%l"
      ;;
    *)
      FORMAT="${XDEBUG_FILE_LINK_FORMAT}"
      ;;
  esac

  sed -i "s/;\?xdebug.file_link_format\s*=.*/xdebug.file_link_format = \"${FORMAT}\"/" $PHP_INI_DIR/conf.d/zz-xdebug.ini
fi

exec "$@"