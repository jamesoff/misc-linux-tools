# 99-functions.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat@gmail.com>
ULE_FUNC_VERSION=16.04.30


generate_path() {
  local user="/opt/local/libexec/gnubin /opt/local/bin /usr/local/bin /usr/games /opt/bin /usr/bin /bin";
  local admin="/usr/local/sbin /opt/local/sbin /opt/sbin /usr/sbin /sbin";
  #local portage="$(/usr/bin/gcc-config -B) /lib64/rc/bin";
  local path;
  if ! groups | /bin/grep -qE '\b(root|wheel|adm|operator)\b'; then
    unset admin
  fi
  if ! groups | /bin/grep -qE '\b(portage)\b'; then
    unset portage
  fi
  for x in ${HOME}/bin $portage $admin $user; do
    [[ -d $x ]] && [[ -x $x ]] && {
      [[ ${#path} > 0 ]] && path+=":"
      path+=${x}
    };
  done
  echo "export PATH=$path"
}


genpasswd() {
  local arg=$1
  : ${arg:-256}
  if hash random.sh 2>/dev/null; then
    random.sh $arg
  else
    echo "please download random.sh from github"
  fi
}

perlmodtest() {
  local module="${1:?a Module::Name is required as an arguement.}"
  perl -C6 -M${module} -le '{ printf "Module %s Loaded OK.\n", shift;  }' $module
  #perl -T -Mstrict -M${module} -le '{ printf "* Module %s was found in \@INC\n", shift }' ${module}
}

crypt_backend ()
{
  if ! hash rpm 2>/dev/null; then
    echo "This function requires an rpm based system."
    return 1
  fi
  shared="${1:?first argument must be a shared execuatble}"
  if [ ! -f "$shared" ]; then
    if ! hash $shared 2>/dev/null; then
      echo "error: $shared is not found." >&2
      return 1
    else
      shared="$(hash -t $shared)"
    fi
  fi
  rpm -qf $shared --queryformat "%{N}/%{V}:\t$shared\n";
  for backend in $(ldd $shared | egrep '(gcrypt|nettle|weed|libssl|libcrypto)' | awk '{ print $3 }'); do
    rpm -qf $backend --queryformat "%{N}/%{V}:\t$backend\n";
  done
}

function mkxdgtmp() {
  test -d "${TMPDIR}" || { mkdir -p "${TMPDIR}" >/dev/null; chmod 700 "${TMPDIR}" >/dev/null; }
  mountpoint -q "${TMPDIR}" || { mount "${TMPDIR}" >/dev/null 2>&1; }
}

function vman {
  /usr/bin/man $* | col -bp | iconv -c | view -c 'set ft=man nomod nolist' -
}

#random_mac() {
#  echo "Switching off radio for mac address change."
#  ifconfig wlp2s0 down
#  macchanger -A wlp2s0
#  macchanger -e wlp2s0
#  ifconfig wlp2s0 up
#  echo "macchange complete"
#}

#default_mac() {
#  local default=00:00:d8:00:00:01
#  ifconfig wlp2s0 down
#  if [ ${#default} ]; then
#    macchanger -mac="$default" wlp2s0
#  else
#    macchanger --permanent wlp2s0
#  fi
#  ifconfig wlp2s0 up
#}
