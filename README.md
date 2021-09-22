# SPID Metadata Signer

Lo script permette di firmare un metadata SAML utilizzando [XmlSecTool](http://shibboleth.net/downloads/tools/xmlsectool/latest/xmlsectool-2.0.0-bin.zip).

## Requisiti
Per utilizzare lo script è necessario avere:

* [XmlSecTool](http://shibboleth.net/downloads/tools/xmlsectool/latest/xmlsectool-2.0.0-bin.zip) (scaricato e verificato automaticamente dallo script)
* Java Development Kit
* Unzip
* curl
* Metadata compliant alle [Regole Tecniche SPID](http://spid-regole-tecniche.readthedocs.io/en/latest/)
* Chiave e certificato di firma (va bene anche quello utilizzato per la firma delle asserzioni saml)

Per creare una chiave (con password) e un certificato:
```
openssl req -x509 -sha256 -days 365 -newkey rsa:2048 -keyout nome-chiave.key -out nome-certificato.crt
```

Nota bene: un certificato generato con questo comando avrà durata di 1 anno

Per rimuovere la password alla chiave:
```
openssl rsa -in your.encrypted.key -out your.key
```

Per aggiungere la password alla chiave:
```
openssl rsa -des3 -in your.key -out your.encrypted.key
```

__Nota__: lo script effettua un controllo dei requisiti software e parametri

## Utilizzo

### Procedura di firma attraverso script

* Scaricare e scompattare la release o clonare il repository
* Inserire la chiave e il certificato nella cartella "certs" (vanno bene anche quelli utilizzati per la firma delle asserzioni SAML)
* Inserire il metadata non firmato nella cartella "metadata/metadata-in"
* Eseguire lo script:

```
./spidMetadataSigner.sh
```

I parametri seguenti possono essere inseriti in un file da cui leggere i valori predefiniti ad ogni esecuzione, un esempio è riportato in ```config.sample```.
Il file di impostazioni deve essere chiamato ```.config```, nella directory principale del progetto.


Verranno richiesti i seguenti parametri:

* nome del metadata da firmare (con estensione - es: FederationMetadata.xml)
* nome della chiave (con estensione - es: firmaspidkey)
* password della chiave, se presente, altrimenti lasciare vuota
* nome del certificato (con estensione - es: firmaspid.crt)
* JAVA_HOME (se non presente) lo script suggerirà il path

Alla fine della procedura il metadata firmato sarà caricato nella cartella "metadata/metadata-out"

### Procedura di firma manuale

Lo script automatizza e semplifica il comando di firma metadata tramite XmlSecTool:

Scaricare XmlSecTool:
* [Pacchetto precompilato](http://shibboleth.net/downloads/tools/xmlsectool/latest/xmlsectool-2.0.0-bin.zip)
* via Homebrew (OS X): ```brew install xmlsectool```

Impostare JAVA_HOME
```
export JAVA_HOME=/path/java/home

Per conoscere il path per JAVA_HOME (Java deve essere installato sul sistema):
Linux: echo $(dirname $(dirname $(readlink -f $(which javac))))
MacOS: echo $(/usr/libexec/java_home)
```

Eseguire XmlSecTool
```
xmlsectool.sh --sign --referenceIdAttributeName ID --inFile "metadata-non-firmato.xml" --outFile "metadata-firmato.xml" --digest SHA-256 --signatureAlgorithm http://www.w3.org/2001/04/xmldsig-more#rsa-sha256 --key "certificato.key" --keyPassword "password" --certificate "certificato.crt
```

Specificare --keyPassword "password" solo se la chiave è con password


### Note

* lo script funziona su sistemi Linux e MacOS
* nelle cartelle "metadata-in" e "metadata-out" è presente un esempio di metadata non firmato (metadata-in) e di uno firmato (metadata-out)
* nella cartella "certs" è presente chiave (con e senza password) e certificato di prova, la password della chiave è "test".

Si raccomanda di utilizzare i file di esempio solo per test.
