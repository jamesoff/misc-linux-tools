# 95-aliases.sh
# Extra bash custimizations. The real magic happens in /usr/local/etc/bashrc.d
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_VERSION['aliases']=16.10.02
export ULE_RUNTIME=80

if groups | grep -Eq '\b(wheel|root|admin|adm)\b'; then
	alias grouplist="column -s: -t /etc/group | sort -nk3"
	if hash zypper 2>/dev/null; then
		alias zypper="sudo zypper -s1 --userdata=$USER --gpg-auto-import-keys"
	fi
	if hash nmap 2>/dev/null; then
		alias nmap.full='sudo nmap -p1-65535 -T5 -sC -sV --version-all -O --open'
		alias nmap.quick='sudo nmap -T5 -sC -sV --version-all -O --open'
		alias nmap.irc="sudo nmap -p U:23,53,123,T:194,6667,6668,6669,6670,6697,7000,7001,443,80,8080 -T5 -sC -sV --version-all --open"
	fi
	if hash hddtemp 2>/dev/null; then
		alias hddtemp="hddtemp -uF"
	fi
fi

if hash colordiff 2>/dev/null; then
	alias diff="`command -v colordiff`"
fi

if hash colorsvn 2>/dev/null; then
	alias svn="`command -v colorsvn`"
fi

alias list-console-fonts="ls --sort=version /usr/share/kbd/consolefonts"
alias perldebug="perl -Ds"
alias super="sudo su -"

if [ -r "/usr/local/etc/vimrc.more" ]; then
	alias vmore="vim -u /usr/local/etc/vimrc.more - "
fi

if [ -n "$EDITOR" ]; then
	alias suedit="sudo \$EDITOR"
fi

if [ -n "$GUI_EDITOR" ]; then
	alias gsuedit="xdg-su -c \$GUI_EDITOR"
fi

if hash tree 2>/dev/null; then
	alias tree="tree -lshACDFv --dirsfirst"
fi

if hash glances 2>/dev/null; then
	alias glances="glances --disable-irix --fahrenheit"
fi

#alias di="di $DI_ARGS"

unalias dir 2>/dev/null
unalias vdir 2>/dev/null

if hash ip 2>/dev/null; then
    alias ip="ip -c"
fi

if hash qpaeq 2>/dev/null; then
	alias equalizer=qpaeq
fi

if hash kde-open5 2>/dev/null; then
	alias open="kde-open5"
elif hash kde-open 2>/dev/null; then
	alias open="kde-open"
fi

alias ls="_ls"
alias ll="ls -l --human --dereference --classify"
alias l="ls -lA --human --classify"
alias grep="grep --color=auto"

alias uname="ule_uname"

alias +="pushd ."
alias ..="cd .."
alias cd..="cd .."
alias cd-="cd -"

unset ULE_RUNTIME
