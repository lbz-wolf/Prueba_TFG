#!/bin/bash

# Define variables
LSB=/usr/bin/lsb_release
DIRECCION_ABSOLUTA=$(pwd)
DIRECCION_CERT_TOOLS="$DIRECCION_ABSOLUTA/cert-tools"
DIRECCION_CERT_ISSUER="$DIRECCION_ABSOLUTA/cert-issuer"

#Mantener menu en pausa
function pausa(){
	local mensaje="$@"
	[ -z $mensaje ] && mensaje="Presiona Enter para continuar..."
	read -p "$mensaje" readEnterKey
}

# Mostrar menu
function menu(){
    date
    echo "----------------------------------------------------"
    echo "  SISTEMA DE CREACION Y EMISION DE CERTIFICADOS  "
    echo "----------------------------------------------------"
	echo "1. Crear plantilla"
	echo "2. Crear certificado"
	echo "3. Mover certificado para envío"
	echo "4. Emitir certificado a blockchain"
	echo "5. Salir"
}

# Mensaje de cabecera
function cabecera(){
	local h="$@"
	echo "---------------------------------------------------------------"
	echo "     ${h}"
	echo "---------------------------------------------------------------"
}

# crea plantilla del certificado con el contenido del arvhivo configuracion
function crear_plantilla(){
	cabecera " Crear plantilla "
  local direccion_conf
	echo "Nombre del archivo de configuracion "
  read direccion_conf
	cd cert-tools
  create-certificate-template -c $direccion_conf
	cd ..
	pausa
}

# crear certificado con el contenido del archivo configuracion
function crear_certificado(){
	cabecera " Crear certificado "
  local direccion_conf
	echo "Nombre del archivo de configuracion "
  read direccion_conf
	cd cert-tools
  instantiate-certificate-batch -c $direccion_conf
	cd ..
	pausa
}

# mover certificados a la herramienta de issuer para enviarlos
function mover_certificado(){
	cabecera " Preparando certificado para envío "
	local direccion_cert_tools
	local direccion_cert_issuer
	direccion_cert_tools="$DIRECCION_CERT_TOOLS/sample_data/unsigned_certificates/*"
	direccion_cert_issuer="$DIRECCION_CERT_ISSUER/data/unsigned_certificates"
  mv $direccion_cert_tools $direccion_cert_issuer
	if [ $? -ne 0 ]; then
		echo "La carpeta está vacia"
	else
		echo "Archivos movidos de $direccion_cert_tools a $direccion_cert_issuer"
	fi
	pausa
}

# Emitir el certificado a la blockchain
function emitir_certificado_blockchain(){
	cabecera " Emisión de certificado a la blockchain "
  local direccion_conf
	echo "Nombre del archivo de configuracion "
  read direccion_conf
	cd cert-issuer
	cert-issuer -c $direccion_conf
	cd ..
	local c
	echo "¿Desea eliminar certificados antiguos? S/n "
	read c
	local cadena1="s"
	local cadena2="S"
	if [ $c = $cadena1 ] || [ $c = $cadena2 ]; then
		cd "$DIRECCION_CERT_ISSUER/data/unsigned_certificates/"
		rm *
		echo "¡Certificados eliminados!"
	fi
	cd "$DIRECCION_ABSOLUTA"
	pausa
}

# Elección de 1 a 5 del menu con sus respectivas funciones
function eleccion_menu(){
	local c
	read -p "Elige opción [ 1 - 5 ] " c
	case $c in
		1)	crear_plantilla ;;
    2)  crear_certificado ;;
    3)  mover_certificado ;;
		4)	emitir_certificado_blockchain ;;
		5)	echo "Adios"; exit 0 ;;
		*)
			echo "Elige entre 1 o 5 del menú."
			pause
	esac
}

# Ignora CTRL+C, CTRL+Z
trap '' SIGINT SIGQUIT SIGTSTP

while true
do
	clear
 	menu
 	eleccion_menu
done
