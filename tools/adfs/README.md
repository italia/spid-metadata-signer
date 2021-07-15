# Creazione di metadati SPID per SP basati su ADFS (Active Directory Federation Services)

Active Directory Federation Services è un sistema di Web SSO che permette di realizzare l'adesione a SPID funzionando come *nodo cluster*, secondo la definizione dell'avviso n.6 delle norme tecniche SPID.

Perché possa interfacciarsi correttamente con SPID è necessario un componente software custom che faccia da tramite tra gli IDP SPID e il nodo cluster.

Lo script si occupa di scaricare e modificare automaticamente i metadati generati da un sistema ADFS, convertendoli nel formato richiesto dalle norme tecniche SPID e successivi avvisi.

## Utilizzo

Eseguire lo script dalla radice del progetto, specificando l'URL dove raggiungere ADFS:
```
bash tools/adfs/adfs2spid-sp.sh -u adfs.contoso.com
```

## Prerequisiti

Nel sistema dove si esegue lo script è necessaria la presenza dei comandi `curl`, `openssl` e `xmllint`.

## Operazioni effettuate

- download dei metadati di ADFS e posizionamento nella directory per la firma con `spid-metadata-signer.sh`
- cancellazione degli elementi non previsti dalle norme tecniche
- inserimento di valori obbligatori
- inserimento degli *AttributeConsumingService* da dichiare per definire le classi di servizio
- sostituzione del certificato di signing di ADFS con quello usato per la firma dei metadati
- validazione e formattazione del file XML risultante

## Configurazione

Il contenuto degli *AttributeConsumingService* è definito nel file ```classi-di-servizio.xml```. Deve contenere le classi di attributi previste dagli IDP SPID.


## Riferimenti

La modellazione dei metadati è basata sulle specifiche riportate nelle comunicazioni di Agid:

* http://www.agid.gov.it/sites/default/files/circolari/spid-regole_tecniche_v1.pdf
* http://www.agid.gov.it/sites/default/files/documentazione/spid-avviso-n6-note-sul-dispiegamento-di-spid-presso-i-gestori-di-servizi-v1.pdf
* http://www.agid.gov.it/sites/default/files/regole_tecniche/spid_tabella_messaggi_di_anomalia_v1.0.pdf
* http://www.agid.gov.it/sites/default/files/regole_tecniche/tabella_attributi_idp_v1_0.pdf

e dalle risposte del servizio di HelpDesk per quanto non previsto nelle comunicazioni ufficiali.