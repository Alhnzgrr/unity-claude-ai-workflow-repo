# Serialization Rules

## FormerlySerializedAs Required

Renaming a [SerializeField] field causes data loss. Required on every rename:

```csharp
// Field name changed from _speed to _moveSpeed
[SerializeField]
[FormerlySerializedAs("_speed")]
private float _moveSpeed = 5f;
```

## [SerializeField] Preference

```csharp
// CORRECT — private, visible in inspector
[SerializeField] private float _speed = 5f;

// WRONG — unnecessarily public
public float speed = 5f;
```

## Runtime State Is Not Serialized

ScriptableObject or serialized fields are for configuration only.
State that changes at runtime → plain C# field.

```csharp
// WRONG — serializing runtime state
[SerializeField] private int _currentHealth;

// CORRECT — serialize config, keep state separate
[SerializeField] private int _maxHealth = 100;
private int _currentHealth; // runtime, do not serialize
```

## Unity Null Check

On Unity objects, `?.` and `is null` operators bypass Unity's overridden == comparison
rather than checking real null:

```csharp
// WRONG — bypasses Unity's destroyed check
if (_component?.DoSomething() != null) { }
if (_go is null) { }

// CORRECT
if (_component != null) _component.DoSomething();
if (_go == null) { }
```

## SerializeReference

For polymorphic serialization:

```csharp
[SerializeReference] private IAbility _ability;
```
