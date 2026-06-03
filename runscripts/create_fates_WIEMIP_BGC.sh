#!/bin/bash

export COMPSET='1850_DATM%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
export RES=f09_g17
export MACH='olivia'
export PROJECT='nn9188k'
export USER='jessica'
export workpath='/cluster/work/projects/nn9188k/jessica'

export TAG='noresm-fates-f09-wiemip-BGC'
export CASEROOT=$workpath/wiemip_runs
export CIMEROOT=$workpath/noresm-wiemip-beta16/CTSM/cime/scripts

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
./xmlchange STOP_N=10
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=10
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=14
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=1850-01-01
./xmlchange CLM_ACCELERATED_SPINUP=off
./xmlchange DATM_YR_START=1850
./xmlchange DATM_YR_END=1869
./xmlchange DATM_YR_ALIGN=1850
./xmlchange DATM_PRESAERO=clim_1850
./xmlchange CLM_CO2_TYPE=diagnostic
./xmlchange DATM_CO2_TSERIES=20tr
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
./xmlchange EXEROOT=${CASE_NAME}/bld

# use existing build
#./xmlchange BUILD_COMPLETE=TRUE
#./xmlchange EXEROOT=/cluster/work/projects/nn9188k/jessica/wiemip_runs/noresm-fates-f09-wiemip-CTRL.2026-06-01/bld

cat >>  user_nl_clm <<EOF
fsurdat='/cluster/work/projects/nn9560k/inputdata/lnd/clm2/surfdata_esmf/ctsm5.4.0/surfdata_0.9x1.25_hist_1850_16pfts_WIEMIP_c260408.nc'
finidat='/cluster/work/projects/nn9188k/jessica/archive/noresm-fates-f09-wiemip-postAD-spinup.2026-05-28/rest/0611-01-01-00000/noresm-fates-f09-wiemip-postAD-spinup.2026-05-28.clm2.r.0611-01-01-00000.nc'
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
fluh_timeseries='/cluster/work/projects/nn9188k/jessica/wiemip-lufiles/LUH2_1850_steadystate_0.9x1.25_c260515.nc'
flandusepftdat='/cluster/work/projects/nn9188k/jessica/wiemip-lufiles/fates_landuse_pft_surfdata_0.9x1.25_c260515.nc'
fates_spitfire_mode=4
stream_year_first_popdens=1850
stream_year_last_popdens=1850
model_year_align_popdens=1850
hist_dov2xy= .true., .false., .true., .false.
hist_mfilt = 1, 1, 1, 1
hist_nhtfrq = 0, 0, -8760, -8760
hist_fincl1=
'QFLX_EVAP_TOT', 'QRUNOFF', 'FATES_WILDFIRE_BURNFRAC', 'FATES_LAI', 'FATES_FRACTION', 'TOTSOILLIQ',
'TSOI', 'H2OSOI',  'TSA', 'RAIN', 'SNOW', 'FSR', 'FSDS', 'ZWT_PERCH', 'FATES_LAI_PF',
'FATES_GPP', 'FATES_AUTORESP', 'FATES_NPP', 'HR', 'FATES_FIRE_CLOSS',
'FATES_FROOTMAINTAR', 'FATES_CROOTMAINTAR',
'FATES_GROWTH_RESP', 'FATES_CROOT_ALLOC', 'FATES_FROOT_ALLOC', 
'FATES_SEED_ALLOC', 'FATES_LEAF_ALLOC', 'FATES_STEM_ALLOC',
'FATES_LAI_PF',
'FCO2', 'FATES_GPP_PF', 'FATES_NPP_PF', 'FATES_LITTER_IN',
'FATES_LEAFCTURN_USTORY_SZ', 'FATES_LEAFCTURN_CANOPY_SZ',
'FATES_STRUCTCTURN_CANOPY_SZ', 'FATES_SAPWOODCTURN_CANOPY_SZ',
'FATES_STRUCTCTURN_USTORY_SZ', 'FATES_SAPWOODCTURN_USTORY_SZ', 
'FATES_MORTALITY_CFLUX_PF' , 'FATES_LEAFC', 'FATES_VEGC', 'FATES_SAPWOODC', 
'FATES_STRUCTC', 'FATES_FROOTC', 'FATES_CROOTC',
'FATES_LITTER_OUT', 'HR_vr',
'FATES_LEAF_ALLOC_SZPF',
 'FATES_BGSAPWOOD_ALLOC_SZPF', 'FATES_BGSTRUCT_ALLOC_SZPF', 
'FATES_AGSAPWOOD_ALLOC_SZPF', 'FATES_AGSTRUCT_ALLOC_SZPF',
'FATES_FROOT_ALLOC_SZPF', 'FATES_FIRE_CLOSS_LIVEFUELS', 
'NDEP_TO_SMINN', 'NET_NMIN', 'SMIN_NO3_LEACHED', 'SMIN_NO3_RUNOFF', 
'F_DENIT', 'F_N2O_DENIT', 'CH4_SURF_DIFF_SAT', 'CH4_SURF_EBUL_SAT', 'CH4_SURF_AERE_SAT',
'FINUNDATED', 'CH4PROD','MEG_isoprene', 'MEG_methanol', 'MEG_acetone', 
'FATES_FIRE_INTENSITY', 'FATES_FUEL_AMOUNT_FC', 'FATES_FUEL_MEF', 'FATES_IGNITIONS',
'FATES_MORTALITY_FIRE_CFLUX_PF', 'FATES_VEGC_PF', 'FATES_ROS','SOM_C_LEACHED', 'RH2M',
'U10', 'FIRA', 'FSH', 'EFLX_LH_TOT', 'FROST_TABLE', 'SABV', 'FSDSVI', 
'FSDSVD', 'FATES_TVEG', 'QDRAI', 'SNOWDP', 'H2OSOI', 'SOILICE', 'TSOI', 'H2OSNO', 'ALT', 
'QVEGT', 'F_N2O_NIT', 'F_NIT', 'CH4PROD', 
'CH4_SURF_EBUL_SAT', 'CH4_SURF_AERE_SAT' , 'SOM_ACT_C', 'SOM_PAS_C', 'SOM_SLO_C',
hist_fincl2='QFLX_EVAP_TOT', 'QVEGT', 'QSOIL', 'FSR', 'FSDS',
'SNOWDP', 'FSH', 'FIRA', 'MEG_isoprene', 'MEG_methanol', 'MEG_acetone'
hist_fincl3=
'FATES_NOCOMP_PATCHAREA_PF', 'FATES_FRACTION', 'FATES_VEGC',
'TOTSOMC', 'TOTSOMC_1m', 'SOILC_vr', 'FATES_VEGC_PF',
'TOTSOMN',  'SMINN',
'FATES_LITTER_AG_CWD_EL', 'FATES_LITTER_AG_FINE_EL',
 'TOTSOMC', 'TOTSOMC_1m', 'SOILC_vr', 'FATES_VEGC_PF', 
'FATES_LEAFC', 'FATES_SAPWOODC', 'FATES_STRUCTC', 'FATES_FROOTC', 'FATES_CROOTC', 
'FATES_CWD_ABOVEGROUND_DC', 'FATES_CWD_BELOWGROUND_DC' 
hist_fincl4=                                                                                                    
'SOILN_vr'
EOF


cp /cluster/work/projects/nn9560k/inputdata/WIEMIP/wiemip_BGC_datm.streams user_nl_datm_streams

./case.setup
./case.build
./case.submit
