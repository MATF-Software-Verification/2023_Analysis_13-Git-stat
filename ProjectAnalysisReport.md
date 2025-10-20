# 2023_Analysis_13-Git-stat

GitStat projekat predstavlja GUI aplikaciju za Git koja omogućava rad sa više repozitorijuma istovremeno i pruža osnovne vizualizacije nad Git repozitorijumima. Aplikacija omogućava korisnicima da na svojoj radnoj površini vide više Git repozitorijuma sa osnovnim informacijama o svakom, pregled commitova po autoru, praćenje izmena fajlova i broj izmenjenih linija. Dodatno, aplikacija podržava čuvanje rezultata obrade za ponovnu upotrebu, dodavanje komentara za projekte, autore i commitove, kao i preuzimanje privatnih repozitorijuma uz pristupni token.

Cilj ove analize je procena pouzdanosti, efikasnosti i kvalitet softvera. Izvršena je analiza projekta primenom alata:

• **Clang-Tidy**: alat za statičku analizu C++ koda koji objedinjuje stilske provere, modernizaciju koda, detekciju bagova i optimizacije performansi. Može automatski predložiti ispravke za mnoge probleme.

• **Valgrind Memcheck**: alat za dinamičku analizu memorije koji detektuje curenja memorije, pristup memoriji van granica, korišćenje neinicijalizovane memorije, use-after-free greške i druge probleme sa upravljanjem memorijom.

• **Valgrind Callgrind**: profiling alat koji analizira performanse programa merenjem broja izvršenih instrukcija po funkciji i omogućava identifikovanje "hot spots" - mesta gde program troši najviše vremena.

• **Doxygen**: alat za automatsko generisanje dokumentacije iz komentara u izvornom kodu koji podržava različite programske jezike uključujući C++. Kreira HTML, PDF i druge formate dokumentacije na osnovu specijalnih komentara u kodu.

## Clang-Tidy

**Clang-Tidy**: alat za statičku analizu C++ koda koji je deo LLVM projekta. Objedinjuje stilske provere, modernizaciju koda, detekciju bagova i optimizacije performansi. Za razliku od običnih kompajlera koji proveravaju samo sintaksu, Clang-Tidy vrši analizu koda i otkriva potencijalne probleme u dizajnu, performansama i održivosti. Alat može automatski predložiti i primeniti ispravke za mnoge probleme, što značajno ubrzava proces refaktorisanja i poboljšanja kvaliteta koda. Podržava različite kategorije provera uključujući `modernize-*` (preporuke za moderne C++ idiome), `readability-*` (poboljšanje čitljivosti), `clang-analyzer-*` (duboka statička analiza) i `performance-*` (optimizacije performansi). Integriše se lako u razvojna okruženja i CI/CD procese.

Pokrenula sam skriptu bez opcije fix kako bih proverila koje greške clang-tidy nalazi. 

![](./clang-tidy/Screenshot%20from%202025-10-17%2003-07-57.png)

Neki od primera pronađenih upozorenja:

![](./clang-tidy/Screenshot%20from%202025-10-17%2003-03-46.png)

![](./clang-tidy/Screenshot%20from%202025-10-17%2003-13-28.png)


Nakon provere, skripta je pokrenuta sa fix=true da bi se automatski primenile ispravke koje clang-tidy predlaže.

![](./clang-tidy/Screenshot%20from%202025-10-17%2003-06-42.png)

Neke od promena koje su izvrsene:

![](./clang-tidy/Screenshot%20from%202025-10-17%2003-27-01.png)

![](./clang-tidy/Screenshot%20from%202025-10-17%2003-30-08.png)

Time su greške poput gore navedenih automatski ispravljene u kodu.

## Valgrind Memcheck

Valgrind je alat koji se koristi za detekciju i dijagnostiku problema u programima napisanima na jezicima poput C i C++, a najpoznatija komponenta je Memcheck, koja služi za otkrivanje grešaka u radu sa memorijom. Kada pokrenemo program kroz Valgrind, alat simulira procesor i izvršavanje instrukcija, prateći svaki pristup memoriji i proveravajući da li se koristi ispravno. Ovo je posebno korisno jer su takve greške često teško uočljive, a mogu dovesti do nestabilnog ponašanja programa ili njegovog pada. Memcheck takođe prikazuje tačnu lokaciju u kodu gde je do problema došlo, što značajno olakšava proces debagovanja i popravljanja grešaka. Koristi se uglavnom tokom razvoja i testiranja, pre nego što se program pusti u produkciju.

Prilikom analize GitStat aplikacije, Memcheck sam pokrenula sa opcijama `--leak-check=full` za detaljno prikazivanje memory leak-ova, `--show-leak-kinds=all` za sve tipove curenja memorije, `--track-origins=yes` za praćenje porekla neinicijalizovanih vrednosti i `--suppressions=qt.supp` za ignorisanje false positives iz Qt biblioteka. Početni izlaz je upisan u `memcheck_full.log` fajl koji je imao više stotina hiljada linija zbog velikog broja grešaka iz Qt biblioteka.

S obzirom da Qt aplikacije alociraju resurse koje operativni sistem automatski oslobađa pri izlasku iz programa, većina prijavljenih problema iz biblioteka poput `libQt6Core.so`, `libQt6Gui.so`, `libwayland-client.so` i `libglib-2.0.so` predstavlja false positive rezultate, a ne prave memory leak-ove. Nakon filtriranja ovih grešaka pomoću suppression fajla, dobijen je značajno čitljiviji izveštaj fokusiran na korisnički kod.

Jedna od identifikovanih grešaka bila je "Invalid read of size 8" u funkciji `RepoNode::getRepo()` koja je nastala zbog nepravilnog upravljanja memorijom Qt widget-a.

![Invalid read](./memcheck/invalid_read.png)

Problem sam rešila prosleđivanjem parent widget-a prilikom kreiranja `RepoNode` objekta (`new RepoNode(ui->glRepos->parentWidget())`), čime je omogućeno Qt-u da automatski upravlja memorijom child widget-a i eliminiše ručno brisanje objekata koji su još uvek u upotrebi.

![Fix for invalid read](./memcheck/fix_repo_node.png)

Leak Summary sekcija u Valgrind izveštaju prikazuje statistiku o curenju memorije kategorizovanu po tipovima: `definitely lost` označava memoriju koja je sigurno izgubljena i predstavlja pravi memory leak koji mora biti ispravljen, `indirectly lost` se odnosi na memoriju dostupnu samo preko pokazivača u `definitely lost` blokovima, `possibly lost` ukazuje na memoriju koja možda curi ali može biti i legitimno korišćena, dok `still reachable` predstavlja memoriju koja nije oslobođena ali je još uvek dostupna kroz globalne pokazivače pri izlasku iz programa.
U slučaju GitStat aplikacije, nakon primene Qt suppression fajla, većina preostalih `still reachable` blokova potiče iz Qt framework-a i predstavlja normalno ponašanje, dok su `definitely lost` blokovi u korisničkom kodu uspešno smanjeni.

![Leak Summary](./memcheck/leak_summary.png)

## Valgrind Callgrind

Callgrind je profiling alat koji predstavlja deo Valgrind platforme, specijalizovan za detaljnu analizu performansi programa napisanih u C i C++. Za razliku od običnih profiler-a koji mere vreme izvršavanja, Callgrind simulira procesor i broji instrukcije, što čini rezultate nezavisnim od brzine procesora i trenutnog opterećenja sistema. Alat prikuplja podatke o broju poziva funkcija, broju izvršenih instrukcija po funkciji, hijerarhiji poziva i međusobnim vezama između različitih delova koda.

Callgrind generiše detaljne izveštaje koji se čuvaju u fajlovima sa ekstenzijom `.out` i mogu se vizualizovati pomoću grafičkih alata poput KCachegrind-a ili QCachegrind-a. Ovi alati omogućavaju interaktivno istraživanje rezultata kroz dijagrame, tabele i grafove poziva, što značajno olakšava identifikaciju delova koda koji troše najviše resursa i predstavljaju najbolje kandidate za optimizaciju.

### Analiza pokretanja alata

Rezultat sam preusmerila u fajl `callgrind.out`. Za analizu tih rezultata koristila sam grafički alat KCachegrind, koji omogućava pregled podataka kroz interaktivan i vizuelan prikaz. Na taj način je lakše uočiti koje funkcije troše najviše resursa i gde postoje mogućnosti za optimizaciju performansi. Kombinacija Callgrind-a i KCachegrind-a pruža detaljan uvid u izvršavanje programa.

Najviše nas zanimaju mesta koja troše najviše vremena, ili koja se najčešće pozivaju. Pomocu opcije All Callees i Callee Map, koje prikazuju sve funkcije koje su direktno ili indirektno, pozvane iz `main()` funkcije, zajedno sa njihovim procentualnim udelom u ukupnom vremenu izvršavanja dobijamo sledeci prikaz:

![Callees for main](./callgrind/calees_for_main.png)

Na osnovu Callee Map prikaza može se uočiti da je najveći deo procesorskog vremena potrošen u funkcijama koje pripadaju Qt biblioteci (npr. QApplication::exec(), QCoreApplication::exec(), QEventLoop::exec()).
To je očekivano, jer se radi o GUI aplikaciji (GitStat) čiji glavni tok izvršavanja zavisi od Qt-ovog događajnog petlji (event loop-a).

U All Callees tabeli vidi se da funkcije QApplication::exec(), QGuiApplication::exec() i QCoreApplication::exec() imaju najveći Inclusive cost (oko 48% ukupnih instrukcija), dok korisnički definisane funkcije kao što su NetworkResponseParser::parseResponse() zauzima manji, ali značajan deo vremena. To ukazuje da najveći deo troškova dolazi od GUI event sistema i obrade mrežnih odgovora.

Takodje mozemo pogledati i graf poziva biranjem opcije CallGraph. Graf poziva za ovo izvrsavanje je sledeci:

![Graph](./callgrind/graph.png)

## Doxygen

Doxygen je alat za automatsko generisanje dokumentacije koji parsira izvorni kod i kreira detaljnu dokumentaciju na osnovu komentara napisanih u specijalnom formatu. Alat podržava različite programske jezike uključujući C, C++, Java, Python i druge, a generiše izlaz u HTML, PDF, RTF i XML formatima. Doxygen je posebno koristan za velike projekte jer automatski kreira hijerarhiju klasa, grafik nasleđivanja, grafove poziva i cross-reference linkove između različitih delova koda.

Za GitStat projekat, Doxygen je konfigurisan kroz Doxyfile koji specificira ulazne direktorijume, izlazni format i različite opcije za generisanje dokumentacije, ovaj fajl je generisan uz pomoć Doxygen GUI alata. S obzirom da originalni kod nije sadržavao Doxygen komentare, ručno su dodati komentari za neke od klasa kako bi se demonstrirala funkcionalnost alata. Dodati su komentari za klase poput `Repo`, `Author` i `Commit`.

Primer dodanih komentara:

```cpp
/**
 * @brief Klasa koja predstavlja Git repozitorijum
 * @details Sadrži osnovne informacije o repozitorijumu uključujući naziv, 
 *          putanju, autore i commit-ove. Omogućava upravljanje komentarima
 *          i statistikama repozitorijuma.
 */
class Repo {
```

Nakon dodavanja komentara, alat se pokreće preko skripte `run_doxygen.sh` koja automatski generiše HTML dokumentaciju. Skripta koristi postojeći `Doxyfile` konfiguraciju i parsira sve header i source fajlove u `src/` i `include/` direktorijumima, kreirajući kompletnu dokumentaciju koja uključuje pregled svih klasa, funkcija, promenljivih i njihovih međusobnih veza. Generisana dokumentacija omogućava laku navigaciju kroz kod, razumevanje arhitekture aplikacije i olakšava onboarding novih kolega na projekat. Dokumentacija se nalazi na putanji file:///home/nikolina.lazarevic/Documents/2023_Analysis_13-Git-stat/13-Git-stat/html/annotated.html

Prikaz klasa koje nasledjuju klasu `QObject`:

![Hijerarhija klasa 1](./doxygen/hijerarhija_klasa.png)

Prikaz klasa koje nasledjuju klasu `QDialog`:

![Hijerarhija klasa 2](./doxygen/hijerarhija_klasa_2.png)

Graf poziva za funkciju `getEmail()`:

![Graf poziva getEmail](./doxygen/graf_poziva.png)

Primer dokumentacije klase `Commit`:

![Prikaz dokumentacije](./doxygen/dokumentacija.png)

## Zaključci Analize

Na osnovu analize GitStat projekta primenom četiri različita alata za statičku i dinamičku analizu koda, mogu se izvesti sledeći zaključci:

### Kvalitet Koda i Održivost

**Clang-Tidy** analiza je pokazala da projekat sadrži moderne C++ idiome, ali ima prostora za poboljšanje u pogledu čitljivosti i performansi. Automatske ispravke su uspešno primenjene za probleme poput nepotrebnih kopiranja objekata i nekonzistentnog korišćenja `const` kvalifikatora. Ove izmene su doprinele boljem kvalitetu koda bez uticaja na funkcionalnost.

### Upravljanje Memorijom

**Valgrind Memcheck** analiza je identifikovala kritičnu grešku "Invalid read of size 8" u funkciji `RepoNode::getRepo()` koja je nastala zbog nepravilnog upravljanja Qt widget hijerarhijom. Rešavanje ovog problema kroz prosleđivanje parent widget-a je eliminisalo use-after-free grešku i poboljšalo stabilnost aplikacije. Većina ostalih prijavljenih problema predstavljala je false positive rezultate iz Qt biblioteka, što je očekivano za GUI aplikacije.

### Performanse

**Valgrind Callgrind** profiling je pokazao da najveći deo procesorskog vremena troše Qt framework funkcije (`QApplication::exec()`, `QEventLoop::exec()`), što je normalno za event-driven GUI aplikacije. Korisnički kod, posebno `NetworkResponseParser::parseResponse()`, zauzima manji ali značajan deo vremena, što ukazuje na efikasnu implementaciju osnovnih funkcionalnosti bez očiglednih performansnih uskih grla.

### Dokumentacija

**Doxygen** analiza je pokazala da originalni kod nije sadržavao strukturovane komentare za automatsko generisanje dokumentacije. Ručno dodavanje Doxygen komentara za ključne klase (`Repo`, `Author`, `Commit`) je demonstriralo potencijal alata za kreiranje profesionalne dokumentacije koja bi olakšala održavanje i proširivanje projekta.

### Opšti Zaključak

GitStat projekat predstavlja stabilnu i funkcionalno ispravnu aplikaciju sa solidnom arhitekturom. Identifikovani problemi su uglavnom kozmetičke prirode ili se odnose na optimizacije koje ne utiču na osnovnu funkcionalnost. Rezultati Valgrind Memcheck analize pokazuju da u GitStat aplikaciji nema značajnih curenja memorije. Količina definitely lost i indirectly lost memorije je veoma mala (ukupno oko 20 KB), što ukazuje na to da su stvarna curenja u korisničkom kodu uspešno otklonjena. Većina preostale memorije označene kao still reachable potiče iz Qt framework-a i predstavlja očekivano ponašanje, a ne stvarne greške u upravljanju memorijom. Korišćenje alata doxygen ukazalo na manjak komentara u kodu.
