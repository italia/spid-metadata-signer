#!/bin/bash

# Author: Cristian Mezzetti <cristian.mezzetti@unibo.it>

set -e

if [ $# -ne 2 ] || [ "$1" -ne "-u" ] ; then
    echo "Uso dello script: adfs2spid-sp.sh -u adfs.contoso.com"
    exit 1
fi

adfsUrl="$2"

if [ ! -x $(which curl) ]; then
    echo "Comando curl non trovato, impossibile proseguire"
    exit 1
fi

adfsMetadata="https://${adfsUrl}/FederationMetadata/2007-06/FederationMetadata.xml"
metadataFile="$(basename $adfsMetadata)"
metadataDir="metadata/metadata-in"
certificate="certs/spidproxy.crt"
classi=$(cat tools/adfs/classi-di-servizio.xml | tr -d '\n')

curl -OJ "$adfsMetadata"
mv $metadataFile $metadataDir/

# ADFS ha già i metadati firmati, vanno cancellate le firme apposta prima della nuova firma
sed -i 's/<ds:Signature.*<\/ds:Signature>//' "$metadataDir/$metadataFile"

# Eliminazione dei metadati superflui per il ruolo di SP
sed -i 's/<RoleDescriptor.*<\/RoleDescriptor>//' "$metadataDir/$metadataFile"
sed -i 's/<IDPSSODescriptor.*<\/IDPSSODescriptor>//' "$metadataDir/$metadataFile"

# Elementi non previsti dalle norme tecniche SPID
sed -i 's/<ContactPerson.*<\/ContactPerson>//' "$metadataDir/$metadataFile"
sed -i 's/<NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress<\/NameIDFormat>//' "$metadataDir/$metadataFile"
sed -i 's/<NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent<\/NameIDFormat>//' "$metadataDir/$metadataFile"

# AuthRequestsSigned="true" è richiesto dalle norme tecniche SPID
sed -i 's/<SPSSODescriptor /<SPSSODescriptor AuthnRequestsSigned="true" /' "$metadataDir/$metadataFile"

# Eliminato HTTP-Artifact non accettato del servizio tecnico Agid
sed -i 's/<AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact" Location="https:\/\/${adfsUrl}\/adfs\/ls\/" index="1"\/>//' "$metadataDir/$metadataFile"

# Tipi di LogoutService non previsti dalle norme tecniche SPID
sed -i 's/<SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https:\/\/${adfsUrl}\/adfs\/ls\/"\/>//' "$metadataDir/$metadataFile"
sed -i 's/<SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https:\/\/${adfsUrl}\/adfs\/ls\/"\/>/<SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP" Location="https:\/\/$adfsUrl\/adfs\/ls\/singleLogoutService"\/>/' "$metadataDir/$metadataFile"

# Sostituzione certificato originale con quello di signing ad hoc
tmp_cert=$(openssl x509 -in $certificate -text | tr -d ' ' | tr -d '\n')
signing_cert=$(echo $tmp_cert | sed -e 's/^.*BEGINCERTIFICATE-----//' | sed -e 's/-----ENDCERTIFICATE-----$//')
sed -i "s@\(.KeyDescriptor.use..signing.*.<X509Certificate>\).*\(<\/X509Certificate\)@\1$signing_cert\2@" "$metadataDir/$metadataFile"

# inserimento del contenuto degli AssertionConsumingService richiesti
cat "$metadataDir/$metadataFile" | sed -e "s@</SPSSODescriptor>@$classi</SPSSODescriptor>@" > tmp.xml

xmllint --format tmp.xml > "$metadataDir/$metadataFile" && rm tmp.xml
