#
# Dockerfile for WordPress
#
FROM appsvcorg/alpine-php-mysql:0.1 
MAINTAINER Azure App Service Container Images <appsvc-images@microsoft.com>

# ========
# ENV vars
# ========

# wordpress
ENV WORDPRESS_SOURCE "/usr/src/wordpress"
ENV WORDPRESS_HOME "/home/site/wwwroot"

#
ENV DOCKER_BUILD_HOME "/dockerbuild"

# ====================
# Download and Install
# ~. tools
# 1. redis
# 2. wordpress
# ====================

WORKDIR $DOCKER_BUILD_HOME
RUN set -ex \
	# --------
	# 1. redis
	# --------
        && apk add --update redis \
	# ------------	
	# 2. wordpress
	# ------------
	&& mkdir -p $WORDPRESS_SOURCE \
        # cp in final
	# ----------
	# ~. clean up
	# ----------
	&& rm -rf /var/cache/apk/* 

# =========
# Configure
# =========
# httpd confs

COPY httpd-wordpress.conf $HTTPD_CONF_DIR/

RUN set -ex \
	##
	&& ln -s $WORDPRESS_HOME /var/www/wordpress \
    ##
    && test -e /usr/local/bin/entrypoint.sh && mv /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.bak
	
# =====
# Add Xdebug and turn on profiler
# =====

RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-2.5.0 \
    && echo "zend_extension=$(find /usr/local/php/lib/php/extensions/ -name xdebug.so)" > /usr/local/php/etc/conf.d/xdebug.ini \
	&& echo "xdebug.profiler_enable = 1" >> /usr/local/php/etc/conf.d/xdebug.ini \
	&& echo "xdebug.profiler_output_dir = \"/home/LogFiles/\"" >> /usr/local/php/etc/conf.d/xdebug.ini


# =====
# final
# =====

COPY wp.tar.gz $WORDPRESS_SOURCE/
COPY wp-config.php $WORDPRESS_SOURCE/

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]
