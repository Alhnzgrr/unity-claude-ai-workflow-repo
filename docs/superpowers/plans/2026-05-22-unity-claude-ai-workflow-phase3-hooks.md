# Unity Claude AI Workflow — Phase 3: Hooks

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 9 blocking + 6 warning guardrail hook script'ini oluştur ve test et.

**Architecture:** Her hook Claude Code'dan stdin'e JSON alır (`tool_name`, `tool_input`). Blocking hook'lar exit 2 döner (yazma durur), warning hook'lar exit 0 döner (stderr'e uyarı yazar, devam eder). Hook'lar `jq` ile JSON parse eder.

**Tech Stack:** Bash, jq

**Hook Input Formatı:**
```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.cs",
    "old_string": "...",
    "new_string": "..."
  }
}
```
Write için `tool_input.content` kullanılır.

---

## Dosya Haritası

| Dosya | Tür | Engellediği |
|---|---|---|
| `.claude/hooks/block-scene-edit.sh` | Blocking | .unity/.prefab/.asset direkt edit |
| `.claude/hooks/guard-editor-runtime.sh` | Blocking | UnityEditor namespace guard'sız |
| `.claude/hooks/check-pure-csharp.sh` | Blocking | _Framework/ içinde using UnityEngine |
| `.claude/hooks/check-input-system.sh` | Blocking | Input.GetKey/Axis (new input seçiliyse) |
| `.claude/hooks/check-singleton.sh` | Blocking | Static singleton pattern |
| `.claude/hooks/check-unity-event.sh` | Blocking | UnityEvent kullanımı |
| `.claude/hooks/check-coroutine.sh` | Blocking | IEnumerator/StartCoroutine |
| `.claude/hooks/guard-config-files.sh` | Blocking | settings.json/.asmdef/manifest.json edit |
| `.claude/hooks/gateguard.sh` | Blocking | Session'da okunmamış C# dosyası edit |
| `.claude/hooks/check-linq-hotpath.sh` | Warning | Update içinde LINQ |
| `.claude/hooks/check-expensive-hotpath.sh` | Warning | Hot path'te GetComponent/Camera.main |
| `.claude/hooks/check-async-void.sh` | Warning | async void |
| `.claude/hooks/check-unitask-cancellation.sh` | Warning | CancellationToken eksik |
| `.claude/hooks/check-null-propagation.sh` | Warning | Unity object'te ?. veya is null |
| `.claude/hooks/warn-serialization.sh` | Warning | FormerlySerializedAs eksik rename |

---

### Task 1: block-scene-edit.sh + guard-editor-runtime.sh + check-pure-csharp.sh

**Files:**
- Create: `.claude/hooks/block-scene-edit.sh`
- Create: `.claude/hooks/guard-editor-runtime.sh`
- Create: `.claude/hooks/check-pure-csharp.sh`

- [ ] **Step 1: block-scene-edit.sh yaz**

```bash
#!/bin/bash
# Blocks direct Edit/Write on .unity .prefab .asset files
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

if [[ "$FILE_PATH" =~ \.(unity|prefab|asset)$ ]]; then
    CONFIG=".claude/project-config.json"
    MCP_HINT=""
    if [[ -f "$CONFIG" ]]; then
        MCP_HINT=" Unity Editor'da manuel olarak düzenleyin."
    fi
    echo "HOOK BLOCK [block-scene-edit]: .unity/.prefab/.asset dosyaları direkt edit edilemez.${MCP_HINT}" >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
```

- [ ] **Step 2: guard-editor-runtime.sh yaz**

```bash
#!/bin/bash
# Blocks using UnityEditor in runtime code without #if UNITY_EDITOR guard
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

# Sadece .cs dosyalarını kontrol et
if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Editor/ klasöründeyse izin ver
if [[ "$FILE_PATH" =~ /[Ee]ditors?/ || "$FILE_PATH" =~ \\[Ee]ditors?\\ ]]; then exit 0; fi

# UnityEditor namespace kullanımı var mı?
if echo "$CONTENT" | grep -q "using UnityEditor"; then
    # #if UNITY_EDITOR guard'ı var mı?
    if ! echo "$CONTENT" | grep -q "#if UNITY_EDITOR"; then
        echo "HOOK BLOCK [guard-editor-runtime]: Runtime kodda 'using UnityEditor' tespit edildi." >&2
        echo "Çözüm: '#if UNITY_EDITOR ... #endif' bloğu içine alın veya dosyayı Editors/ klasörüne taşıyın." >&2
        echo "Dosya: $FILE_PATH" >&2
        exit 2
    fi
fi

exit 0
```

- [ ] **Step 3: check-pure-csharp.sh yaz**

```bash
#!/bin/bash
# Blocks using UnityEngine in _Framework/ (pure C# layer)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# _Framework/ klasöründe mi?
if [[ "$FILE_PATH" =~ _Framework ]]; then
    if echo "$CONTENT" | grep -qE "^using UnityEngine|^using UnityEngine\."; then
        echo "HOOK BLOCK [check-pure-csharp]: _Framework/ içinde 'using UnityEngine' yasak." >&2
        echo "_Framework/ pure C# katmanıdır. Unity API kullanmak gerekiyorsa _GameFolders/ içine taşıyın." >&2
        echo "Dosya: $FILE_PATH" >&2
        exit 2
    fi
fi

exit 0
```

- [ ] **Step 4: Test — block-scene-edit.sh**

```bash
# Test: .unity dosyası edit girişimi → exit 2 beklenir
echo '{"tool_name":"Edit","tool_input":{"file_path":"Assets/Scenes/Game.unity","new_string":"test"}}' \
  | bash .claude/hooks/block-scene-edit.sh
echo "Exit code: $?"
```

Beklenen: `HOOK BLOCK [block-scene-edit]` mesajı + exit code 2

```bash
# Test: .cs dosyası edit girişimi → exit 0 beklenir
echo '{"tool_name":"Edit","tool_input":{"file_path":"Assets/Scripts/Player.cs","new_string":"test"}}' \
  | bash .claude/hooks/block-scene-edit.sh
echo "Exit code: $?"
```

Beklenen: exit code 0 (çıktı yok)

- [ ] **Step 5: Test — guard-editor-runtime.sh**

```bash
# Test: Runtime'da UnityEditor — exit 2 beklenir
echo '{"tool_name":"Write","tool_input":{"file_path":"Assets/Scripts/MyService.cs","content":"using UnityEditor;\npublic class MyService {}"}}' \
  | bash .claude/hooks/guard-editor-runtime.sh
echo "Exit code: $?"
```

Beklenen: exit code 2

```bash
# Test: #if UNITY_EDITOR ile korumalı — exit 0 beklenir
echo '{"tool_name":"Write","tool_input":{"file_path":"Assets/Scripts/MyService.cs","content":"#if UNITY_EDITOR\nusing UnityEditor;\n#endif\npublic class MyService {}"}}' \
  | bash .claude/hooks/guard-editor-runtime.sh
echo "Exit code: $?"
```

Beklenen: exit code 0

- [ ] **Step 6: Commit**

```bash
git add .claude/hooks/block-scene-edit.sh .claude/hooks/guard-editor-runtime.sh .claude/hooks/check-pure-csharp.sh
git commit -m "feat: add scene-edit, editor-runtime and pure-csharp blocking hooks"
```

---

### Task 2: check-input-system.sh + check-singleton.sh + check-unity-event.sh + check-coroutine.sh

**Files:**
- Create: `.claude/hooks/check-input-system.sh`
- Create: `.claude/hooks/check-singleton.sh`
- Create: `.claude/hooks/check-unity-event.sh`
- Create: `.claude/hooks/check-coroutine.sh`

- [ ] **Step 1: check-input-system.sh yaz**

```bash
#!/bin/bash
# Blocks legacy Input.GetKey/Axis when project-config input == "new"
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

CONFIG=".claude/project-config.json"
if [[ ! -f "$CONFIG" ]]; then exit 0; fi

INPUT_TYPE=$(jq -r '.input // "new"' "$CONFIG")
if [[ "$INPUT_TYPE" != "new" ]]; then exit 0; fi

if echo "$CONTENT" | grep -qE "Input\.(GetKey|GetKeyDown|GetKeyUp|GetAxis|GetButton|GetButtonDown|GetButtonUp|GetMouseButton)"; then
    echo "HOOK BLOCK [check-input-system]: Legacy Input API kullanımı tespit edildi." >&2
    echo "Proje New Input System kullanıyor. InputActionAsset ve InputAction kullanın." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
```

- [ ] **Step 2: check-singleton.sh yaz**

```bash
#!/bin/bash
# Blocks static singleton patterns
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Test dosyalarını atla
if [[ "$FILE_PATH" =~ [Tt]est || "$FILE_PATH" =~ [Ee]ditor ]]; then exit 0; fi

# Static Instance property veya field
if echo "$CONTENT" | grep -qE "static\s+\w+\s+Instance|private\s+static\s+\w+\s+_instance|public\s+static\s+\w+\s+Instance"; then
    echo "HOOK BLOCK [check-singleton]: Static singleton pattern tespit edildi." >&2
    echo "VContainer veya Zenject kullanarak dependency injection ile inject edin." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
```

- [ ] **Step 3: check-unity-event.sh yaz**

```bash
#!/bin/bash
# Blocks UnityEvent and UnityEvent<T> usage
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Test ve Editor dosyalarını atla
if [[ "$FILE_PATH" =~ [Tt]est || "$FILE_PATH" =~ [Ee]ditor ]]; then exit 0; fi

if echo "$CONTENT" | grep -qE "UnityEvent(<|;|\s)"; then
    echo "HOOK BLOCK [check-unity-event]: UnityEvent kullanımı yasak." >&2
    echo "Sistemler arası: IEventBus kullanın. Aynı modül içi: C# event kullanın." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
```

- [ ] **Step 4: check-coroutine.sh yaz**

```bash
#!/bin/bash
# Blocks IEnumerator and StartCoroutine (UniTask projelerinde)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

CONFIG=".claude/project-config.json"
if [[ ! -f "$CONFIG" ]]; then exit 0; fi

ASYNC_LIB=$(jq -r '.async // "unitask"' "$CONFIG")
if [[ "$ASYNC_LIB" != "unitask" ]]; then exit 0; fi

# Test ve Editor dosyalarını atla
if [[ "$FILE_PATH" =~ [Tt]est || "$FILE_PATH" =~ [Ee]ditor ]]; then exit 0; fi

if echo "$CONTENT" | grep -qE "IEnumerator|StartCoroutine|StopCoroutine|yield return"; then
    echo "HOOK BLOCK [check-coroutine]: Coroutine kullanımı yasak." >&2
    echo "Proje UniTask kullanıyor. 'async UniTask' ve 'await' kullanın." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
```

- [ ] **Step 5: Test — check-singleton.sh**

```bash
# Test: singleton pattern → exit 2 beklenir
echo '{"tool_name":"Write","tool_input":{"file_path":"Assets/Scripts/GameManager.cs","content":"public class GameManager {\n    public static GameManager Instance { get; private set; }\n}"}}' \
  | bash .claude/hooks/check-singleton.sh
echo "Exit code: $?"
```

Beklenen: exit code 2

```bash
# Test: normal sınıf → exit 0 beklenir
echo '{"tool_name":"Write","tool_input":{"file_path":"Assets/Scripts/GameManager.cs","content":"public sealed class GameManager : IGameManager {}"}}' \
  | bash .claude/hooks/check-singleton.sh
echo "Exit code: $?"
```

Beklenen: exit code 0

- [ ] **Step 6: Test — check-coroutine.sh**

```bash
# Test: StartCoroutine → exit 2 beklenir
echo '{"tool_name":"Write","tool_input":{"file_path":"Assets/Scripts/Player.cs","content":"public class Player : MonoBehaviour {\n    void Start() { StartCoroutine(MoveRoutine()); }\n    IEnumerator MoveRoutine() { yield return null; }\n}"}}' \
  | bash .claude/hooks/check-coroutine.sh
echo "Exit code: $?"
```

Beklenen: exit code 2

- [ ] **Step 7: Commit**

```bash
git add .claude/hooks/check-input-system.sh .claude/hooks/check-singleton.sh .claude/hooks/check-unity-event.sh .claude/hooks/check-coroutine.sh
git commit -m "feat: add input-system, singleton, unity-event and coroutine blocking hooks"
```

---

### Task 3: guard-config-files.sh + gateguard.sh

**Files:**
- Create: `.claude/hooks/guard-config-files.sh`
- Create: `.claude/hooks/gateguard.sh`

- [ ] **Step 1: guard-config-files.sh yaz**

```bash
#!/bin/bash
# Blocks edits to protected config files: settings.json, .asmdef, manifest.json, .inputactions
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# settings.json — her zaman koru
if [[ "$FILE_PATH" =~ settings\.json$ && "$FILE_PATH" =~ \.claude ]]; then
    echo "HOOK BLOCK [guard-config-files]: .claude/settings.json Claude tarafından edit edilemez." >&2
    echo "Hook eklemek için settings.json'u manuel düzenleyin." >&2
    exit 2
fi

# .asmdef dosyaları — test assembly'leri hariç koru
if [[ "$FILE_PATH" =~ \.asmdef$ ]]; then
    if [[ ! "$FILE_PATH" =~ [Tt]est ]]; then
        echo "HOOK BLOCK [guard-config-files]: .asmdef dosyaları korumalı." >&2
        echo "Assembly definition değişikliği için kullanıcı onayı gerekli. Manuel düzenleyin." >&2
        echo "Dosya: $FILE_PATH" >&2
        exit 2
    fi
fi

# manifest.json
if [[ "$FILE_PATH" =~ Packages/manifest\.json$ || "$FILE_PATH" =~ packages/manifest\.json$ ]]; then
    echo "HOOK BLOCK [guard-config-files]: Packages/manifest.json korumalı." >&2
    echo "Paket eklemek için Unity Package Manager'ı kullanın." >&2
    exit 2
fi

# .inputactions
if [[ "$FILE_PATH" =~ \.inputactions$ ]]; then
    echo "HOOK BLOCK [guard-config-files]: .inputactions dosyaları korumalı." >&2
    echo "Input action map değişiklikleri Unity Editor'da yapılmalı." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
```

- [ ] **Step 2: gateguard.sh yaz**

```bash
#!/bin/bash
# Blocks editing C# files that haven't been Read in the current session.
# Uses a session read-log to track which files Claude has seen.
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Sadece .cs dosyalarını kontrol et
if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Yeni dosya oluşturma (Write) her zaman izinli
if [[ "$TOOL_NAME" == "Write" ]]; then
    # Dosya yoksa yeni oluşturuluyor, izin ver
    if [[ ! -f "$FILE_PATH" ]]; then exit 0; fi
fi

SESSION_LOG=".claude/state/read-files.log"
mkdir -p ".claude/state"

# Dosya read-log'da var mı?
if [[ -f "$SESSION_LOG" ]]; then
    NORMALIZED=$(echo "$FILE_PATH" | tr '\\' '/')
    if grep -qF "$NORMALIZED" "$SESSION_LOG" 2>/dev/null; then
        exit 0
    fi
    # Basename ile de kontrol et (path farklılıklarına karşı)
    BASENAME=$(basename "$FILE_PATH")
    if grep -qF "$BASENAME" "$SESSION_LOG" 2>/dev/null; then
        exit 0
    fi
fi

echo "HOOK BLOCK [gateguard]: '$FILE_PATH' bu session'da okunmadan edit edilemez." >&2
echo "Önce dosyayı Read tool ile okuyun, sonra düzenleyin." >&2
exit 2
```

- [ ] **Step 3: Test — guard-config-files.sh**

```bash
# Test: settings.json → exit 2 beklenir
echo '{"tool_name":"Edit","tool_input":{"file_path":".claude/settings.json","old_string":"x","new_string":"y"}}' \
  | bash .claude/hooks/guard-config-files.sh
echo "Exit code: $?"
```

Beklenen: exit code 2

```bash
# Test: normal .cs dosyası → exit 0 beklenir
echo '{"tool_name":"Edit","tool_input":{"file_path":"Assets/Scripts/Player.cs","old_string":"x","new_string":"y"}}' \
  | bash .claude/hooks/guard-config-files.sh
echo "Exit code: $?"
```

Beklenen: exit code 0

- [ ] **Step 4: Commit**

```bash
git add .claude/hooks/guard-config-files.sh .claude/hooks/gateguard.sh
git commit -m "feat: add config-guard and gateguard blocking hooks"
```

---

### Task 4: Warning Hook'ları (6 script)

**Files:**
- Create: `.claude/hooks/check-linq-hotpath.sh`
- Create: `.claude/hooks/check-expensive-hotpath.sh`
- Create: `.claude/hooks/check-async-void.sh`
- Create: `.claude/hooks/check-unitask-cancellation.sh`
- Create: `.claude/hooks/check-null-propagation.sh`
- Create: `.claude/hooks/warn-serialization.sh`

- [ ] **Step 1: check-linq-hotpath.sh yaz**

```bash
#!/bin/bash
# Warns when LINQ is used inside Update/FixedUpdate/LateUpdate
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# LINQ using var mı?
if ! echo "$CONTENT" | grep -qE "using System\.Linq|\.Where\(|\.Select\(|\.ToList\(|\.FirstOrDefault\("; then
    exit 0
fi

# Update metotları içinde mi? (basit heuristic: Update bloğu sonrasında LINQ)
if echo "$CONTENT" | grep -qE "(void Update|void FixedUpdate|void LateUpdate)"; then
    echo "HOOK WARN [check-linq-hotpath]: Update/FixedUpdate/LateUpdate içinde LINQ kullanımı tespit edildi." >&2
    echo "Hot path'te GC allocation oluşturur. for/foreach döngüsüyle değiştirin." >&2
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
```

- [ ] **Step 2: check-expensive-hotpath.sh yaz**

```bash
#!/bin/bash
# Warns about GetComponent, Camera.main, Find* in hot paths
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

HAS_HOTPATH=$(echo "$CONTENT" | grep -cE "void Update|void FixedUpdate|void LateUpdate")
if [[ "$HAS_HOTPATH" -eq 0 ]]; then exit 0; fi

ISSUES=()

if echo "$CONTENT" | grep -qE "GetComponent<|GetComponent\("; then
    ISSUES+=("GetComponent — Awake'de cache'le")
fi

if echo "$CONTENT" | grep -q "Camera.main"; then
    ISSUES+=("Camera.main — field'a cache'le")
fi

if echo "$CONTENT" | grep -qE "FindObjectOfType|FindAnyObjectByType|FindObjectsOfType"; then
    ISSUES+=("Find* — Inject et veya Awake'de cache'le")
fi

if [[ ${#ISSUES[@]} -gt 0 ]]; then
    echo "HOOK WARN [check-expensive-hotpath]: Hot path'te pahalı çağrılar tespit edildi:" >&2
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue" >&2
    done
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
```

- [ ] **Step 3: check-async-void.sh yaz**

```bash
#!/bin/bash
# Warns about async void outside Unity lifecycle methods
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# async void bul — Unity lifecycle'ları hariç tut
ASYNC_VOID_LINES=$(echo "$CONTENT" | grep -nE "async void" | grep -vE "async void (Awake|Start|OnEnable|OnDisable|OnDestroy|Update|FixedUpdate|LateUpdate)")

if [[ -n "$ASYNC_VOID_LINES" ]]; then
    echo "HOOK WARN [check-async-void]: 'async void' kullanımı tespit edildi:" >&2
    echo "$ASYNC_VOID_LINES" >&2
    echo "Exception'lar yakalanmaz. 'async UniTask' kullanın veya .Forget() ile fire-and-forget yapın." >&2
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
```

- [ ] **Step 4: check-unitask-cancellation.sh yaz**

```bash
#!/bin/bash
# Warns when async UniTask methods lack CancellationToken parameter
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

CONFIG=".claude/project-config.json"
if [[ -f "$CONFIG" ]]; then
    ASYNC_LIB=$(jq -r '.async // "unitask"' "$CONFIG")
    if [[ "$ASYNC_LIB" != "unitask" ]]; then exit 0; fi
fi

# UniTask metodları bul
UNITASK_METHODS=$(echo "$CONTENT" | grep -nE "async UniTask(<\w+>)?\s+\w+\s*\(")

if [[ -z "$UNITASK_METHODS" ]]; then exit 0; fi

# CancellationToken parametresi olmayan metodları bul
MISSING=$(echo "$UNITASK_METHODS" | grep -v "CancellationToken")

if [[ -n "$MISSING" ]]; then
    echo "HOOK WARN [check-unitask-cancellation]: CancellationToken parametresi eksik UniTask metodları:" >&2
    echo "$MISSING" >&2
    echo "Her public async metoda 'CancellationToken ct' parametresi ekleyin." >&2
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
```

- [ ] **Step 5: check-null-propagation.sh yaz**

```bash
#!/bin/bash
# Warns about ?. and "is null" on Unity objects (bypasses Unity's == override)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

ISSUES=()

# ?. operatörü — Unity object'lerde tehlikeli
NULL_CONDITIONAL=$(echo "$CONTENT" | grep -nE "\?\." | grep -vE "//.*\?\.")
if [[ -n "$NULL_CONDITIONAL" ]]; then
    ISSUES+=("'?.' operatörü Unity object'lerde destroyed check'ini atlatır")
fi

# is null — Unity object'lerde == null kullanılmalı
IS_NULL=$(echo "$CONTENT" | grep -nE "\bis null\b" | grep -vE "//.*is null")
if [[ -n "$IS_NULL" ]]; then
    ISSUES+=("'is null' Unity'nin == override'ını atlatır, '== null' kullanın")
fi

if [[ ${#ISSUES[@]} -gt 0 ]]; then
    echo "HOOK WARN [check-null-propagation]: Unity object null check sorunları:" >&2
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue" >&2
    done
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
```

- [ ] **Step 6: warn-serialization.sh yaz**

```bash
#!/bin/bash
# Warns when [SerializeField] fields appear renamed without [FormerlySerializedAs]
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
OLD_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.old_string // ""')
NEW_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi
if [[ -z "$OLD_CONTENT" || -z "$NEW_CONTENT" ]]; then exit 0; fi

# Eski içerikte [SerializeField] olan private field'ları bul
OLD_FIELDS=$(echo "$OLD_CONTENT" | grep -oE "\[SerializeField\][^;]+private [a-zA-Z<>]+ (_[a-zA-Z]+)" | grep -oE "_[a-zA-Z]+$")

if [[ -z "$OLD_FIELDS" ]]; then exit 0; fi

# Yeni içerikte bu field'lar hala var mı?
while IFS= read -r field; do
    if [[ -n "$field" ]] && ! echo "$NEW_CONTENT" | grep -q "$field"; then
        # Field silindi veya rename edildi — FormerlySerializedAs var mı?
        if ! echo "$NEW_CONTENT" | grep -q "FormerlySerializedAs"; then
            echo "HOOK WARN [warn-serialization]: '[SerializeField] $field' rename edilmiş görünüyor." >&2
            echo "[FormerlySerializedAs(\"$field\")] attribute'u ekleyin — aksi halde sahne/prefab verisi kaybolur." >&2
            echo "Dosya: $FILE_PATH" >&2
        fi
    fi
done <<< "$OLD_FIELDS"

exit 0
```

- [ ] **Step 7: Test — check-async-void.sh**

```bash
# Test: async void (lifecycle dışında) → uyarı beklenir
echo '{"tool_name":"Write","tool_input":{"file_path":"Assets/Scripts/Player.cs","content":"public class Player {\n    async void OnButtonClick() { await DoSomethingAsync(); }\n}"}}' \
  | bash .claude/hooks/check-async-void.sh
echo "Exit code: $?"
```

Beklenen: stderr'de uyarı mesajı, exit code 0

```bash
# Test: async void Awake — uyarı verilmemeli
echo '{"tool_name":"Write","tool_input":{"file_path":"Assets/Scripts/Player.cs","content":"public class Player : MonoBehaviour {\n    async void Awake() { await InitAsync(); }\n}"}}' \
  | bash .claude/hooks/check-async-void.sh
echo "Exit code: $?"
```

Beklenen: exit code 0, uyarı yok

- [ ] **Step 8: Commit**

```bash
git add .claude/hooks/check-linq-hotpath.sh .claude/hooks/check-expensive-hotpath.sh \
  .claude/hooks/check-async-void.sh .claude/hooks/check-unitask-cancellation.sh \
  .claude/hooks/check-null-propagation.sh .claude/hooks/warn-serialization.sh
git commit -m "feat: add six warning hooks for hot-path, async and serialization"
```

---

### Task 5: Hook İzinleri + Verify

**Files:**
- Modify: `.claude/hooks/*.sh` (chmod)

- [ ] **Step 1: Tüm hook'ları çalıştırılabilir yap (Linux/Mac)**

```bash
chmod +x .claude/hooks/*.sh
```

Windows'ta Git Bash bu adımı otomatik halleder. PowerShell'de çalışmıyorsa:

```powershell
# Windows: git config ile otomatik chmod
git config core.fileMode false
```

- [ ] **Step 2: Tüm hook dosyaları mevcut mu?**

```bash
ls -1 .claude/hooks/*.sh | wc -l
```

Beklenen: 15

```powershell
# PowerShell alternatifi
(Get-ChildItem .claude/hooks -Filter "*.sh").Count
```

- [ ] **Step 3: Her hook'un jq bağımlılığı var mı — jq kurulu mu?**

```bash
jq --version
```

Beklenen: `jq-1.x.x` formatında versiyon. Kurulu değilse:
- Windows: `winget install jqlang.jq`
- Mac: `brew install jq`
- Linux: `sudo apt install jq`

- [ ] **Step 4: Entegrasyon testi — blocking hook settings.json koruyor mu?**

```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":".claude/settings.json","old_string":"allow","new_string":"deny"}}' \
  | bash .claude/hooks/guard-config-files.sh
echo "Exit code: $? (2 olmalı)"
```

- [ ] **Step 5: Entegrasyon testi — .cs dosyası geçiyor mu?**

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"Assets/Scripts/AudioService.cs","content":"public sealed class AudioService {}"}}' \
  | bash .claude/hooks/check-singleton.sh && \
  bash .claude/hooks/check-unity-event.sh && \
  bash .claude/hooks/check-coroutine.sh
echo "Exit code: $? (0 olmalı)"
```

- [ ] **Step 6: Final commit**

```bash
git add .claude/hooks/
git commit -m "feat: complete hooks system - 9 blocking + 6 warning guardrails"
```

---

**Phase 3 tamamlandı.** Sonraki: Phase 4 — Agents (22 agent tanım dosyası).
