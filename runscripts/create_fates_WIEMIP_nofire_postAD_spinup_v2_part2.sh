#!/bin/bash

export COMPSET='1850_DATM%CRUJRA2024b_CLM60%FATES-NCFB%NORESM_SICE_SOCN_SROF_SGLC_SWAV'
export RES=f09_g17
export MACH='olivia'
export PROJECT='nn9560k'
export USER='jessica'
export workpath='/cluster/work/projects/nn9188k/jessica'

export TAG='noresm-fates-f09-wiemip-nofire-postAD-spinup_v2_part2'
export CASEROOT=$workpath/wiemip_runs_v2
export CIMEROOT=$workpath/noresm-wiemip/CTSM/cime/scripts

cd ${CIMEROOT}

export CIME_HASH=`git log -n 1 --pretty=%h`
export NorESM_CTSM_HASH=`(cd ../..;git log -n 1 --pretty=%h)`
export FATES_HASH=`(cd src/fates;git log -n 1 --pretty=%h)`
export GIT_HASH=N${NorESM_CTSM_HASH}-F${FATES_HASH}	
export CASE_NAME=${CASEROOT}/${TAG}.`date +"%Y-%m-%d"`


# REMOVE EXISTING CASE DIRECTORY IF PRESENT 
rm -rf ${CASE_NAME}

# CREATE THE CASE
./create_newcase --case=${CASE_NAME} --res=${RES} --compset=${COMPSET} --mach=${MACH} --project=${PROJECT} --run-unsupported

cd ${CASE_NAME}

./xmlchange STOP_N=25
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=25
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=1
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=501-01-01 # check this matches end of AD spinup run
./xmlchange CLM_ACCELERATED_SPINUP=off
./xmlchange CCSM_CO2_PPMV=280.
./xmlchange DATM_YR_START=1850
./xmlchange DATM_YR_END=1869
./xmlchange DATM_PRESAERO=clim_1850

./xmlchange --subgroup case.run JOB_WALLCLOCK_TIME=24:00:00
./xmlchange --subgroup case.st_archive JOB_WALLCLOCK_TIME=00:30:00

./xmlchange CLM_BLDNML_OPTS="-bgc fates -megan"

./xmlchange NTASKS_CPL=1536
./xmlchange NTASKS_ATM=256
./xmlchange NTASKS_LND=1536
./xmlchange ROOTPE_CPL=256
./xmlchange ROOTPE_ATM=0
./xmlchange ROOTPE_LND=256

./xmlchange RUNDIR=${CASE_NAME}/run
#./xmlchange EXEROOT=${CASE_NAME}/bld

# use existing build
./xmlchange BUILD_COMPLETE=TRUE
./xmlchange EXEROOT=/cluster/work/projects/nn9188k/jessica/wiemip_runs_v2/noresm-fates-f09-wiemip-nofire-AD-spinup_v2.2026-08-24/bld

cat >>  user_nl_clm <<EOF
finidat='/cluster/work/projects/nn9188k/jessica/wiemip_runs_v2/noresm-fates-f09-wiemip-nofire-postAD-spinup_v2.2026-08-30/run/noresm-fates-f09-wiemip-nofire-postAD-spinup_v2.2026-08-30.clm2.r.0501-01-01-00000.nc'
fsurdat='/cluster/work/projects/nn9560k/inputdata/lnd/clm2/surfdata_esmf/ctsm5.4.0/surfdata_0.9x1.25_hist_1850_16pfts_WIEMIP_c260408.nc'
use_fates_sp=.false.
use_fates_nocomp=.true.
use_fates_fixed_biogeog=.true.
do_transient_lakes = .false.
do_transient_urban = .false.
fates_stomatal_model='medlyn2011'
fates_spitfire_mode=0
stream_year_first_popdens=1850
stream_year_last_popdens=1850
fates_lu_transition_logic = 1
use_fates_luh=.true.
use_fates_lupft=.true.
fates_harvest_mode='luhdata_area'
use_fates_potentialveg=.false.
fluh_timeseries='/cluster/work/projects/nn9188k/jessica/wiemip-lufiles/LUH2_1850_steadystate_0.9x1.25_c260515.nc'
flandusepftdat='/cluster/work/projects/nn9188k/jessica/wiemip-lufiles/fates_landuse_pft_surfdata_0.9x1.25_c260515.nc'
hist_empty_htapes=.true.
hist_fincl1='FCO2', 'TOTSOMC', 'FATES_NPP_LU',
'FATES_GPP_LU','FATES_VEGC_PF', 'FATES_VEGC_LU', 'FATES_LAI', 'FATES_GPP_PF'
EOF

cp /cluster/work/projects/nn9560k/inputdata/WIEMIP/wiemip_spinup_datm.streams user_nl_datm_streams

./case.setup
#./case.build
./case.submit
