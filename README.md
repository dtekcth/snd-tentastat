# SND Tentastatistik

Genererar PDF-dokument med tentastatistik automatiskt utifrån resultat lagrade i TSV filer med hjälp av LuaLaTeX. Varje latex dokument definierar en tidsperiod att hämta resultat från, förslagsvis en tentavecka.

## Lagringsformat
Data lagras i TSV-filer (Tab Separated Value).
Observera att datum måste anges *exakt* enligt [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601): YYYY-MM-DD. 

#### resultat.tsv
Tentaresultaten i sig. Symbolen "→" används för att betona en tabulator.

* Syntax: `<datum>`→`<kurskod>`→`<antal underkända>`→`<antar 3:or>`→`<antal 4:or>`→`<antal 5:or>`
* Exempel: `2012-10-20`→`MVE055`→`8`→`19`→`35`→`26`

#### kurskoder.tsv
Associerar kurskoder med en årskurs (se `program.tsv`) och ett namn.

* Syntax: `<kurskod>`→`<årskurs>`→`<namn>`
* Exempel: `TDA555`→`1`→`Introduktion till funktionell programmering`

#### program.tsv
Associerar en årskurssymbol med dess fulla namn. I den genererade PDF:en kommer ordningen på årskurserna att följa denna fil

* Syntax: `<symbol>`→`<namn>`
* Exempel: `1`→`TKDAT-1`


## Skapa ett nytt dokument efter en tentaperiod
Ytterligare en tentavecka har passerat och det är din uppgift i studienämnden att publicera statistik över resultaten.

1. Lägg till resultat i `resultat.tsv`
2. Komplettera eventuella saknade kurskoder i `kurskoder.tsv`
3. Kopiera `2012-13lp1.tex` till `<namn>.tex`och uppdatera:
    * \title — dokumentets titel
    * \tvstart — tentaveckans första dag
    * \tvstop — tenteveckans sista dag
4. Generera PDF-dokumentet:
> lualatex --interaction=nonstopmode `<namn.tex>`
