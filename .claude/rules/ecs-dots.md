# ECS / DOTS Rules

> Aktif koşul: `project-config.json` → `"ecs": true`

## Temel Yapı

```csharp
// Component — pure data
public struct HealthComponent : IComponentData
{
    public float Value;
    public float Max;
}

// System — logic
public partial struct HealthSystem : ISystem
{
    public void OnUpdate(ref SystemState state)
    {
        foreach (var (health, entity) in
            SystemAPI.Query<RefRW<HealthComponent>>().WithEntityAccess())
        {
            if (health.ValueRO.Value <= 0)
                state.EntityManager.DestroyEntity(entity);
        }
    }
}
```

## Authoring / Baker

```csharp
public class HealthAuthoring : MonoBehaviour
{
    public float MaxHealth = 100f;

    public class Baker : Baker<HealthAuthoring>
    {
        public override void Bake(HealthAuthoring authoring)
        {
            var entity = GetEntity(TransformUsageFlags.Dynamic);
            AddComponent(entity, new HealthComponent
            {
                Value = authoring.MaxHealth,
                Max = authoring.MaxHealth
            });
        }
    }
}
```

## IJobEntity — Paralel İşlem

```csharp
[BurstCompile]
public partial struct MoveJob : IJobEntity
{
    public float DeltaTime;

    void Execute(ref LocalTransform transform, in VelocityComponent velocity)
    {
        transform.Position += velocity.Value * DeltaTime;
    }
}
```

## EntityCommandBuffer

Structural change'ler (add/remove component, destroy) ECB ile yapılır:

```csharp
var ecb = new EntityCommandBuffer(Allocator.TempJob);
ecb.DestroyEntity(entity);
ecb.Playback(state.EntityManager);
ecb.Dispose();
```

## Hybrid Linking

MonoBehaviour ↔ Entity iletişimi için `EntityReference` component veya
`CompanionComponentSystemGroup` kullan.

## IEvent'lerde byte Base

```csharp
// ECS event enum'ları byte base kullanır (cache line optimizasyonu)
public enum EnemyState : byte { Idle, Moving, Attacking, Dead }
```
