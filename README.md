# SND Tentastatistik

Genererar PDF-dokument med tentastatistik automatiskt utifrån resultat lagrade i TSV filer med hjälp av LuaLaTeX.
Varje latex dokument definierar en tidsperiod att hämta resultat från, förslagsvis en [tentavecka](https://www.student.chalmers.se/sp/academic_year_list).

## Förberedelser
Du behöver Lualatex, svensk babel samt rekommenderade texlive-filer.
För att automatiskt generera resultat från Chalmers statistikfil,
krävs Python 3 och pythonpaketet xlrd.

I Ubuntu bör du installera följande paket (exempelvis genom "sudo apt-get install <paket>"):
texlive-full texlive-xetex python3-xlrd texlive-lang-european


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

1. Ladda ner senaste http://document.chalmers.se/download?docid=479628742 och placera i denna mapp.
2. Om det behövs, byt namn på kalkylarket till Statistik_över_kursresultat.xlsx.
3. Lägg till eventuella nya kurser i `kurskoder.tsv`. Scriptet genererar bara ner resultat för kurser definierade där.
4. Kör `python generate.py > resultat.tsv`
5. Kopiera `2012-13lp1.tex` till `<namn>.tex`och uppdatera:
    * \title — dokumentets titel
    * \tvstart — tentaveckans första dag
    * \tvstop — tenteveckans sista dag
6. Generera PDF-dokumentet:
    > lualatex --interaction=nonstopmode `tex-stats/<namn.tex>`
7. Flytta PDF-dokumentet till `pdf-stats`

Notera att resultat endast genereras för tentor som har fler än 15 deltagare.
Om något kursresultat saknas sök på kurskoden i det stora kalkylarket.
Finns det inte där så har inte något resultat rapporterats in.

### Om en tenta går utanför ordinarie tenperiod
1. Sök på kurskoden och notera tentamensdatumet.
2. Ändra i aktuell .tex-fil, exempelvis 2015-16p2.tex, så att datumet för tentan ligger inom intervallet.
3. Kör `python generate.py > resultat.tsv`
4. Sök rätt på kurskoden, till exempel ENM155.
5. Kopiera raden med statistik över tentaresultatet och spara på ett säkert ställe.
6. Ändra tillbaka till ordinarie tentamensdatum och upprepa steg 3.
7. Gå in i resultat.tsv och lägg till din sparade rad längst ned.
8. Generera PDF-dokumentet:
    > lualatex --interaction=nonstopmode `tex-stats/<namn.tex>`

