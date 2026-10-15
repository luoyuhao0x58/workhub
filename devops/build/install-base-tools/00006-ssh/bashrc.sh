#! /usr/bin/bash

ssh_agent_env=~/.ssh/agent.env
agent_load_env () { test -f "$ssh_agent_env" && . "$ssh_agent_env" >| /dev/null ; }
agent_start () {
  (umask 077; ssh-agent >| "$ssh_agent_env")
  . "$ssh_agent_env" >| /dev/null ; }
agent_load_env
# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
  agent_start
  if [ ! -z "$SSH_TTY" ] || [ ! -z "$VSCODE_IPC_HOOK_CLI" ]; then
    ssh-add
  fi
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
  if [ ! -z "$SSH_TTY" ] || [ ! -z "$VSCODE_IPC_HOOK_CLI" ]; then
    ssh-add
  fi
fi
unset ssh_agent_env