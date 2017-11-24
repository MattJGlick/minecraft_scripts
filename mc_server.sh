#!/bin/bash

BACKUP_DIR=/home/backups
SHUTDOWN_DELAY=5
SPIGOT_DIR=/home/spigot
TMUX_NAME=mc

setup() {
  if [ -d "$SPIGOT_DIR" ]; then
    echo "This SPIGOT_DIR already exists, not gonna mess it up"
    exit 3
  fi

  echo "Creating $SPIGOT_DIR"
  mkdir -p $SPIGOT_DIR
  cd $SPIGOT_DIR

  echo "Pulling down the needed packages"
  sudo apt-get -qy install "git" "openjdk-8-jre" "tar"

  echo "Pulling down the build tools"
  curl -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

  echo "Running the Build Tools"
  git config --global --unset core.autocrlf
  java -jar BuildTools.jar --rev latest

  echo "Creating and Signing the EULA"
  touch eula.txt
  echo "eula=true" > eula.txt

  crontab -l | { cat; echo "0 5 * * * $SPIGOT_DIR/mc_server backup"; } | crontab -
}

is_running() {
  tmux ls 2> /dev/null | grep $TMUX_NAME > /dev/null
}

send_msg() {
  if ! is_running; then
    echo "tmux session: $TMUX_NAME is not running, cant send msg"
    exit 1
  fi

  echo "saying \"$1\" to the boys"
  tmux send-key -t $TMUX_NAME "say $1" C-m
}

start() {
  if is_running; then
    echo "tmux session: $TMUX_NAME is already running, cant start"
    exit 1
  fi

  echo "Starting up the server at tmux session: $TMUX_NAME"
  tmux new -d -s $TMUX_NAME "java -Xms512M -Xmx1G -XX:MaxPermSize=128M -XX:+UseConcMarkSweepGC -jar $SPIGOT_DIR/spigot-*.jar"
}

stop() {
  if ! is_running; then
    echo "tmux session: $TMUX_NAME is not running, cant stop"
    exit 1
  fi

  send_msg "Shutting her down in $SHUTDOWN_DELAY seconds boys"
  sleep $SHUTDOWN_DELAY
  tmux send-key -t $TMUX_NAME "stop" C-m
}

status() {
  if ! is_running; then
    echo "tmux session: $TMUX_NAME is not running, cant get status"
    exit 1
  fi

  echo "Server is up"
  tmux send-key -t $TMUX_NAME "list" C-m
  grep -A1 "There are .* players online" $SPIGOT_DIR/logs/latest.log | tail -n 2 | awk -F 'INFO]: ' '{print $2}'
}

backup() {
  NOW=`date "+%Y-%m-%d_%Hh%M"`
  BACKUP_FILE="$BACKUP_DIR/world_${NOW}.tar"

  echo "Backing up minecraft world... $BACKUP_FILE"
  tar -P -C $SPIGOT_DIR -cf $BACKUP_FILE $SPIGOT_DIR

  echo "Compressing backup..."
  gzip -f $BACKUP_FILE
  echo "Done."
}

case "$1" in
  setup)
    setup
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    stop
    sleep 5
    start
    ;;
  backup)
    backup
    ;;
  send_msg)
    shift
    send_msg "$*"
    ;;
  attach)
    tmux attach -t $TMUX_NAME
    ;;
  *)
  echo $"Usage: $0 {setup|start|stop|attach|restart|send_msg|status}"
  exit 1
esac

exit 0
