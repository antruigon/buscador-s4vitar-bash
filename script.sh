#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n${redColour}[!]${endColour} Saliendo...\n"
  tput cnorm && exit 1
}


# Ctrl + C
trap ctrl_c INT

main_url=https://htbmachines.github.io/bundle.js

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso: ${endColour}\n"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Actualizar archivos necesarios${endColour}\n"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de máquina${endColour}\n"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por dirección ip${endColour}\n"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar el panel de ayuda${endColour}\n"
}


function update_files(){
  tput civis
  if [ ! -f bundle.js ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Archivos descargados correctamente${endColour}"

  else
    curl -s $main_url > bundle_tmp.js
    js-beautify bundle_tmp.js | sponge bundle_tmp.js
    
    bundlejs_md5=$(md5sum bundle.js | awk '{print $1}')
    bundletmpjs_md5=$(md5sum bundle_tmp.js | awk '{print $1}')
    
    if [ "$bundlejs_md5" == "$bundletmpjs_md5" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No hay actualizaciones disponibles, está todo al día${endColour}"
      rm bundle_tmp.js
    else
      rm bundle.js && mv bundle_tmp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Archivos actualizados correctamente${endColour}"
    fi

  fi
  tput cnorm
}


function searchMachine(){
  machineName="$1"
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando propiedades de la máquina ${endColour}${blueColour}$machineName${endColour}${grayColour}: ${endColour}"
  echo -e "\t${yellowColour}-${endColour}${grayColour} $(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d "," | sed 's/ *//' | grep "^name:")"
  echo -e "\t${yellowColour}-${endColour}${grayColour} $(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d "," | sed 's/ *//' | grep "^ip:")"
  echo -e "\t${yellowColour}-${endColour}${grayColour} $(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d "," | sed 's/ *//' | grep "^so:")"
  echo -e "\t${yellowColour}-${endColour}${grayColour} $(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d "," | sed 's/ *//' | grep "^dificultad:")"
  echo -e "\t${yellowColour}-${endColour}${grayColour} $(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d "," | sed 's/ *//' | grep "^skills:")"
  echo -e "\t${yellowColour}-${endColour}${grayColour} $(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d "," | sed 's/ *//' | grep "^youtube:")"
}


function searchIP(){
  ipAddress="$1"

  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour} La máquina correspondiente para la IP ${endColour}${blueColour}$ipAddress${endColour}${grayColour} es ${endColour}${purpleColour}$machineName${endColour}"

  searchMachine $machineName
}


#Indicadores
declare -i paremeter_counter=0

while getopts "m:ui:h" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress=$OPTARG; parameter_counter+=3;;
  esac
done

if [[ $parameter_counter -eq 1 ]]; then
  searchMachine $machineName
elif [[ $parameter_counter -eq 2 ]]; then
  update_files
elif [[ $parameter_counter -eq 3 ]]; then
  searchIP $ipAddress
else
  helpPanel
fi
