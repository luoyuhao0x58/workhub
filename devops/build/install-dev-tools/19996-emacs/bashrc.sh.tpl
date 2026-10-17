# Attach a terminal frame to the supervised Emacs daemon.
# `-s` pins the socket path (kept in sync with emacs.conf.tpl) so the
# client never depends on XDG_RUNTIME_DIR; `-a ""` makes emacsclient
# fail fast instead of spawning a brand-new Emacs that would race the
# daemon for the server socket. The path is keyed by uid, immune to
# the runtime user rename.
function em() {
    emacsclient --tty -s @@EMACS_SOCKET_DIR@@/server.sock --alternate-editor= "$@"
}
