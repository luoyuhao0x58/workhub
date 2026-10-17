[program:emacs]
; Foreground Emacs daemon, managed by supervisor. `--fg-daemon` keeps the
; process in the foreground so supervisor can track it (plain `--daemon`
; forks to the background and supervisor would lose the child). The
; socket path is pinned under /var/run, so neither the daemon nor the
; client depends on XDG_RUNTIME_DIR.
;
; The build user gets RENAMED at container start (name AND home may
; change; the uid does not), so this program must never reference the
; user by name:
;   - `user=` takes a numeric uid, which supervisor accepts natively;
;   - HOME/USER are looked up from passwd BY UID at spawn time, so the
;     daemon automatically follows any runtime rename.
command=/bin/bash -c 'exec env HOME="$(getent passwd @@BUILD_UID@@ | cut -d: -f6)" USER="$(getent passwd @@BUILD_UID@@ | cut -d: -f1)" /usr/bin/emacs --fg-daemon=@@EMACS_SOCKET_DIR@@/server.sock'
user=@@BUILD_UID@@
autostart=false
autorestart=true
startsecs=5
stopsignal=TERM
stdout_logfile=/var/log/supervisor/emacs.log
stderr_logfile=/var/log/supervisor/emacs.err.log
