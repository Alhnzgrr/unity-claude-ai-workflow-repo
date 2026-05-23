# Serialization Rules

## FormerlySerializedAs Zorunlu

[SerializeField] alan adı değişince veri kaybı olur. Her rename'de zorunlu:

```csharp
// Alan adı _speed → _moveSpeed olarak değişti
[SerializeField]
[FormerlySerializedAs("_speed")]
private float _moveSpeed = 5f;
```

## [SerializeField] Tercihi

```csharp
// DOĞRU — private, inspector'da görünür
[SerializeField] private float _speed = 5f;

// YANLIŞ — gereksiz public
public float speed = 5f;
```

## Runtime State Serialize Edilmez

ScriptableObject veya serialized field'lar sadece konfigürasyon için.
Runtime'da değişen state → plain C# field.

```csharp
// YANLIŞ — runtime state serialize
[SerializeField] private int _currentHealth;

// DOĞRU — config serialize, state ayrı
[SerializeField] private int _maxHealth = 100;
private int _currentHealth; // runtime, serialize etme
```

## Unity Null Check

Unity object'lerde `?.` ve `is null` operator'leri gerçek null değil
Unity'nin override ettiği == karşılaştırmasını atlatır:

```csharp
// YANLIŞ — Unity'nin destroyed check'ini atlatır
if (_component?.DoSomething() != null) { }
if (_go is null) { }

// DOĞRU
if (_component != null) _component.DoSomething();
if (_go == null) { }
```

## SerializeReference

Polymorphic serialization için:

```csharp
[SerializeReference] private IAbility _ability;
```
