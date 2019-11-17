#!/bin/sh

. ./config.sh

MAILCMD=mutt

cd $AUTHORSDIR || exit
for email in *@etersoft.ru ; do
    [ -s "$email" ] || continue
    echo "Send to $email ..."
    $MAILCMD $email -s "Analyze results for $PROJECT project" < $email
done
