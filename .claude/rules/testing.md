# Testing Rules

## Test Tipi Karar Ağacı

```
Unity API var mı?
├── Hayır → EditMode Test (NUnit, hızlı)
└── Evet → Scene gerekiyor mu?
    ├── Hayır → PlayMode Programmatic (MonoBehaviour olmadan)
    └── Evet → PlayMode Scene Test
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
    yield return null; // Awake/Start çalışsın

    view.SimulateInput(Vector2.right);
    yield return new WaitForSeconds(0.1f);

    Assert.Greater(go.transform.position.x, 0f);

    Object.Destroy(go);
}
```

## NSubstitute Kuralları

```csharp
// Mock oluştur
var mock = Substitute.For<IService>();

// Davranış tanımla
mock.GetValue().Returns(42);

// Çağrı doğrula
mock.Received(1).Process(Arg.Any<string>());
mock.DidNotReceive().Process("forbidden");
```

## AAA Pattern Zorunlu

Her test: Arrange / Act / Assert bölümleriyle.
Tek test → tek assertion konusu (birden fazla Assert kabul edilebilir ama tek davranışı test eder).

## Test Dosya Konumu

```
Scripts/Tests/
├── [Project]EditModeTest/
│   └── [Domain]/[Class]Tests.cs
└── [Project]PlayModeTest/
    └── [Feature]/[Feature]PlayTests.cs
```
