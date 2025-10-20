# 2023_Analysis_13-Git-stat

## Autor

**Ime i prezime**: Nikolina Lazarevic

## Analizirani Projekat

**Naziv**: GitStat  

**Opis**: Desktop GUI aplikacija za Git koja omogućava rad sa više repozitorijuma istovremeno  

**Izvorni kod**: [GitStat](https://gitlab.com/matf-bg-ac-rs/course-rs/projects-2021-2022/13-Git-stat)

**Analizirana grana**: `main`  

**Commit hash**: `f20ddedfb456496b8bf7485b7ab9dd17be18d044`  

## Spisak alata:
* Clang-tidy
* Memcheck
* Callgrind
* Doxygen

## Reprodukcija Rezultata

### Preduslovi

- CMake 3.16 ili noviji
- Qt6
- Clang-Tidy
- Valgrind sa Memcheck i Callgrind alatima
- Doxygen

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

Detaljni rezultati i interpretacija se nalaze u odgovarajućim README fajlovima u svakom direktorijumu, kao i u ProjectAnalysisReport fajlu.

## Zaključci

1. **Kvalitet koda**: Clang-Tidy je identifikovao nekoliko oblasti za poboljšanje, uključujući modernizaciju C++ koda i poboljšanje čitljivosti. Automatske ispravke su uspešno primenjene.

2. **Upravljanje memorijom**: Valgrind Memcheck je otkrio kritičnu "Invalid read" grešku u upravljanju Qt widget-ima koja je uspešno ispravljena implementacijom pravilnog parent-child ownership modela.

3. **Performanse**: Callgrind analiza je omogućila detaljan uvid u raspodelu procesorskog vremena među funkcijama i identifikaciju delova koda koji imaju najveći uticaj na ukupne performanse aplikacije.

4. **Dokumentacija**: Doxygen je uspešno generisao kompletnu HTML dokumentaciju projekta na osnovu komentara u kodu, što značajno olakšava razumevanje i održavanje softvera.

5. **Razvojni proces (CI)**: Integracija ovih alata u razvojni proces može značajno poboljšati kvalitet koda i smanjiti broj grešaka u produkciji.
