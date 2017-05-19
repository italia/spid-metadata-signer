#!/bin/bash

set -e 

echo -e "\n"
echo "==============================================="
echo "      AgID Agenzia per l'Italia Digitale       "
echo "     Presidenza del Consiglio dei Ministri     "
echo "==============================================="
echo "  SPID Sistema Pubblico di Identità Digitale   "
echo "==============================================="
echo "           SPID Metadata Signer v1.0           "
echo "==============================================="
echo -e "\n"

# Nome del file metadata
while [ -z "$metadataFileName" ]
do
    read -p "> Digita il nome del metadata da firmare (senza estensione es: .xml): " metadataFileName
done
echo -e "\n"

# Nome della chiave
while [ -z "$keyName" ]
do
    read -p "> Digita il nome della chiave (con estensione es: .key): " keyName
done
echo -e "\n"

# Password della chiave (non specificare se non presente)
read -s -p "> Digita la password della chiave (se presente): " keyPass
if [ ! -z "$keyPass" ]; then
    commandPass="--keyPassword $keyPass"
fi
echo -e "\n"

# Nome del certificato
while [ -z "$crtName" ]
do
    read -p "> Digita il nome del certificato (con estensione es: .crt): " crtName
done
echo -e "\n"

# Controllo se JAVA è installato
if type -p java; then
    echo -e "Java installato sul sistema\n"
else
    echo -e "Java non installato sul sistema. Installarlo e riprovare!\n"
    exit 1
fi

# Controllo se Unzip è installato
if type -p unzip; then
    echo -e "Unzip installato sul sistema\n"
else
    echo -e "Unzip non installato sul sistema. Installarlo e riprovare!\n"
    exit 1
fi

# Controllo JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
    if [ "$(uname)" == "Darwin" ]; then
        javaHomeTip=$(/usr/libexec/java_home)
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        javaHomeTip=$(dirname $(dirname $(readlink -f $(which javac))))
    fi
    # Impostazione del JAVA_HOME
    while [ -z "$javaHome" ]
    do
        read -p "> Digita il JAVA_HOME (suggerimento: $javaHomeTip): " javaHome
    done
    export JAVA_HOME=$javaHome
fi
echo -e "\n"

# Download e installazione XmlSecTool 2.0.0
if [ ! -d "xmlsectool-2.0.0" ]; then
    echo "Scaricamento XmlSecTool 2.0.0:"
    curl -OJ https://shibboleth.net/downloads/tools/xmlsectool/latest/xmlsectool-2.0.0-bin.zip
    unzip -qq xmlsectool-2.0.0-bin.zip
    rm -f xmlsectool-2.0.0-bin.zip
    echo -e "\n"
fi

# Firma del metadata
echo "Firma del metadata: metadata/metadata-in/$metadataFileName.xml"
./xmlsectool-2.0.0/xmlsectool.sh --sign --referenceIdAttributeName ID --inFile "metadata/metadata-in/$metadataFileName.xml" --outFile "metadata/metadata-out/$metadataFileName-signed.xml" --digest SHA-256 --signatureAlgorithm http://www.w3.org/2001/04/xmldsig-more#rsa-sha256 --key "certs/$keyName" $commandPass --certificate "certs/$crtName"
echo -e "\n"
