# -*-bash-*-  vim: ft=bash

# basename and dirname functions
# transparent bash-only replacements for the external commands
# extended pattern matching (shopt -s extglob) is required
basename() {
    local path=$1 suf=$2

    if [[ -z ${path} ]]; then
	echo
	return
    fi

   # remove any trailing slashes
    path=${path%%*(/)}

    # remove everything up to and including the last slash
    path=${path##*/}

    # remove any suffix
    [[ ${suf} != "${path}" ]] && path=${path%"${suf}"}

    # output the result, or "/" if we ended up with a null string
    echo "${path:-/}"
}

dirname() {
    local path=$1

    if [[ -z ${path} ]]; then
	echo .
	return
    fi
    
    # remove any trailing slashes
    path=${path%%*(/)}

    # if the path contains only non-slash characters, then dirname is cwd
    [[ ${path:-/} != */* ]] && path=.

    # remove any trailing slashes followed by non-slash characters
    path=${path%/*}
    path=${path%%*(/)}

    # output the result, or "/" if we ended up with a null string
    echo "${path:-/}"
}

canonicalise() {
    /usr/bin/readlink -f "$@"
}

# relative_name
# Convert filename $1 to be relative to directory $2 (both must exist).
relative_name() {
    local path=$(canonicalise "$1") dir=$(canonicalise "$2") c
    while [[ -n ${dir} ]]; do
	c=${dir%%/*}
	dir=${dir##"${c}"*(/)}
	if [[ ${path%%/*} = ${c} ]]; then
	    path=${path##"${c}"*(/)}
	else
	    path=..${path:+/}${path}
	fi
    done
    echo "${path:-.}"
}
