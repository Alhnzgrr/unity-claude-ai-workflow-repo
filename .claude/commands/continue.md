# /continue

Kesilen /orchestrate'i kaldığı yerden devam ettirir.

## Kullanım

```
/continue
```

## Workflow

### Adım 1 — State Oku

`.claude/state/session.json` oku:
- Hangi fazda kaldık?
- Hangi task tamamlandı?
- Hangi dosyalar değişti?

### Adım 2 — Checkpoint Oku (varsa)

`.claude/state/checkpoint.md` oku — bağlam topla.

### Adım 3 — Devam Et

```
Son durum: Faz [N], Task [M] tamamlanmış.
[Task M+1]'den devam ediliyor...
```

`/orchestrate`'in Adım 1 Faz döngüsüne kalan task'tan gir.

## Session State Format

`.claude/state/session.json`:
```json
{
  "current_phase": 2,
  "current_task": "Task 2.3",
  "completed_tasks": ["Task 1.1", "Task 1.2", "Task 2.1", "Task 2.2"],
  "modified_files": ["Assets/_GameFolders/Scripts/Games/Concretes/Audio/AudioService.cs"]
}
```
