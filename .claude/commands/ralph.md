# /ralph

Yeşil olana kadar verify-fix loop. Max 10 iterasyon.

## Kullanım

```
/ralph
```

## Workflow

```
iterasyon = 0

LOOP:
  iterasyon += 1
  unity-verifier → compile + test
  
  PASSED → "Yeşil! [iterasyon] iterasyonda geçti." → DUR
  
  FAILED:
    iterasyon >= 10 → "STUCK: 10 iterasyon sonra hala kırmızı." → DUR
    unity-coder → hatayı düzelt
    LOOP'a dön
```

## Sıkışma Çıkışı

10 iterasyon sonra geçmiyorsa:
```
❌ STUCK after 10 iterations
Son hata: [hata mesajı]
Öneri: /fix-deep ile root cause analizi yap
```
