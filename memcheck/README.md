# Valgrind Memcheck - Detekcija Problema sa Memorijom

Ovaj direktorijum sadrži skripte i rezultate **Valgrind Memcheck** analize za projekat Git-stat.

## Opis Alata

Alat Memcheck je deo paketa Valgrind i koristi se za otkrivanje grešaka u radu sa memorijom u programima napisanima na jezicima kao što su C i C++ koji detektuje:

- curenja memorije (alocirani blokovi koji nikad nisu oslobođeni)
- pristup memoriji van granica alociranog bloka
- korišćenje neinicijalizovane memorije
- korišćenje memorije nakon što je oslobođena
- višestruko oslobađanje iste memorije
- prekoračenja stack i globalnih nizova

Valgrind radi tako što simulira izvršavanje programa u virtuelnom CPU-u, prateći svaku memorijsku operaciju.

## Preduslovi

### Instalacija na Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install valgrind
```

### Provera instalacije
```bash
valgrind --version
```

## Pokretanje Analize

### Automatsko pokretanje

```bash
cd 2023_Analysis_13-Git-stat/valgrind-memcheck
./run_memcheck.sh
```

Skripta automatski:

1. Kompajlira projekat sa debug simbolima
2. Pokreće aplikaciju kroz Valgrind Memcheck
3. Generiše detaljni log svih memorijskih operacija
4. Filtrira Qt library false positives pomoću suppression fajla

## Opcije Memcheck-a

| Opcija                         | Opis                                                                   |
| ------------------------------ | ---------------------------------------------------------------------- |
| `--leak-check=full`            | Detaljno prikazuje svaki memory leak                                   |
| `--show-leak-kinds=all`        | Prikazuje sve tipove curenja (definite, indirect, possible, reachable) |
| `--track-origins=yes`          | Prati poreklo neinicijalizovanih vrednosti (sporije ali korisnije)     |
| `--log-file=memcheck_full.out` | Snima output u fajl                                                    |
| `--suppressions=qt.supp`       | Ignoriše false positives iz suppression fajla                          |

## Proces Analize i Filtriranje Rezultata

Prilikom prvog pokretanja Valgrind alata memcheck, putem skripte `run_memcheck.sh`, izlaz je upisan u `memcheck_full.log`. S obzirom da dobijen log fajl ima više stotina hiljada linija, pri čemu se dosta pronađenih grešaka odnosi na Qt biblioteke, napravljeni su koraci kako bi izveštaj bio čitljiviji.

Sledeće biblioteke generišu poznate false positive rezultate:

1. **Qt Core biblioteke**:
   - `libQt6Core.so`
   - `libQt6Gui.so` 
   - `libQt6Widgets.so`
   - `libQt6WaylandClient.so`

2. **Sistemske biblioteke**:
   - `libwayland-client.so`
   - `libglib-2.0.so`

### Razlog False Positives

Qt aplikacije alociraju resurse koje operativni sistem automatski oslobađa pri izlasku iz programa. Ovo nije pravi memory leak već normalno ponašanje Qt framework-a.

#### Filtriranje False Positives

**Komanda za analizu samo korisničkog koda**:

```bash
valgrind \
    --tool=memcheck \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    --verbose \
    --log-file="$OUTPUT_DIR/memcheck_full.log" \
    --suppressions=qt.supp \
    "$EXECUTABLE_PATH"
```

Nakon pokretanja nove komande možemo da primetimo da je fajl dosta manji i čitljiviji.

### Identifikovana Greška u Korisničkom Kodu

**Invalid read of size 8** u funkciji `RepoNode::getRepo()`

Analiza je pokazala da se greška javlja zbog nepravilnog upravljanja memorijom Qt widget-a. Problem nastaje kada se objekti tipa `RepoNode` kreiraju bez parent widget-a, pa kada su manualno brisani u `removeRepository` funkciji, Qt signal/slot mehanizam je i dalje pokušavao da pristupi već izbrisanom objektu.

**Implementirano rešenje:**
Prilikom kreiranja `RepoNode` objekta prosleđen je parent widget:

```cpp
// Umesto:
RepoNode* r = new RepoNode();

// Koristi se:
RepoNode* r = new RepoNode(ui->glRepos->parentWidget());
```

**Rezultat:**
Qt sada automatski upravlja memorijom child widget-a i objekti nisu više ručno brisani dok su i dalje u upotrebi. Greška "Invalid read" više ne postoji.

### Leak Summary

Nakon filtriranja Qt false positives, u izveštaju se nalaze sledeće informacije o curenju memorije:

![Dodaj sliku]()

## Ograničenja Valgrind-a

1. **Performanse**: 20-50x usporenje
2. **False Positives**: Posebno sa Qt i system libraries
3. **macOS Kompatibilnost**: Loša podrška za novije verzije
4. **GUI Testing**: Teško je testirati GUI aplikacije interaktivno
5. **Race Conditions**: Memcheck ne detektuje threading probleme (koristi Helgrind za to)

## Alternative

- **AddressSanitizer (ASan)** - brži (2-3x usporenje)
- **Valgrind Helgrind** - za thread safety probleme

## Zaključci

1. **Overall Health**: Projekat ima relativno malo memory leak-ova
2. **Critical Issues**: Nekoliko "definitely lost" blokova koji zahtevaju pažnju
3. **Qt Management**: Većina "still reachable" je legitimno Qt behavior
4. **Recommendations**: Koristiti smart pointer-e i RAII principe