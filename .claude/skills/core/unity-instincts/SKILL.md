---
name: unity-instincts
description: Unity geliştirmede hızlı, güvenilir kararlar için proje genelinde geçerli instinct'ler.
---

# Unity Instincts

Sık tekrarlanan durumlar için önceden belirlenmiş kararlar. Her seferinde analiz yapmak yerine bu instinct'leri uygula.

## Genel İnstinct'ler

**Yeni bir sistem gerekiyor mu?**
→ Önce Interface yaz, sonra implementasyon. Hiçbir zaman ters sırayla.

**Servisler arası iletişim mi?**
→ IEventBus. Doğrudan referans değil.

**Async bir işlem mi?**
→ UniTask + CancellationToken. Her zaman. İstisna yok.

**MonoBehaviour'a bağımlılık mı?**
→ [Inject] void Construct(...). Constructor değil.

**Yeni GameObject gerekiyor mu?**
→ Prefab'dan Instantiate. new GameObject() değil.

**Coroutine → UniTask geçişi mi?**
→ yield return new WaitForSeconds(t) → await UniTask.Delay(ms, ct)
→ yield return null → await UniTask.Yield()
→ yield return new WaitForEndOfFrame() → await UniTask.WaitForEndOfFrame()

**Event subscribe/unsubscribe mi?**
→ OnEnable'da subscribe, OnDisable'da unsubscribe. Her zaman eşleştirilmiş.

**Performans sorusu mu?**
→ Önce profiler. Varsayım yapma. Ölçümsüz optimizasyon yapma.

**Test yazıyor musun?**
→ Unity API gerektirmiyor → EditMode. Gerektiriyor → PlayMode. Scene lazım → PlayMode Scene.

**Yeni dosya mı oluşturacaksın?**
→ Önce interface, sonra concrete. Klasöre bak: Abstracts/ ve Concretes/ ayrı.
