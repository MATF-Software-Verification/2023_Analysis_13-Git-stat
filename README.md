# 2023_Analysis_13-Git-stat

## Autor

**Ime i prezime:** Nikolina Lazarević  


## Analizirani Projekat

**Naziv:** `GitStat`  
**Opis:** Desktop GUI aplikacija za Git koja omogućava rad sa više repozitorijuma istovremeno.  
**Izvorni kod:** [GitStat – GitLab repo](https://gitlab.com/matf-bg-ac-rs/course-rs/projects-2021-2022/13-Git-stat)  
**Analizirana grana:** `main`  
**Commit hash:** `f20ddedfb456496b8bf7485b7ab9dd17be18d044`  

## Korišćeni alati za analizu

| Alat | Namena |
|------|--------|
| **Clang-Tidy** | Statička analiza i automatska korekcija stilskih i performansnih problema |
| **Cppcheck** | Statička analiza za detekciju potencijalnih grešaka i stilskih nepravilnosti |
| **Valgrind Memcheck** | Dinamička analiza memorije — otkrivanje curenja i neinicijalizovanih promenljivih |
| **Valgrind Callgrind** | Profilisanje performansi i analiza potrošnje procesorskog vremena |
| **Doxygen** | Generisanje tehničke dokumentacije iz komentara u kodu |
| **CBMC** | Formalna verifikacija i simbolička analiza C/C++ koda |


## Reprodukcija Rezultata

### Preduslovi

Za pokretanje svih analiza neophodno je instalirati sledeće komponente:

- `CMake >= 3.16`
- `Qt6`
- `Clang-Tidy`
- `Valgrind` (sa alatima **Memcheck** i **Callgrind**)
- `Doxygen`
- `Cppcheck` (verzija 2.12 ili novija)
- `Python3` i biblioteka `Pygments` (za HTML izveštaj Cppcheck-a)

### Pokretanje Analiza

**Inicijalizacija git submodule-a:**
```bash
git submodule update --init --recursive
```

**Clang-Tidy analiza:**
```bash
cd 2023_Analysis_13-Git-stat/clang-tidy
./run_clang_tidy.sh
```

**Valgrind Memcheck analiza:**
```bash
cd 2023_Analysis_13-Git-stat/valgrind-memcheck
./run_memcheck.sh
```

**Valgrind Callgrind analiza:**
```bash
cd 2023_Analysis_13-Git-stat/valgrind-callgrind
./run_callgrind.sh
```

**Doxygen dokumentacija:**
```bash
cd 2023_Analysis_13-Git-stat/doxygen
doxygen Doxyfile
```

**Cppcheck statička analiza**
```bash
cd 2023_Analysis_13-Git-stat/cppcheck
./run_cppcheck.sh
```

**CBMC formalna analiza:**
```bash
cd 2023_Analysis_13-Git-stat/cbmc
./run_cbmc.sh
```

Detaljni rezultati i interpretacija se nalaze u odgovarajućim README fajlovima u svakom direktorijumu, kao i u ProjectAnalysisReport fajlu.

## Zaključci

### 🔹 Kvalitet koda
**Clang-Tidy** analiza je identifikovala oblasti za modernizaciju i poboljšanje čitljivosti koda.  
Automatske ispravke, poput uklanjanja nepotrebnih kopiranja objekata i dodavanja `const` kvalifikatora, uspešno su primenjene bez uticaja na funkcionalnost.  
Ove izmene su doprinele većem kvalitetu, čitljivosti i održivosti koda.

### 🔹 Statička analiza — Cppcheck
**Cppcheck** analiza nije otkrila ozbiljne greške u logici programa niti probleme sa upravljanjem memorijom.  
Detektovani su uglavnom manji stilski i strukturni nedostaci:

- razlike u redosledu inicijalizacije članova klasa,  
- nekonzistentni nazivi argumenata između deklaracija i definicija,  
- redundantne inicijalizacije i neiskorišćene promenljive,  
- preporuke za upotrebu prefiks operatora (`++it`) i STL algoritama (`std::find_if`, `std::any_of`) umesto ručnih petlji.  

Ovi rezultati ukazuju da je kod stabilan i konzistentan, uz mogućnost daljeg estetskog i performansnog poboljšanja kroz manje stilske izmene.

### 🔹 Upravljanje memorijom
**Valgrind Memcheck** je identifikovao kritičnu grešku tipa *Invalid read* u okviru Qt widget hijerarhije.  
Greška je uspešno rešena implementacijom pravilnog *parent-child* modela, čime je eliminisano *use-after-free* ponašanje.  
Većina preostalih upozorenja odnosi se na Qt biblioteke i ne predstavlja stvarne greške u korisničkom kodu.


### 🔹 Performanse
**Valgrind Callgrind** profilisanje pokazalo je da najveći deo procesorskog vremena zauzimaju Qt event petlje (`QApplication::exec()`, `QEventLoop::exec()`), što je tipično za GUI aplikacije.  
Korisničke funkcije, poput `NetworkResponseParser::parseResponse()`, pokazuju dobru efikasnost bez značajnih performansnih uskih grla.  
Analiza omogućava precizno usmeravanje budućih optimizacija na najrelevantnije delove aplikacije.


### 🔹 Dokumentacija
**Doxygen** analiza je pokazala da originalni kod nije sadržao dovoljno komentara za automatsko generisanje dokumentacije.  
Dodavanjem Doxygen komentara za ključne klase (`Repo`, `Author`, `Commit`) demonstriran je potencijal alata za generisanje strukturisane dokumentacije.  
Ovo značajno olakšava održavanje i budući razvoj projekta.

### 🔹 Formalna verifikacija
**CBMC (C Bounded Model Checker)** je korišćen za formalnu proveru funkcije commitFromQJsonToClass, koja konvertuje JSON objekte u Commit strukture.
Pošto CBMC nije kompatibilan sa Qt bibliotekama (QString, QJsonObject, QDateTime, itd.), izrađene su mock implementacije ovih tipova, čime je omogućeno simboličko izvršavanje funkcije.

Analiza je otkrila potencijalne probleme:

* dereferenciranje null vrednosti

* pristup neinicijalizovanim podacima u QString objektima

* mogućnost da neka JSON polja (id, author.email, title) budu null

### Opšti zaključak
Projekat **GitStat** predstavlja stabilnu i funkcionalno ispravnu aplikaciju sa dobro osmišljenom arhitekturom.  
Rezultati kombinovane statičke i dinamičke analize pokazuju da:

- **nema ozbiljnih grešaka** ni curenja memorije,  
- **performanse** su u skladu sa očekivanjima za Qt GUI aplikacije,  
- **formalna verifikacija** je otkrila granične slučajeve sa neinicijalizovanim podacima,
- **stil koda i dokumentacija** mogu se dodatno unaprediti.  