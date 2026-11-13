# Laadunvarmistus ja hyväksymiskäytännöt

## Projektin Informaatiostandardit

Projektissa noudatetaan seuraavia standardeja ja ohjeita:

- *ISO 19650*-standardisarja (osat 1-5): Tiedonhallinnan perusperiaatteet
- *IFC 4 (ISO 16739): Tiedonsiirron avoin standardi
- Yleiset Informaatiomallivaatimukset (*YTV 2012*/päivitykset): Kansalliset vaatimukset
- BuildingSMART International -standardit: *IDS*, *bSDD*
- BuildingSMART Finland, RYTV informaatiovaatimukset

## Informaatiotuotantomenetelmät ja -käytännöt (esim. CDE)

Projektissa käytetään yhteistä informaatioympäristöä (CDE) tiedon hallintaan. Valittu CDE-alusta on [CDE-alustan nimi], jota käytetään kaikkeen projektin tiedonvaihtoon.
CDE-ympäristön rakenne noudattaa ISO 19650-2 -standardin mukaista jaottelua:

- *WIP* (Work In Progress): Keskeneräiset työversiot
- *SHARED*: Tarkastukseen jaetut versiot
- *PUBLISHED*: Hyväksytyt ja julkaistut versiot
- *ARCHIVED*: Arkistoidut versiot

Informaatiomallien julkaiseminen ja jakaminen tapahtuu aina CDE:n kautta määritellyn prosessin mukaisesti.

## Hyväksymisprosessi ja hyväksymistaulukko
Informaatiomallien laadunvarmistus ja hyväksyminen tapahtuvat seuraavan prosessin mukaisesti:

1. Suunnittelija tarkistaa mallin sisäisesti (itselle luovutus)
2. Malli jaetaan "SHARED"-tilaan CDE:ssä tarkastettavaksi
3. Informaatiomallikoordinaattori tekee teknisen tarkastuksen
4. Pääsuunnittelija tekee sisällöllisen tarkastuksen
5. Tilaaja hyväksyy mallin, jolloin se siirretään "PUBLISHED"-tilaan

|*Tarkastuskohde*|*Tarkastaja*|*Tarkastustapa*|Hyväksymiskriteerit|
|----------------|------------|---------------|-------------------|
Tekninen laatu|Tietomallikoordinaattori|Solibri Model Checker|Ei törmäyksiä, nimeäminen standardin mukainen|
Informaatiosisältö|Pääsuunnittelija|Informaatiosisällön tarkistuslista|Vaaditut tiedot löytyvät, riittävä tarkkuus|
Toiminnallisuus|Tilaaja|Käyttötapausten testaus|Malli vastaa toiminnallisia vaatimuksia|
