# Minecraft Server Management

A simple bash script for minecraft server management.

## Quickstart

```
chmod +x mc_server.sh
./mc_server setup
```

## Settings:

```
BACKUP_DIR: Directory where backups should be stored
SHUTDOWN_DELAY: Delay between sending the shutdown command and actual shutdown (ex. 5)
SPIGOT_DIR: Directory where the spigot-*.jar lives
TMUX_NAME: name of the tmux session to be used (ex. mc)
```

## Usage

```
$ ./mc_server.sh
Usage: ./mc_server.sh {setup|start|stop|attach|restart|send_msg|status}

$ ./mc_server status
Server is up
There are 0 out of maximum 20 players online.
```

## Notes

Most of this can be copy/pasted for other servers. The `setup` function is specific to Spigot, but the start/stop can be easily edited for other versions.
