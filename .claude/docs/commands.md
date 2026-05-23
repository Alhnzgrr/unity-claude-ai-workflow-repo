# Command Referansı

## Tasarım Fazı
| Command | Açıklama |
|---|---|
| `/game-idea` | Ham fikri GDD'ye dönüştürür |
| `/architect` | GDD → TDD, unity-critic ile adversarial review |
| `/plan-workflow` | TDD'yi fazlara böler → WORKFLOW.md |
| `/dry-run` | Orchestration planını önizler |

## Implementasyon Fazı
| Command | Açıklama |
|---|---|
| `/setup-project` | Detect + seçim sihirbazı, klasör yapısını oluşturur |
| `/implement <task>` | TDD pipeline: test→coder→verifier→reviewer→committer |
| `/fix <bug>` | Bug fix pipeline |
| `/fix-lite <bug>` | Hızlı yol: NullRef, typo, tek satır |
| `/fix-deep <bug>` | Evidence-first: root cause kanıtlanmadan fix yok |
| `/orchestrate` | WORKFLOW.md'yi faz faz execute eder |
| `/continue` | Kesilen /orchestrate'i devam ettirir |
| `/new-module` | 5 dosya scaffold (Interface, Service, Config, Installer, Events) |

## Kalite Fazı
| Command | Açıklama |
|---|---|
| `/qa` | Tam kalite pipeline: ralph→silent-failure-hunt→validate |
| `/ralph` | Yeşil olana kadar verify-fix loop (max 10 iterasyon) |
| `/validate` | Faz için exit criteria kontrolü |
| `/review-code` | Belirli dosyaları derinlemesine review eder |
| `/performance-audit` | Hot path allocation & draw call denetimi |

## Dokümantasyon & Öğrenme
| Command | Açıklama |
|---|---|
| `/learn` | Pattern'leri skills/learned/ altına kaydeder |
| `/catch-up` | İnsan-okunabilir codebase kılavuzu → docs/CATCH_UP.md |
| `/adr <karar>` | Architecture Decision Record oluşturur |
| `/smart-commit` | Dirty tree'yi semantic commit'lere böler |

## Session & Bağlam
| Command | Açıklama |
|---|---|
| `/context-prime` | Session başında Claude'u proje bağlamına sokar |
| `/checkpoint` | Konuşma özetini state'e kaydeder |
| `/search <sorgu>` | Codebase araştırması → action router |
| `/discover` | manifest.json tarayıp paket skill'leri üretir |
