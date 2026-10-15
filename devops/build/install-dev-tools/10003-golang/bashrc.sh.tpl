#! /bin/bash

# >>> mirrors: golang >>>
# <<< mirrors: golang <<<
export GONOSUMDB='*'
if [[ -n $(alias g 2>/dev/null) ]]; then
    unalias g
fi
[ -s "${HOME}/.g/env" ] && \. "${HOME}/.g/env"
