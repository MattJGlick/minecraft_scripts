#!/bin/bash

# delete the old spigot folder
rm -rf spigot

# make a folder for spigot
mkdir spigot
cd spigot

# update everything
sudo apt-get -qy install "git" "openjdk-7-jre-headless" "tar"

# get build tools
curl -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

# run build tools
git config --global --unset core.autocrlf
java -jar BuildTools.jar --rev latest

# sign the eula
sed -i -e 's/false/true/g' eula.txt

# create the start up file
touch start.sh

# write the start up file
cat > start.sh << EOF1
#!/bin/sh

java -Xms512M -Xmx1G -XX:MaxPermSize=128M -XX:+UseConcMarkSweepGC -jar spigot-1.10.2.jar
EOF1

# make it executable
chmod +x start.sh
