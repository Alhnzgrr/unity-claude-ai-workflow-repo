---
name: object-pooling
description: Use when implementing or reviewing repeated spawn/despawn flows, projectiles, VFX, UI items, enemies, or mobile-sensitive allocation paths.
---

# Object Pooling

## Purpose

Reduce runtime allocation, garbage collection, and frame spikes by reusing objects with clear lifecycle rules.

## Core Idea

Pooling is useful when objects are created and destroyed frequently. It is not a default replacement for every `Instantiate`.

## When To Use Pooling

Use pooling for:

- projectiles
- hit VFX
- floating damage text
- enemy waves
- reusable UI rows
- short-lived audio sources
- frequently spawned gameplay props

Avoid pooling for:

- rare objects
- objects with complex one-off setup
- objects whose lifecycle is simpler with direct creation
- prototypes where pooling hides the actual design problem

## Unity Built-In Pool

Prefer `UnityEngine.Pool.ObjectPool<T>` when it fits.

```csharp
private ObjectPool<BulletView> _pool;

private void Awake()
{
    _pool = new ObjectPool<BulletView>(
        createFunc: CreateBullet,
        actionOnGet: bullet => bullet.gameObject.SetActive(true),
        actionOnRelease: bullet => bullet.gameObject.SetActive(false),
        actionOnDestroy: bullet => Destroy(bullet.gameObject),
        collectionCheck: true,
        defaultCapacity: 32,
        maxSize: 128);
}
```

## Lifecycle Pattern

Pooled objects need explicit lifecycle hooks:

```csharp
public interface IPooledView
{
    void OnSpawned();
    void OnDespawned();
}
```

On spawn:

- reset visual state
- reset timers
- assign owner/context
- subscribe to needed events

On despawn:

- stop tweens and coroutines
- unsubscribe events
- clear references
- disable expensive components if needed

## Reset Pattern

```csharp
public sealed class BulletView : MonoBehaviour
{
    private ObjectPool<BulletView> _pool;
    private Rigidbody _rigidbody;

    public void Initialize(ObjectPool<BulletView> pool)
    {
        _pool = pool;
    }

    public void OnSpawned(Vector3 position, Vector3 velocity)
    {
        transform.position = position;
        _rigidbody.linearVelocity = velocity;
    }

    public void Despawn()
    {
        _rigidbody.linearVelocity = Vector3.zero;
        _pool.Release(this);
    }
}
```

## Safety Rules

- Never release the same instance twice.
- Never keep stale owner/context references after release.
- Reset visual and logical state before reuse.
- Do not call `Destroy` on pooled instances except in pool destroy callbacks.
- Keep pool ownership clear.

## Mobile and Runtime Notes

Pooling is especially valuable on mobile and VR where garbage collection and frame spikes are more visible.

Pool sizes should be tuned from expected peak usage, not guessed blindly.

## Common Mistakes

- pooling objects but not resetting state
- event leaks from pooled objects
- double release
- hiding too much behavior in pool callbacks
- creating pools for objects that are rarely spawned

## AI Review Guidance

When reviewing pooling, check:

- Is the object spawned frequently enough to justify pooling?
- Is reset behavior complete?
- Are events and tweens cleaned up on despawn?
- Is ownership of the pool clear?
- Are max sizes and overflow behavior reasonable?
