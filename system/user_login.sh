#!/bin/bash

SSHCMD=$(echo "$SSH_ORIGINAL_COMMAND" | awk '{ print $1 }')
ME=$(id -u -n)
DOIT=Maybe
# Root is always allowed in order to not being locked out
for n in root $*
do
  if [ "$ME" = "$n" ]
  then
    DOIT=YES
    break
  fi
done

if [[ "$DOIT" == YES ]] || [[ "$SSHCMD" == "scp" ]] ||  [[ "$SSHCMD" == "rsync" ]] || [[ "$SSHCMD" == /usr/lib/openssh/sftp-server ]]
then
    sh -c "$SSH_ORIGINAL_COMMAND"
else
    cat <<EOF 1>&2

This account is restricted and the command is not allowed.

User $ME is locked out.

If you believe this is in error, please contact your system administrator.
EOF
    exit 1
fi

