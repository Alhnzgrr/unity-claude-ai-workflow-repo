# /search

Codebase araştırması ve action router.

## Kullanım

```
/search <sorgu>
```

Örnekler:
```
/search IAudioService nerede implement edilmiş?
/search singleton pattern var mı?
/search PlayerService'i kim kullanıyor?
```

## Workflow

### Adım 1 — unity-scout

`unity-scout` spawn et:
- Grep ve Glob ile soru ile ilgili kod bul
- Bağımlılık haritası çıkar
- Bulgular raporla

### Adım 2 — unity-reviewer (analiz gerekiyorsa)

Bulgu review gerektiriyorsa (mimari ihlal vs.) → `unity-reviewer` ekle.

### Adım 3 — Action Router

Sonuca göre öneri:
```
## Arama Sonucu

[Bulgular]

## Önerilen Aksiyon
- Sorun var → /fix ile düzelt
- Refactor gerekiyor → /implement ile yeni yaklaşım
- Sadece bilgi → bilgi verildi, aksiyon gerekmez
```
