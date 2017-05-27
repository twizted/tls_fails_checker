#!/bin/bash

#  TLS handshake fails checker for Sendmail
#  Copyright (C) 2016 Armando Vega
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.


DOMAIN_FILE="/dev/shm/tls_domain_fails.txt"
DOMAIN_TMP="/dev/shm/tls_domain_fails.tmp"
DOMAIN_LAST="/dev/shm/tls_domain_fails.last"

SMAIL_ACCESS="/etc/mail/access"
SMAIL_LOG="/var/log/maillog"

MAIL_SUBJECT="ExampleCompany: TLS handshake fails"
MAIL_SENDER="noreply@example.com"
MAIL_RCPT="fails@example.com"

DOMAINS=$(grep -oh "ruleset=tls_server.*TLS handshake failed" $SMAIL_LOG | cut -d ',' -f3 | cut -d '=' -f2 | sort -u)

if [ -f $DOMAIN_FILE ]; then
	DOMAINS="$DOMAINS $(<$DOMAIN_FILE)"
fi

if [ ! -f $DOMAIN_LAST ]; then
	echo "" > $DOMAIN_LAST
fi

DOMAINS=$(sed -e 's/ /\\n/g' <<< $DOMAINS)

echo -e $DOMAINS > $DOMAIN_FILE
sort -u $DOMAIN_FILE -o $DOMAIN_FILE

KNOWN_DOMAINS=$(grep -i "Try_TLS:.*NO" $SMAIL_ACCESS | cut -d ':' -f2 | sed -e 's/ /\t/g' | cut -f1)

for i in $KNOWN_DOMAINS; do
	grep -v $i $DOMAIN_FILE > $DOMAIN_TMP
	cp $DOMAIN_TMP $DOMAIN_FILE
done;

if [ -f $DOMAIN_TMP ]; then
	rm $DOMAIN_TMP
fi

diff $DOMAIN_FILE $DOMAIN_LAST > /dev/null 2>&1
if [ $? -ne 0 ]; then
	cat $DOMAIN_FILE | mail -s "$MAIL_SUBJECT" -r $MAIL_SENDER $MAIL_RCPT
fi

cp $DOMAIN_FILE $DOMAIN_LAST
