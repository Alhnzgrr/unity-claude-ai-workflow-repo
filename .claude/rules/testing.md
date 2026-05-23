# Testing Rules

## Test Type Decision Tree

```text
Does it use Unity API?
  No -> EditMode test (NUnit, fast)
  Yes -> Does it need a scene or Unity lifecycle?
    No -> EditMode or PlayMode programmatic test
    Yes -> PlayMode scene test
```

Prefer EditMode tests whenever the behavior can be tested without Unity runtime objects.

## EditMode Test (Pure C#)

```csharp
[TestFixture]
public sealed class AudioServiceTests
{
    private AudioService _sut;
    private IEventBus _eventBus;

    [SetUp]
    public void SetUp()
    {
        _eventBus = Substitute.For<IEventBus>();
        _sut = new AudioService(_eventBus);
    }

    [Test]
    public void Play_PublishesAudioStartedEvent()
    {
        // Arrange
        const string clipName = "explosion";

        // Act
        _sut.Play(clipName);

        // Assert
        _eventBus.Received(1)
            .Publish(Arg.Is<AudioStartedEvent>(e => e.ClipName == clipName));
    }
}
```

## PlayMode Programmatic Test Exception

Production code must not create scene objects directly. Tests may create temporary `GameObject` instances when the test is explicitly verifying MonoBehaviour behavior.

Rules for this exception:

- Use temporary objects only inside test code.
- Name the object clearly when useful.
- Destroy the object at the end of the test.
- Do not copy this pattern into runtime gameplay code.

```csharp
[UnityTest]
public IEnumerator PlayerView_ReceivesInput_MovesCharacter()
{
    var go = new GameObject("PlayerView Test Object");
    var view = go.AddComponent<PlayerView>();
    yield return null;

    view.SimulateInput(Vector2.right);
    yield return null;

    Assert.Greater(go.transform.position.x, 0f);

    Object.Destroy(go);
}
```

## Coroutine Exception for UnityTest

Runtime coroutines are forbidden in production code. `IEnumerator` is allowed in tests only when required by Unity's `[UnityTest]` runner.

For production async behavior, use UniTask. For test harness control, Unity's coroutine-based test runner is acceptable.

## NSubstitute Rules

```csharp
var mock = Substitute.For<IService>();

mock.GetValue().Returns(42);

mock.Received(1).Process(Arg.Any<string>());
mock.DidNotReceive().Process("forbidden");
```

## AAA Pattern Required

Every test should have Arrange, Act, and Assert sections.

One test should validate one behavior. Multiple assertions are acceptable when they describe the same behavior.

## Test File Location

```text
Scripts/Tests/
  [Project]EditModeTest/
    [Domain]/[Class]Tests.cs
  [Project]PlayModeTest/
    [Feature]/[Feature]PlayTests.cs
```

## Common Mistakes

- writing PlayMode tests for pure C# logic
- copying `new GameObject` test setup into runtime code
- using `[UnityTest]` coroutine examples as runtime coroutine approval
- testing implementation details instead of behavior
- forgetting to destroy temporary test objects
