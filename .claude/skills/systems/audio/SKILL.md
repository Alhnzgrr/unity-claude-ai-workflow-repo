---
name: audio
description: Use when implementing or reviewing Unity audio playback, AudioMixer routing, pooled one-shots, music, UI sounds, or audio service architecture.
---

# Audio System

## Purpose

Help agents build audio systems that are testable, mixer-driven, pooled where needed, and separated from scene-specific AudioSource details.

## Core Idea

Audio intent belongs in services. Unity playback details belong in providers or views.

## Use When

Use this skill for:

- music playback
- SFX playback
- UI sounds
- AudioMixer volume control
- audio config assets
- pooled one-shot audio
- async audio loading or transitions

## Recommended Module Structure

```text
Abstracts/Audio/
  IAudioService.cs

Concretes/Audio/
  AudioService.cs
  AudioConfiguration.cs
  AudioInstaller.cs
  AudioEvents.cs
  AudioProvider.cs
```

## Public API Shape

```csharp
public interface IAudioService
{
    UniTask PlayMusicAsync(string key, CancellationToken ct);
    void PlayOneShot(string key, AudioChannel channel);
    void StopMusic();
    void SetVolume(AudioChannel channel, float normalizedVolume);
}
```

The API should express game intent, not expose raw `AudioSource` manipulation.

## Configuration Pattern

```csharp
[CreateAssetMenu(menuName = "Config/Audio")]
public sealed class AudioConfiguration : ScriptableObject
{
    [SerializeField] private AudioClipEntry[] _clips;
    [SerializeField] private AudioMixer _mixer;

    public AudioMixer Mixer => _mixer;

    public bool TryGetClip(string key, out AudioClip clip)
    {
        for (int i = 0; i < _clips.Length; i++)
        {
            if (_clips[i].Key == key)
            {
                clip = _clips[i].Clip;
                return true;
            }
        }

        clip = null;
        return false;
    }
}
```

Avoid building dictionaries in `Update`. If a lookup table is needed, build it once in `OnEnable` or during initialization.

## Provider Pattern

`AudioProvider` owns Unity objects:

- music `AudioSource`
- SFX pool
- UI audio source
- mixer groups
- low-level playback calls

`AudioService` owns policy:

- which clip key to play
- volume rules
- event publishing
- music transition decisions

## AudioMixer Guidance

Route audio through mixer groups:

```text
Master
  Music
  SFX
  UI
```

Expose mixer parameters for runtime volume. Store normalized user volume in settings, then convert to decibels at the mixer boundary.

## Pooling Guidance

Use a pool for frequent short SFX. Do not allocate a new `AudioSource` for every one-shot.

```csharp
public void PlayOneShot(AudioClip clip, AudioMixerGroup group)
{
    AudioSource source = _pool.Get();
    source.outputAudioMixerGroup = group;
    source.clip = clip;
    source.Play();
    ReleaseWhenFinishedAsync(source, destroyCancellationToken)
        .Forget(Debug.LogException);
}
```

## Events

Useful events:

- `AudioClipStartedEvent`
- `AudioClipStoppedEvent`
- `MusicChangedEvent`
- `VolumeChangedEvent`

Publish events for system coordination. Do not use `UnityEvent`.

## Testing Guidance

Use EditMode tests for service policy:

- unknown clip key fails clearly
- volume is clamped
- correct event is published
- music transition decision is correct

Use PlayMode tests only for provider behavior that needs Unity objects.

## Good Pattern

```text
Gameplay system -> IAudioService.PlayOneShot("hit", Sfx)
AudioService -> validates key and publishes intent
AudioProvider -> plays clip through AudioSource and mixer
```

## Bad Pattern

```text
EnemyView gets AudioSource and plays arbitrary clips directly.
UI button owns gameplay audio policy.
Every SFX instantiates a new AudioSource.
```

## Common Mistakes

- exposing `AudioSource` through service interfaces
- no mixer routing
- no pooling for frequent one-shots
- silently ignoring missing clip keys
- storing runtime playback state in ScriptableObject config
- using LINQ in hot audio paths

## AI Review Guidance

When reviewing audio code, check:

- Is Unity playback isolated in a provider?
- Does the service API express game intent?
- Are frequent one-shots pooled?
- Are mixer groups and volume conversion handled centrally?
- Are missing clips handled fail-fast or with clear fallback?
- Are tests focused on service policy?
