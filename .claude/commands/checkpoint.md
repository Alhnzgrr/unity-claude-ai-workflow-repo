# /checkpoint

Konuşma özetini state'e kaydeder. Uzun session'larda context kaybına karşı.

## Kullanım

```
/checkpoint
```

## Workflow

### Adım 1 — Özet Oluştur

Bu session'da yapılanları özetle:
- Hangi task'lar tamamlandı
- Hangi dosyalar oluşturuldu/değiştirildi
- Hangi kararlar alındı
- Nerede kaldık

### Adım 2 — Kaydet

`.claude/state/checkpoint.md`:

```markdown
# Checkpoint — [Tarih Saat]

## Bu Session'da Yapılanlar
- [tamamlanan task'lar]

## Değiştirilen Dosyalar
- [dosya listesi]

## Alınan Kararlar
- [mimari kararlar, trade-off'lar]

## Devam Noktası
[Bir sonraki session nereye bağlanmalı]
```

### Adım 3 — Onay

```
✅ Checkpoint kaydedildi: .claude/state/checkpoint.md
Yeni session'da /context-prime ile yüklenebilir.
```
