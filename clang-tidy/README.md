# Clang-Tidy

**Clang-Tidy** je alat za statičku analizu C++ koda koji je deo LLVM projekta. Objedinjuje:

- **Stilske provere** - proverava da li kod prati definisane standarde i konvencije.
- **Modernizaciju koda** - preporuke za moderne C++ idiome (C++11/14/17/20).
- **Detekciju bagova** - pronalaženje čestih programerskih grešaka.
- **Optimizacije performansi** - identifikovanje neefikasnog koda.
- **Čitljivost** - poboljšanje jasnoće koda.

Clang-Tidy može automatski predložiti ispravke za mnoge probleme.

## Preduslovi

### Instalacija na Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install clang-tidy cmake ninja-build
```

### Provera instalacije
```bash
clang-tidy --version
```

## Pokretanje Analize

### Automatsko pokretanje skripte

```bash
cd 2023_Analysis_13-Git-stat/clang-tidy
./run_clang_tidy.sh
```

Skripta automatski:
1. Generiše `compile_commands.json` koristeći CMake
2. Pronalazi sve relevantne C++ izvorne fajlove u src i include folderima, isključujući Qt GUI fajlove i generisane .ui, moc, qrc fajlove
3. Pokreće clang-tidy analizu na svakom fajlu
4. Generiše detaljni izveštaj u `analysis_git_stat/clang-tidy/clang_tidy_results.txt`

### Manuelno pokretanje

```bash
cd 13-Git-stat

# 1. Generisanje compile_commands.json
mkdir -p build
cd build
cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# 2. Analiza
run-clang-tidy main.cpp -checks='modernize-*' > ../check.txt

# 3. Analiza sa automatskim ispravkama
run-clang-tidy main.cpp -checks='modernize-*' -fix
```

## Kategorije provera

Skripta koristi sledeće kategorije provera:

| Kategorija               | Opis                     | Primer pravila |
| ------------------------ | ------------------------ | -------------- |
| **clang-diagnostic-***   | Upozorenja kompajlera    | `-Wunused-variable`, `-Wsign-compare` |
| **clang-analyzer-***     | Duboka statička analiza  | `clang-analyzer-core.*`, `clang-analyzer-cplusplus.*` |
| **readability-***        | Poboljšanje čitljivosti  | `readability-identifier-naming`, `readability-braces-around-statements` |
| **modernize-use-***      | Modernizacija koda       | `modernize-use-auto`, `modernize-use-nullptr`, `modernize-use-noexcept`, `modernize-use-emplace`, `modernize-use-emplace-back`, `modernize-loop-convert`, `modernize-use-using` |



### Isključeni Checks

Neki checks su namerno isključeni da bi se smanjio šum:
- `readability-magic-numbers` - preveliki broj false positive-a
- `cppcoreguidelines-avoid-magic-numbers` - ista oduka kao gore
- `readability-identifier-length` - dozvoljeni su kratki identifikatori gde ima smisla


## Interpretacija Rezultata

Pokrenula sam skriptu bez opcije fix kako bih proverila koje greške clang-tidy nalazi. 

![](./Screenshot%20from%202025-10-17%2003-07-57.png)

Neki od primera pronađenih upozorenja:
![](./Screenshot%20from%202025-10-17%2003-03-46.png)

![](./Screenshot%20from%202025-10-17%2003-13-28.png)


Nakon provere, skripta je pokrenuta sa fix=true da bi se automatski primenile ispravke koje clang-tidy predlaže.

![](./Screenshot%20from%202025-10-17%2003-06-42.png)

Neke od promena koje su izvrsene:

![](./Screenshot%20from%202025-10-17%2003-27-01.png)

![](./Screenshot%20from%202025-10-17%2003-30-08.png)

Time su greške poput gore navedenih automatski ispravljene u kodu.