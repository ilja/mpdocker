# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.9

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install dependencies with apt-get
RUN apt-get update
RUN apt-get -y install mpd ncmpcpp make git libsqlite3-dev nodejs

ADD mpd.conf /etc/mpd.conf

RUN mkdir /etc/service/mpd
ADD mpd.sh /etc/service/mpd/run

# Install ruby-install from source
RUN curl -L -o ruby-install-0.4.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.1.tar.gz
RUN tar -xzvf ruby-install-0.4.1.tar.gz
RUN cd ruby-install-0.4.1/ && make install

# Build ruby
RUN ruby-install ruby 2.1.1

# RUN echo "gem: --no-ri --no-rdoc" > /etc/gemrc
RUN echo "gem: --no-document" > /etc/gemrc

# Install chruby from source
RUN curl -L -o chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
RUN tar -xzvf chruby-0.3.8.tar.gz
RUN cd chruby-0.3.8/ && make install

RUN echo 'if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then' >> /etc/profile.d/chruby.sh
RUN echo '  source /usr/local/share/chruby/chruby.sh' >> /etc/profile.d/chruby.sh
RUN echo 'fi' >> /etc/profile.d/chruby.sh

RUN echo 'chruby 2.1.1' >> /etc/profile

# Change path to include ruby
ENV PATH /opt/rubies/ruby-2.1.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install bundler
RUN gem install bundler --no-ri --no-rdoc

# Install total player
RUN git clone https://github.com/ilja/total_player.git
RUN cd /total_player && bundle install

# Add total player runit
RUN mkdir /etc/service/total_player
ADD total_player.sh /etc/service/total_player/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose mpd & total_player ports
EXPOSE 8000 5000
