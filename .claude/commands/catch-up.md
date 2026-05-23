# /catch-up

İnsan-okunabilir codebase kılavuzu üretir.

## Kullanım

```
/catch-up
```

## Workflow

### Adım 1 — Codebase Tara

`unity-scout` ile:
- Tüm Interface'leri listele
- Tüm Service'leri listele
- Bağımlılık grafiğini çıkar

### Adım 2 — CATCH_UP.md Üret

`docs/CATCH_UP.md`:

```markdown
# Codebase Kılavuzu — [Tarih]

## Sistemler

| Sistem | Interface | Sorumluluk |
|---|---|---|
| Audio | IAudioService | Ses çalma, durdurma, volume |
| Player | IPlayerService | Hareket, input, state |

## Bağımlılık Grafiği
[Metin diagram]

## DI Wiring
[AppScope / GameScope'ta ne register edilmiş]

## Önemli Pattern'ler
[Projede kullanılan kritik pattern'ler]
```

### Adım 3 — Commit

```bash
git add docs/CATCH_UP.md
git commit -m "docs: update CATCH_UP.md codebase guide"
```
