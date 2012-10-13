export EDITOR=vim

if [ -e ~/etc/profile ]; then
  source ~/etc/profile
fi

# all of this should go into a Mac specific config...
## export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/local/bin:/opt/local/sbin:/usr/X11/bin
## 
## # MacPorts Installer addition on 2009-10-31_at_10:45:42: adding an appropriate PATH variable for use with MacPorts.
## export PATH=/usr/local/bin:/usr/local/sbin:$PATH
## # Finished adapting your PATH environment variable for use with MacPorts.
## 
## # homebrew python install
## export PATH=/usr/local/share/python:$PATH
## 
## export JREBEL_HOME=/Applications/JRebel
## export JETTY_HOME=~/Applications/jetty
## 
## export MAVEN_HOME=/usr/local/Cellar/maven/3.0.2/
## 
## export JAVA_HOME=/Library/Java/Home
## 
## export SCALA_HOME=/Users/hub/Applications/scala
## 
## export PATH=/Users/hub/bin:$PATH:/Users/hub/Applications/android-sdk-mac_86/tools:/Users/hub/.gem/ruby/1.8/bin:$JAVA_HOME/bin:$SCALA_HOME/bin
## 
## export AKKA_HOME=/Users/hub/Applications/akka

# this should go into mac specific config
# if [ -f `brew --prefix`/etc/autojump ]; then
#   . `brew --prefix`/etc/autojump
# fi
