# Testing Rules

## Test Type Decision Tree

```
Does it use the Unity API?
├── No  → EditMode Test (NUnit, fast)
└── Yes → Does it need a Scene?
    ├── No  → PlayMode Programmatic (without MonoBehaviour)
    └── Yes → PlayMode Scene Test
```

## EditMode Test (Pure C#)

```csharp
[TestFixture]
public class AudioServiceTests
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
        _eventBus.Received(1).Publish(Arg.Is<AudioStartedEvent>(e => e.ClipName == clipName));
    }
}
```

## PlayMode Test (MonoBehaviour)

```csharp
[UnityTest]
public IEnumerator PlayerView_ReceivesInput_MovesCharacter()
{
    var go = new GameObject();
    var view = go.AddComponent<PlayerView>();
    yield return null; // let Awake/Start run

    view.SimulateInput(Vector2.right);
    yield return new WaitForSeconds(0.1f);

    Assert.Greater(go.transform.position.x, 0f);

    Object.Destroy(go);
}
```

## NSubstitute Rules

```csharp
// Create mock
var mock = Substitute.For<IService>();

// Define behavior
mock.GetValue().Returns(42);

// Verify calls
mock.Received(1).Process(Arg.Any<string>());
mock.DidNotReceive().Process("forbidden");
```

## AAA Pattern Required

Every test: Arrange / Act / Assert sections.
One test → one assertion topic (multiple Asserts are acceptable but test a single behavior).

## Test File Location

```
Scripts/Tests/
├── [Project]EditModeTest/
│   └── [Domain]/[Class]Tests.cs
└── [Project]PlayModeTest/
    └── [Feature]/[Feature]PlayTests.cs
```
