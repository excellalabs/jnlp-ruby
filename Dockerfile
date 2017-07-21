FROM jenkinsci/jnlp-slave
MAINTAINER John Thompson

#####################################################################################
# Current version is aws-cli/1.10.53 Python/2.7.12
#####################################################################################
USER "root"

RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git ruby libpq-dev
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get clean


# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /home/jenkins/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /home/jenkins/.rbenv/plugins/ruby-build
RUN /home/jenkins/.rbenv/plugins/ruby-build/install.sh
ENV PATH /home/jenkins/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc
RUN echo 'eval "$(rbenv init -)"' >> .profile

# Install multiple versions of ruby
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./versions.txt /home/jenkins/versions.txt
RUN xargs -L 1 rbenv install < /home/jenkins/versions.txt
RUN chown -R jenkins:jenkins /home/jenkins
# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
USER "jenkins"
RUN eval "$(rbenv init -)"
RUN for v in $(cat /home/jenkins/versions.txt); do rbenv global $v; eval "$(rbenv init -)"; gem install bundler; done
