#!/usr/bin/env bash
#   Copyright (C) 2016 Dan Reidy <dubkat@gmail.com>
#   Create a dynamically generated /etc/hosts file
#                                                                              #
#   This program is free software; you can redistribute it and/or modify       #
#   it under the terms of the GNU General Public License as published by       #
#   the Free Software Foundation; either version 2 of the License, or          #
#   (at your option) any later version.                                        #
#                                                                              #
#   This program is distributed in the hope that it will be useful,            #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#   GNU General Public License for more details.                               #
#                                                                              #
#   You should have received a copy of the GNU General Public License          #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.      #
#                                                                              #

CONFDIR=/usr/local/etc
CONFIGS="dynhosts.sys dynhosts.static dynhosts.dyn"

dynfile=/var/run/hosts.dyn
tmpfile=/tmp/${RANDOM}${RANDOM}${RANDOM}.txt

generate_file() {
  local mode=${1:?error. missing arg.}
  for conf in ${CONFIGS}; do
    if [ "${conf##*.}" = "$mode" ]; then
      if [ "$mode" != "dyn" ]; then
        cat "${CONFDIR}/${conf}" >> $tmpfile 2>/dev/null
      else
        for host in $(<${CONFDIR}/${conf}); do
          local ip=$(dig +short $host AAAA 2>/dev/null || dig +short $host A 2>/dev/null);
          if [ ${#ip} -gt 0 ]; then
            printf "${ip}\t${host}\n" >> $tmpfile;
          fi
          unset ip;
        done
      fi
    fi
  done
}

printf "# This hosts file was dynamically generated by dynhosts.sh \n" > $tmpfile
printf "# Any changes made here will be lost. \n" >> $tmpfile
printf "# See $CONFDIR/dynhosts.static if you wish to include changes. \n" >> $tmpfile
printf "\n" >> $tmpfile;

for type in sys static dyn; do
  generate_file $type;
done
mv "$tmpfile" "$dynfile"

if [ -f "/etc/hosts"  -a ! -k "/etc/hosts"  ]; then
  mv /etc/hosts /etc/hosts-$(date +%F).bak
fi
rm /etc/hosts >/dev/null 2>&1
ln -s "${dynfile}" "/etc/hosts"

exit 0