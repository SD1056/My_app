# Myapp

> AI가 패턴을 학습해서 데이터 입력을 자동화하는 모바일 앱

지출, 운동, 식단 등 매일 반복되는 기록을 AI가 대신 제안해주는 Flutter 앱입니다.
사용자는 확인 한 번으로 기록을 완료할 수 있습니다.

---

## 🎬 발표 자료 (2분)

**GitHub Pages를 통해 PC에서 즉시 재생 가능합니다:**

| 자료 | 설명 | 링크 |
|------|------|------|
| 📊 **발표 슬라이드** | 비전, 기능, 아키텍처, OKR (2분 타이머 내장) | [🔗 보러 가기](https://sd1056.github.io/My_app/) |
| 📈 **WBS & 로드맵** | 프로젝트 계층도, 마일스톤, Gantt 차트 | [🔗 보러 가기](https://sd1056.github.io/My_app/wbs.html) |

> ⏱️ **발표 팁:** 슬라이드에 2분 타이머가 내장되어 있습니다. 스마트폰 타이머 앱을 함께 사용하세요!

---

## 목차

1. [주요 기능](#주요-기능)
2. [기술 스택](#기술-스택)
3. [개발 도구](#개발-도구)
4. [아키텍처](#아키텍처)
5. [프로젝트 구조](#프로젝트-구조)
6. [화면 구성](#화면-구성)
7. [시작하기](#시작하기)
8. [AI 기능 활성화](#ai-기능-활성화)
9. [기획 문서](#기획-문서)

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| 📝 수동 기록 | 5가지 카테고리(지출/운동/식단/수면/메모)로 빠른 데이터 입력 |
| 🤖 AI 자동 제안 | 과거 30일 패턴을 분석해 Claude AI가 다음 기록을 먼저 제안 |
| ✅ 원탭 수락 | 제안이 맞으면 수락 버튼 하나로 기록 완료 |
| 📊 통계 | 주간·월간 지출 차트 및 카테고리별 분석 |
| 🗂️ 히스토리 | 날짜별 전체 기록 조회 및 수정·삭제 |
| ⚙️ 설정 | AI 제안 ON/OFF, API 키 관리 |

---

## 기술 스택

### 프레임워크

| 항목 | 선택 | 버전 |
|------|------|------|
| 모바일 프레임워크 | Flutter | 3.41.9 |
| 언어 | Dart | 3.11.5 |
| 지원 플랫폼 | iOS / Android | - |

### 주요 패키지

| 패키지 | 용도 | 버전 |
|--------|------|------|
| `flutter_riverpod` | 상태 관리 | ^2.5.1 |
| `sqflite` | 로컬 SQLite DB | ^2.3.3 |
| `dio` | HTTP 클라이언트 (Claude API) | ^5.7.0 |
| `flutter_secure_storage` | API 키 암호화 저장 | ^9.2.2 |
| `fl_chart` | 통계 차트 | ^0.68.0 |
| `shared_preferences` | 앱 설정 저장 | ^2.3.2 |
| `intl` | 날짜·숫자 포맷 (한국어) | ^0.19.0 |
| `path` | 파일 경로 유틸 | ^1.9.0 |

### AI

| 항목 | 내용 |
|------|------|
| 모델 | Claude Sonnet 4.6 (`claude-sonnet-4-6`) |
| API | Anthropic Messages API |
| 호출 방식 | 온디맨드 (+ 버튼 탭 시) |
| 데이터 전송 | 개인정보 제거된 패턴 요약 텍스트만 전송 |

### 데이터 저장

| 데이터 | 저장소 |
|--------|--------|
| 기록 데이터 | 기기 내 SQLite |
| API 키 | 기기 내 Keychain/Keystore (flutter_secure_storage) |
| 앱 설정 | 기기 내 SharedPreferences |

---

## 개발 도구

| 도구 | 용도 |
|------|------|
| **Flutter SDK 3.41.9** | 크로스플랫폼 앱 빌드 |
| **Dart 3.11.5** | 프로그래밍 언어 |
| **Git** | 버전 관리 |
| **GitHub** | 원격 저장소, 코드 리뷰 |
| **GitHub Actions** | CI (자동 분석 + 테스트) |
| **GitHub CLI (`gh`)** | 레포 생성·관리 |
| **Claude Code** | AI 보조 개발 |
| **VS Code / Android Studio** | 코드 에디터 (선택) |

### CI/CD

`.github/workflows/flutter_ci.yml`에 정의된 GitHub Actions 파이프라인:

```
push / PR → flutter pub get → flutter analyze → flutter test
```

---

## 아키텍처

### 레이어 구조

```
┌──────────────────────────────────────┐
│           Presentation Layer          │
│  Flutter Widgets + Riverpod Providers │
├──────────────────────────────────────┤
│            Business Logic             │
│     Notifiers / Pattern Analyzer      │
├───────────────────┬──────────────────┤
│   Local Storage   │   Remote (AI)     │
│  SQLite (sqflite) │  Claude API (dio) │
└───────────────────┴──────────────────┘
```

### 데이터 흐름

```
사용자 [+] 탭
     │
     ▼
PatternAnalyzer
(로컬 30일 기록 분석)
     │ 패턴 요약 텍스트
     ▼
Claude API 호출
     │ JSON 제안 수신
     ▼
SuggestionCard 표시
     │
     ├─ 수락  → SQLite 저장 (source: ai_accepted)
     ├─ 수정  → 폼 프리필 후 저장 (source: ai_modified)
     └─ 건너뜀 → 수동 입력 폼 표시
```

### 상태 관리 (Riverpod)

| Provider | 타입 | 역할 |
|----------|------|------|
| `recordListProvider` | `AsyncNotifierProvider` | 전체 기록 목록 (CRUD) |
| `suggestionProvider` | `FutureProvider.autoDispose` | AI 제안 fetch |
| `aiEnabledProvider` | `StateNotifierProvider` | AI 토글 ON/OFF |
| `aiServiceProvider` | `Provider` | AiService 싱글톤 |

---

## 프로젝트 구조

```
Myapp/
├── .github/
│   └── workflows/
│       └── flutter_ci.yml       # GitHub Actions CI
├── .planning/                   # 기획 문서
│   ├── 00-vision.md
│   ├── 01-requirements.md
│   ├── 02-architecture.md
│   ├── 03-ux-flow.md
│   └── 04-roadmap.md
├── lib/
│   ├── main.dart                # 진입점, 온보딩 분기
│   ├── core/
│   │   ├── database/
│   │   │   └── database_helper.dart   # SQLite 초기화 & 마이그레이션
│   │   └── ai/
│   │       ├── ai_service.dart        # Claude API 클라이언트
│   │       └── pattern_analyzer.dart  # 패턴 추출 알고리즘
│   ├── features/
│   │   ├── record/              # 기록 기능 (M1)
│   │   │   ├── domain/
│   │   │   │   └── record.dart        # Record 모델, 카테고리 상수
│   │   │   ├── data/
│   │   │   │   └── record_dao.dart    # SQLite CRUD
│   │   │   └── presentation/
│   │   │       ├── record_provider.dart   # Riverpod Notifier
│   │   │       ├── add_record_sheet.dart  # 기록 입력 Bottom Sheet
│   │   │       └── home_screen.dart       # 홈 화면
│   │   ├── suggestion/          # AI 제안 기능 (M2)
│   │   │   └── presentation/
│   │   │       ├── suggestion_provider.dart
│   │   │       └── suggestion_card.dart
│   │   ├── history/             # 히스토리 화면
│   │   │   └── presentation/
│   │   │       └── history_screen.dart
│   │   ├── stats/               # 통계 화면 (M3)
│   │   │   └── presentation/
│   │   │       └── stats_screen.dart
│   │   ├── onboarding/          # 온보딩 (M3)
│   │   │   └── presentation/
│   │   │       └── onboarding_screen.dart
│   │   └── settings/            # 설정 화면
│   │       └── presentation/
│   │           └── settings_screen.dart
│   └── shared/
│       ├── theme/
│       │   └── app_theme.dart   # Material3 테마
│       └── widgets/
│           └── app_shell.dart   # 하단 탭바 네비게이션
├── android/                     # Android 플랫폼 코드
├── ios/                         # iOS 플랫폼 코드
├── PROGRESS.md                  # 개발 진행 상태
└── pubspec.yaml                 # 의존성 정의
```

---

## 화면 구성

| 화면 | 진입 | 주요 내용 |
|------|------|-----------|
| 온보딩 | 최초 실행 1회 | 3장 슬라이드, 스킵 가능 |
| 홈 | 탭바 🏠 | 오늘 요약 카드 + 기록 목록 + FAB |
| 기록 입력 | FAB(+) | AI 제안 카드 → 수락/수정/건너뜀 → 수동 입력 |
| 히스토리 | 탭바 📝 | 전체 기록 날짜별 그룹 |
| 통계 | 탭바 📊 | 주간/월간 지출 차트 + 카테고리 분석 |
| 설정 | 탭바 ⚙️ | AI 토글, API 키 관리 |

---

## 시작하기

### 요구사항

- Flutter 3.41.9 이상
- Dart 3.11.5 이상
- Android Studio 또는 Xcode (에뮬레이터용)

### 설치 및 실행

```bash
# 1. 레포 클론
git clone https://github.com/SD1056/My_app.git
cd My_app

# 2. 패키지 설치
flutter pub get

# 3. 실행 (에뮬레이터 또는 실기기 연결 후)
flutter run

# 4. 빌드 체크
flutter analyze
flutter test
```

---

## AI 기능 활성화

1. [Anthropic Console](https://console.anthropic.com)에서 API 키 발급
2. 앱 실행 → **설정 탭** → **Claude API 키** 탭
3. `sk-ant-...` 형식의 키 입력 후 저장
4. AI 자동 제안 ON 상태에서 **3일 이상 기록** 후 제안 활성화

> AI 제안은 동일 시간대(±2시간) 기록이 3개 이상 쌓여야 작동합니다.

---

## 기획 문서

| 문서 | 내용 |
|------|------|
| [00-vision.md](.planning/00-vision.md) | 비전, 문제 정의, OKR |
| [01-requirements.md](.planning/01-requirements.md) | 사용자 시나리오 3개, MoSCoW 기능 분류 |
| [02-architecture.md](.planning/02-architecture.md) | 기술 스택, 시스템 구성도, DB 스키마 |
| [03-ux-flow.md](.planning/03-ux-flow.md) | 화면 설계, 사용자 플로우 |
| [04-roadmap.md](.planning/04-roadmap.md) | 7주 로드맵, 마일스톤, 리스크 |

---

## Architecture Decision Records (ADR)

주요 기술 결정과 그 근거를 기록합니다. → [전체 목록](.adr/0000-index.md)

| 번호 | 제목 | 상태 |
|------|------|------|
| [ADR-0001](.adr/0001-flutter-cross-platform.md) | 크로스플랫폼 프레임워크로 Flutter 선택 | Accepted |
| [ADR-0002](.adr/0002-local-sqlite-no-backend.md) | 서버 없이 SQLite 온디바이스 저장 | Accepted |
| [ADR-0003](.adr/0003-claude-api-cloud-ai.md) | 온디바이스 ML 대신 Claude API 사용 | Accepted |
| [ADR-0004](.adr/0004-riverpod-state-management.md) | 상태 관리로 Riverpod 선택 | Accepted |
| [ADR-0005](.adr/0005-feature-first-structure.md) | Feature-first 폴더 구조 채택 | Accepted |
| [ADR-0006](.adr/0006-on-demand-ai-suggestion.md) | AI 제안을 온디맨드(+ 버튼 탭 시)로 호출 | Accepted |

---

## 개발 현황

| 마일스톤 | 상태 | 완료일 |
|---------|------|--------|
| M0 프로젝트 셋업 | ✅ 완료 | 2026-05-18 |
| M1 수동 기록 | ✅ 완료 | 2026-05-18 |
| M2 AI 제안 | ✅ 완료 | 2026-05-18 |
| M3 완성도 & 베타 | ✅ 완료 | 2026-05-18 |
| M4 출시 준비 | 🔜 예정 | 2026-07-20 |
