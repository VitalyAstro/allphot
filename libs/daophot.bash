#@BASH@
# -*-bash-*-

# daophot_opt <optfile>
daophot_opt() {
    cat <<-EOF
	OPTION
	${1}

EOF
}

# daophot_attach <file without extension>
daophot_attach() {
    echo "ATTACH ${1}"
}

# daophot_find <output file>
daophot_find() {
    cat <<-EOF
	FIND
	1,1
	${1}
	y

EOF
}

# daophot_phot <phot options file> <input file> <output file>
daophot_phot() {
    cat <<-EOF
	PHOT
	${1}

	${2}
	${3}
EOF
}

# daophot_phot_with_psf <phot options file> <psf phot file> <input id file> <output file>
daophot_phot_with_psf() {
    cat <<-EOF
	PHOT
	${1}

	${2}
	${3}
	${4}

EOF
}

# daophot_pick <input file> <nstars> <mag faint> <output psf stars file>
daophot_pick() {
    cat <<-EOF
	PICK
	${1}
	${2} ${3}
	${4}
EOF
}

# daophot_psf <input mag file> <input psf stars file> <output psf file> 
# do two rounds
daophot_psf() {
    cat <<-EOF
	PSF
	${1}
	${2}
	${3}

EOF
}

# allstar_standard <fits file> <input psf file> <input mag file> <output allstar file>
daophot_allstar() {
    cat <<-EOF

	${1}
	${2}
	${3}
	${4}
	${1}s
EOF
}

# daophot_append <input 1>  <input 2> <merged file>
daophot_append() {
    cat <<-EOF
	APPEND
	${1}
	${2}
	${3}
EOF
}

# daophot_offset <input file> <ID DX DY DMAG> <output>
daophot_offset() {
    cat <<-EOF
	OFFSET
	${1}
	${2} ${3} ${4} ${5}
	${6}
EOF
}
