#!/bin/bash

export COMPSET='1850_DATM%CRUJRA2024b_CLM60%FATES-NCFB%NORESM_SICE_SOCN_SROF_SGLC_SWAV'
export RES=f09_g17
export MACH='betzy'
export PROJECT='nn9188k'
export USER='jessica'
export workpath='/cluster/work/users/jessica'

export TAG='noresm-fates-f09-wiemip-nofire-COU_v2'
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

# 
./xmlchange STOP_N=25
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=25
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=5
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=1850-01-01
./xmlchange CLM_ACCELERATED_SPINUP=off
./xmlchange DATM_YR_START=1850
./xmlchange DATM_YR_END=2000
./xmlchange DATM_YR_ALIGN=1850
./xmlchange DATM_PRESAERO=clim_1850
./xmlchange CLM_CO2_TYPE=diagnostic
./xmlchange DATM_CO2_TSERIES=cmip7_20tr
./xmlchange CCSM_BGC=CO2A

# For real runs
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
./xmlchange EXEROOT=/cluster/work/users/jessica/wiemip_runs_v2/noresm-fates-f09-wiemip-overshoot-CTRL_v2.2026-09-03/bld

cat >>  user_nl_clm <<EOF
fsurdat='/cluster/work/users/jessica/wiemip_misc/surfdata_0.9x1.25_hist_1850_16pfts_WIEMIP_c260408.nc'
finidat=''
use_fates_sp=.false.
use_fates_nocomp=.true.
use_fates_fixed_biogeog=.true.
do_transient_lakes = .false.
do_transient_urban = .false.
fates_stomatal_model='medlyn2011'
fates_lu_transition_logic = 1
use_fates_luh=.true.
use_fates_lupft=.true.
fates_harvest_mode='luhdata_area'
use_fates_potentialveg=.false.
fluh_timeseries='/cluster/work/users/jessica/wiemip_misc/LUH2_1850_steadystate_0.9x1.25_c260515.nc'
flandusepftdat='/cluster/work/users/jessica/wiemip_misc/fates_landuse_pft_surfdata_0.9x1.25_c260515.nc'
fates_spitfire_mode=0
stream_year_first_popdens=1850
stream_year_last_popdens=1850
model_year_align_popdens=1850
hist_mfilt = 1, 1
hist_nhtfrq = 0, -8760
hist_fincl1=
'MEG_acetone','FSR','FSDS','ALT','FATES_WILDFIRE_BURNFRAC',
'FATES_FUEL_AMOUNT_FC','CH4PROD','SOM_C_LEACHED',
'QFLX_EVAP_TOT','FATES_LEAF_ALLOC_SZPF',
'FATES_BGSAPWOOD_ALLOC_SZPF','FATES_BGSTRUCT_ALLOC_SZPF',
'FATES_FROOT_ALLOC_SZPF',
'FATES_AGSAPWOOD_ALLOC_SZPF','FATES_AGSTRUCT_ALLOC_SZPF',
'FROST_TABLE','FATES_FIRE_CLOSS','FATES_FIRE_CLOSS_LIVEFUELS',
'FATES_FIRE_INTENSITY','FATES_MORTALITY_FIRE_CFLUX_PF',
'FATES_VEGC_PF','FATES_IGNITIONS','FATES_ROS',
'FATES_LEAFCTURN_USTORY_SZ','FATES_LEAFCTURN_CANOPY_SZ',
'FATES_MORTALITY_CFLUX_PF','FATES_LEAFC','FATES_VEGC',
'FATES_LITTER_OUT','SABV','FSDSVD',
'FATES_FROOTCTURN_CANOPY_SZ','FATES_FROOTCTURN_USTORY_SZ',
'FATES_CROOTCTURN_CANOPY_SZ','FATES_CROOTCTURN_USTORY_SZ',
'FATES_FROOTC','FATES_CROOTC','FATES_VEGC',
'FATES_LITTER_IN',
'FATES_STRUCTCTURN_CANOPY_SZ','FATES_SAPWOODCTURN_CANOPY_SZ',
'FATES_STRUCTCTURN_USTORY_SZ','FATES_SAPWOODCTURN_USTORY_SZ', 
'FATES_SAPWOODC','FATES_STRUCTC',
'FATES_GPP','FATES_GPP_PF',
'MEG_isoprene','FATES_LAI','FATES_LAI_PF',
'FIRA','MEG_methanol',
'FATES_FUEL_MOISTURE_FC','QRUNOFF',
'TOTSOILLIQ','TOTSOILICE',
'FCO2','FATES_NPP','FATES_NPP_PF',
'RAIN','SNOW','RH2M','FSH',
'EFLX_LH_TOT','QDRAI','FATES_AUTORESP','HR',
'SNOWDP','SOILICE',
'FATES_FROOTMAINTAR','FATES_CROOTMAINTAR',
'FATES_GROWTH_RESP','FATES_CROOT_ALLOC','FATES_FROOT_ALLOC',
'FATES_SEED_ALLOC','FATES_LEAF_ALLOC','FATES_STEM_ALLOC',
'HR_vr','TSOI','H2OSNO','TSA','FATES_TVEG','QVEGT',
'FINUNDATED',
'CH4_SURF_DIFF_SAT','CH4_SURF_EBUL_SAT','CH4_SURF_AERE_SAT',
'U10','ZWT_PERCH','CH4PROD', 
'H2OSOI','FATES_FUEL_MEF', 
'FSDSVI','QSOIL', 
'FATES_FRACTION',
hist_fincl2=
'FATES_CWD_ABOVEGROUND_DC', 'FATES_CWD_BELOWGROUND_DC', 
'FATES_LEAFC','FATES_LITTER_AG_CWD_EL', 'FATES_LITTER_AG_FINE_EL',
'FATES_FROOTC', 'FATES_CROOTC','TOTSOMC', 'TOTSOMC_1m',
'SOILC_vr','SOM_ACT_C', 'SOM_PAS_C', 'SOM_SLO_C',
'FATES_VEGC','FATES_VEGC_PF',
'FATES_SAPWOODC','FATES_STRUCTC',
'FATES_NOCOMP_PATCHAREA_PF','FATES_FRACTION'
EOF

cp /cluster/shared/noresm/inputdata/WIEMIP/wiemip_COU_datm.streams user_nl_datm_streams

./case.setup
#./case.build
./case.submit
