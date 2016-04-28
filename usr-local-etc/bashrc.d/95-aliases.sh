# 95-aliases.sh
# Extra bash custimizations. The real magic happens in /usr/local/etc/bashrc.d
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_ALIAS_VERSION=16.04.24

if [ "$USER" = "root" ]; then
	alias grouplist="column -s: -t /etc/group | sort -nk3"
	alias userlist="column -s: -t /etc/passwd | sort -nk3 | colout '^([^ ]+)\s+([a-z])\s+([\d]+)\s+([\d]+)\s+(.*)\s+([^ ]+)\s+([^ ]+)$' white,black,red,yellow,white,none,none | colout '/dev/null|/sbin/nologin' red bold | colout '/home/[^ ]+|/bin/b?[kac]sh' green bold"
	alias dmesg="dmesg --human"
fi

if groups | grep -Eq '\b(wheel|root)\b'; then
	if hash zypper 2>/dev/null; then
		alias zypper="sudo zypper -s1 --userdata=$USER --gpg-auto-import-keys"
	fi
	if hash nmap 2>/dev/null; then
		alias nmap.full='sudo nmap -p1-65535 -T5 -sC -sV --version-all -O --open'
		alias nmap.netscout='sudo nmap -sn --open'
		alias nmap.quick='sudo nmap -T5 -sC -sV --version-all -O --open'
	fi
	if hash hddtemp 2>/dev/null; then
		alias hddtemp="hddtemp -uF"
	fi
fi


alias list-console-fonts="ls --sort=version /usr/share/kbd/consolefonts"
alias perldebug="perl -Ds"
alias super="sudo su -"

if [ -r "/usr/local/etc/vimrc.more" ]; then
	alias vmore="vim -u /usr/local/etc/vimrc.more - "
fi

if [ ! -z "$EDITOR" ]; then
        alias suedit="sudo \$EDITOR"
fi

if [ ! -z "$GUI_EDITOR" ]; then
        alias gsuedit="xdg-su -c \$GUI_EDITOR"
fi

alias tree="tree -lshACDFv --dirsfirst"
#alias di="di $DI_ARGS"

unalias dir 2>/dev/null
unalias vdir 2>/dev/null

if hash qpaeq 2>/dev/null; then
        alias equalizer=qpaeq
fi

if hash kde-open5 2>/dev/null; then
	alias open="kde-open5"
elif hash kde-open 2>/dev/null; then
	alias open="kde-open"
fi


alias +="pushd ."
alias ..="cd .."
alias cd..="cd .."
alias cd-="cd -"

