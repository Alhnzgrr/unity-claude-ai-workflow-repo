# Performance Rules

## Hot Path Tanımı

`Update()`, `FixedUpdate()`, `LateUpdate()` ve bunlardan çağrılan her metot hot path'tir.

## Allocation Yasağı

Hot path'te GC allocation sıfır olmalı:

```csharp
// YANLIŞ — her frame allocation
void Update()
{
    var enemies = new List<Enemy>(); // allocation!
    var name = $"Enemy_{id}";       // string allocation!
}

// DOĞRU — önceden alloc edilmiş
private readonly List<Enemy> _enemies = new(32);
private readonly StringBuilder _sb = new();
```

## LINQ Yasağı (Hot Path)

```csharp
// YANLIŞ — Update içinde
void Update()
{
    var alive = _enemies.Where(e => e.IsAlive).ToList();
}

// DOĞRU — for loop
void Update()
{
    for (int i = 0; i < _enemies.Count; i++)
        if (_enemies[i].IsAlive) Process(_enemies[i]);
}
```

## GetComponent Cache Zorunlu

```csharp
// YANLIŞ
void Update() { GetComponent<Rigidbody>().AddForce(Vector3.up); }

// DOĞRU
private Rigidbody _rb;
void Awake() => _rb = GetComponent<Rigidbody>();
void Update() => _rb.AddForce(Vector3.up);
```

## Find* Yasağı (Hot Path)

`Camera.main`, `FindObjectOfType`, `FindAnyObjectByType` → inject et veya cache'le.

## Object Pooling

Sık oluşturulan/yok edilen objeler için `ObjectPool<T>` kullan:

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

## Draw Call Disiplini

- Static objeler → Static Batching işaretle
- Aynı material kullanan dinamik objeler → GPU Instancing
- UI Canvas'ları ayrı tut (World Space / Screen Space)
