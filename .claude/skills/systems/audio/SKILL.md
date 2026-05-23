---
name: audio
description: Unity Audio system patterns. AudioSource, AudioMixer, module structure.
---

# Audio System

## Module Structure

```
Abstracts/Audio/
└── IAudioService.cs

Concretes/Audio/
├── AudioService.cs          ← sealed, UniTask async
├── AudioConfiguration.cs    ← ScriptableObject (volume, clips dict)
├── AudioInstaller.cs        ← VContainer/Zenject register
├── AudioEvents.cs           ← AudioStartedEvent, AudioStoppedEvent
└── AudioProvider.cs         ← MonoBehaviour, AudioSource wrapper
```

## IAudioService

```csharp
public interface IAudioService
{
    UniTask PlayAsync(string clipKey, CancellationToken ct);
    void Stop(string clipKey);
    void SetVolume(float volume);
}
```

## AudioConfiguration

```csharp
[CreateAssetMenu(menuName = "Config/Audio")]
public sealed class AudioConfiguration : ScriptableObject
{
    [SerializeField] private AudioClip[] _clips;
    [SerializeField] private float _masterVolume = 1f;

    private Dictionary<string, AudioClip> _clipMap;

    public float MasterVolume => _masterVolume;
    public AudioClip GetClip(string key) =>
        _clipMap.TryGetValue(key, out var clip) ? clip : null;

    void OnEnable()
    {
        _clipMap = _clips.ToDictionary(c => c.name, c => c);
    }
}
```

## AudioMixer Usage

Each AudioSource is linked to an AudioMixerGroup:
- Master → Music, SFX, UI sub-groups
- Mixer parameters exposed → runtime volume control

## Pool Usage

Many short sound effects → AudioSource pool:
```csharp
private IObjectPool<AudioSource> _sourcePool;
```
