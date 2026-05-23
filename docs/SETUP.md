# Kurulum Kılavuzu

## 1. .claude/ Klasörünü Kopyala

**Mac/Linux:**
```bash
cp -r unity-claude-ai-workflow-repo/.claude/ YourUnityProject/.claude/
```

**Windows:**
```powershell
Copy-Item -Recurse unity-claude-ai-workflow-repo\.claude\ YourUnityProject\.claude\
```

## 2. Git Bash Kurulu Olduğundan Emin Ol

Hook'lar bash script'leri. Windows'ta Git Bash gerekli.
İndir: https://git-scm.com/download/win

## 3. Hook İzinlerini Ver (Linux/Mac)

```bash
chmod +x YourUnityProject/.claude/hooks/*.sh
```

## 4. Claude Code'u Aç

Unity proje root dizininde Claude Code'u başlat.

## 5. Setup Sihirbazını Çalıştır

```
/setup-project
```

Bu komut:
- `manifest.json` tarayıp VContainer/Zenject, UniTask tespit eder
- Input sistemini tespit eder
- ECS, Addressables, XR opsiyonlarını sorar
- `.claude/project-config.json` doldurur
- Önerilen klasör yapısını oluşturur

## Doğrulama

```
/context-prime
```

Claude projeyi tanımlıyorsa kurulum tamamdır.

## Sorun Giderme

**Hook'lar çalışmıyor:** `jq` kurulu mu? `jq --version` ile kontrol et.
- Windows: `winget install jqlang.jq`
- Mac: `brew install jq`

**settings.json izin hatası:** Bu dosya Claude tarafından düzenlenemez, tasarım gereği.
