# ECS / DOTS Rules

> Active condition: `project-config.json` → `"ecs": true`

## Basic Structure

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

## IJobEntity — Parallel Processing

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

Structural changes (add/remove component, destroy) are done via ECB:

```csharp
var ecb = new EntityCommandBuffer(Allocator.TempJob);
ecb.DestroyEntity(entity);
ecb.Playback(state.EntityManager);
ecb.Dispose();
```

## Hybrid Linking

Use `EntityReference` component or `CompanionComponentSystemGroup`
for MonoBehaviour ↔ Entity communication.

## byte Base in IEvents

```csharp
// ECS event enums use byte base (cache line optimization)
public enum EnemyState : byte { Idle, Moving, Attacking, Dead }
```
