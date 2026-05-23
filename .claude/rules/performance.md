# Performance Rules

## Hot Path Definition

`Update()`, `FixedUpdate()`, `LateUpdate()` and every method called from them is a hot path.

## Allocation Ban

GC allocation must be zero in hot paths:

```csharp
// WRONG — allocation every frame
void Update()
{
    var enemies = new List<Enemy>(); // allocation!
    var name = $"Enemy_{id}";       // string allocation!
}

// CORRECT — pre-allocated
private readonly List<Enemy> _enemies = new(32);
private readonly StringBuilder _sb = new();
```

## LINQ Ban (Hot Path)

```csharp
// WRONG — inside Update
void Update()
{
    var alive = _enemies.Where(e => e.IsAlive).ToList();
}

// CORRECT — for loop
void Update()
{
    for (int i = 0; i < _enemies.Count; i++)
        if (_enemies[i].IsAlive) Process(_enemies[i]);
}
```

## GetComponent Cache Required

```csharp
// WRONG
void Update() { GetComponent<Rigidbody>().AddForce(Vector3.up); }

// CORRECT
private Rigidbody _rb;
void Awake() => _rb = GetComponent<Rigidbody>();
void Update() => _rb.AddForce(Vector3.up);
```

## Find* Ban (Hot Path)

`Camera.main`, `FindObjectOfType`, `FindAnyObjectByType` → inject or cache.

## Object Pooling

Use `ObjectPool<T>` for frequently created/destroyed objects:

```csharp
private IObjectPool<BulletView> _pool;

void Awake()
{
    _pool = new ObjectPool<BulletView>(
        createFunc: () => Instantiate(_bulletPrefab),
        actionOnGet: b => b.gameObject.SetActive(true),
        actionOnRelease: b => b.gameObject.SetActive(false),
        actionOnDestroy: b => Destroy(b.gameObject),
        defaultCapacity: 32,
        maxSize: 128
    );
}
```

## Draw Call Discipline

- Static objects → mark Static Batching
- Dynamic objects sharing the same material → GPU Instancing
- Keep UI Canvases separate (World Space / Screen Space)
