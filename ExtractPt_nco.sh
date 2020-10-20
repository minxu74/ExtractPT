#!/usr/bin/env bash

module load nco
module load cdo


# ncvarlst $fl_nm : What variables are in file?
function ncvarlst { ncks --trd -m ${1} | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort ; }


DayMetDir=/gpfs/alpine/csc395/world-shared/5v1/Daymet_ESM_PR/

Vars=(Precip3Hrly Solar3Hrly TPHWL3Hrly)



#Latitude: 18.326200000000 
#Longitude: -65.816000000000
PtLat=18.326200000000
PtLon=-65.816000000000


for var in "${Vars[@]}"; do
    dirvar=$DayMetDir/$var
    echo $dirvar

    mkdir -p $var
    for file in $dirvar/*.nc; do
        echo $file 
        [[ $file =~ [^0-9]+([0-9]+)-([0-9]+).nc$ ]]
        cy=${BASH_REMATCH[1]}
        cm=${BASH_REMATCH[2]}
        echo ${BASH_REMATCH[0]}, ${BASH_REMATCH[1]}, ${BASH_REMATCH[2]}

        #ncks -d lat,$PtLat -d lon,$PtLon $file -o test.nc
        #cdo -outputtab,date,lon,lat,value -remapnn,"lon=9.0_lat=54.0" infile.nc
        /bin/cp -f $file daymet.nc
        if [[ $var == Precip3Hrly ]]; then
           varname=(PRECTmms)
        fi
        if [[ $var == Solar3Hrly ]]; then
           varname=(FSDS)
        fi
        if [[ $var == TPHWL3Hrly ]]; then
           varname=(TBOT QBOT PSRF FLDS WIND) 
        fi

        for v in "${varname[@]}"; do
            ncatted -a coordinates,$v,c,c,"time lat lon" daymet.nc
        done 
        cdo remapnn,lon=${PtLon}_lat=${PtLat} daymet.nc $var/${cy}-${cm}.nc
        /bin/rm -f daymet.nc
    done
done
