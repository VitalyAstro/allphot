# -*-bash-*-
#!/usr/bin/env bash

# very simple so far, needs more work
check_exist() {
    if [[ ! -f ${1} ]]; then
	echo "*** Error: file ${1} not found." >&2
	return -1
    fi
}

# return false if a catalog has less than 5 lines
check_catalog() {
    if [[ $(wc -l ${1} | cut -d ' ' -f1) -lt 5  ]]; then
	echo "*** Error: ${1} is not a valid catalog" >&2
	return -1
    fi
    return 0
}

# return false if fwhm from psf is not between 0.5 and 20
check_psf() {
    local ifwhm10=$(awk 'NR==2 {print int(($1+$2)*11.76); exit}' ${1} 2> /dev/null)    
    if [[ -z ${ifwhm10} ]] || [[ ${ifwhm10} -lt 5 ]] || [[ ${ifwhm10} -gt 200 ]]; then
	echo "*** Error: ${1} is not a valid PSF file, ${ifwhm10}" >&2
	return -1
    fi
    return 0
}

# get_psf_fwhm <psf file>
get_psf_fwhm() {
    awk 'NR==2 {print ($1+$2)*1.176; exit}' ${1} 2> /dev/null
}

daophot_process_init() {
    check_exist ${1} || return -1
    local imagepath="$(readlink -f ${1})"
    local image=$(basename ${1%.*})
    ALLPHOT_PROCESS_DIR=${PWD}/${image}_daophot
    mkdir -p ${ALLPHOT_PROCESS_DIR}
    pushd ${ALLPHOT_PROCESS_DIR} &> /dev/null
    [[ ! -r daophot.opt ]]   && cp ${ALLPHOT_OPT_DAOPHOT} daophot.opt
    [[ ! -r photo.opt ]]     && cp ${ALLPHOT_OPT_PHOTO} photo.opt
    [[ ! -r allstar.opt ]]   && cp ${ALLPHOT_OPT_ALLSTAR} allstar.opt
    [[ ! -r ${image}.fits ]] && ln -sfn ${imagepath} ${image}.fits
    return 0
}

daophot_process_end() {
    popd &> /dev/null
}

# check if queue is empty and return the number of processing jobs
allphot_check_queue() {
    local pids=${ALLPHOT_PIDS} p i
    for p in ${pids}; do
	# check at least one process has finished
	if [[ -z $(ps -p ${p} -o pid=) ]] ; then
            # regenerate the list of processes
	    ALLPHOT_PIDS=""
	    for i in ${pids}; do
		[[ -n $(ps -p ${p} -o pid=) ]] && ALLPHOT_PIDS="${ALLPHOT_PIDS} ${i}"
	    done
	    break
	fi
    done
}

# allphot_process <action> <fits files>
allphot_process() {
    local action
    local njobs=1
    while [[ $# -gt 0 ]]; do
	case "${1}" in
	    -a=* | --action=*) action="${1##*=}" ;;
	    -j=* | --jobs=*) njobs="${1##*=}" ;;
	    --) shift; break ;;
	*) break ;;
	esac
	shift
    done

    if [[ -x ${action} ]]; then
	echo "*** Error: ${1} is not a valid action to process" >&2
	return -1
    fi
    
    # very simple automatic process (not portable)
    [[ ${njobs} == auto ]] && njobs=$(grep -c processor /proc/cpuinfo)
    [[ ${njobs} -gt $# ]] && njobs=$#
    [[ ${njobs} -gt 2 ]] && echo " >>> Will run ${njobs} jobs simultaneously"
    
    local j=0 image
    while [[ $# -gt 0 ]]; do
	image=$(basename ${1%.*})
	echo " >>> Starting job ${j} on ${image}"
	eval "${action}" ${1} &> allphot.job.${j}.${image}.log &
	ALLPHOT_PIDS="${ALLPHOT_PIDS} $!"
	j=$(( ${j} + 1 ))
	while [[ $(echo ${ALLPHOT_PIDS} | wc -w) -ge ${njobs} ]]; do
	    allphot_check_queue
	    sleep 0.4
	done
	shift
    done
    # wait for all processes to finish before exit
    wait
}
    
