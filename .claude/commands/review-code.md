# /review-code

Belirli dosyaları derinlemesine review eder.

## Kullanım

```
/review-code <dosya yolu veya glob pattern>
```

Örnekler:
```
/review-code Assets/_GameFolders/Scripts/Games/Concretes/Audio/AudioService.cs
/review-code Assets/_GameFolders/Scripts/Games/Concretes/Audio/
```

## Workflow

### Adım 1 — Dosyaları Oku

Belirtilen dosyaları Read tool ile oku (gateguard bypass için zorunlu).

### Adım 2 — unity-reviewer

`unity-reviewer` spawn et. Tam review kontrol listesi ile.

### Adım 3 — Raporu Göster

Reviewer output'unu göster:
- Must Fix (blocker)
- Should Improve (öneri)
- Optional (nice-to-have)
- Unity Notes (Unity-spesifik)

### Adım 4 — Kullanıcı Kararı

Must Fix varsa: "Düzeltmemi ister misin? (yes/no)"
