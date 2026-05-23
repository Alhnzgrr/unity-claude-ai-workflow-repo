# /validate

Tamamlanan faz için exit criteria kontrolü.

## Kullanım

```
/validate
```

## Kontrol Listesi

- [ ] Compile: hata yok
- [ ] EditMode testler: hepsi geçiyor
- [ ] PlayMode testler (varsa): hepsi geçiyor
- [ ] Console: error ve exception yok (warning kabul edilebilir)
- [ ] Serialization riski: FormerlySerializedAs kontrol edildi
- [ ] Silent failures: temiz
- [ ] Mimari kurallar: ihlal yok (unity-linter çalıştır)

## Output

```
## Validation Raporu

Compile: ✅ OK
EditMode Tests: ✅ [N] passed
PlayMode Tests: ✅ [N] passed
Console Errors: ✅ Temiz
Serialization: ✅ Risk yok
Silent Failures: ✅ Temiz

Sonuç: PASS / PARTIAL / FAIL
```

PARTIAL veya FAIL → hangi madde takıldığını belirt.
