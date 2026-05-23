# /performance-audit

Hot path allocation ve draw call denetimi.

## Kullanım

```
/performance-audit [opsiyonel: klasör veya dosya]
```

## Workflow

### Adım 1 — Tarama Kapsamı

Belirtilmişse o dosya/klasör, yoksa tüm `Concretes/` klasörü.

### Adım 2 — unity-optimizer

`unity-optimizer` spawn et:
- Update/FixedUpdate metotlarını tara
- Allocation pattern'leri bul
- LINQ kullanımı
- GetComponent/Camera.main/Find* hot path'te mi?

### Adım 3 — unity-developer (full modda)

review-mode == `full` → `unity-developer` ek perspektif sunar.

### Adım 4 — Rapor

```
## Performans Denetim Raporu

### Kritik (hemen düzelt)
- [dosya:satır]: [sorun] → [öneri]

### İzle
- [dosya:satır]: [sorun]

### Temiz
- [N] dosya tarandı, sorun yok
```
