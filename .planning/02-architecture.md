# 기술 스택 & 아키텍처

## 기술 스택 요약

| 레이어 | 선택 | 이유 |
|--------|------|------|
| 모바일 프레임워크 | Flutter (Dart) | iOS/Android 동시 지원, 단일 코드베이스 |
| 로컬 DB | SQLite (`sqflite`) | 서버 없이 온디바이스 저장, 개인정보 보호 |
| AI 제안 엔진 | Claude API (Anthropic) | 패턴 기반 자연어 제안 생성 |
| 상태 관리 | Riverpod | Flutter 생태계 표준, 테스트 용이 |
| HTTP 클라이언트 | `dio` | 인터셉터, 재시도, 타임아웃 처리 |

---

## 시스템 구성도

```
┌─────────────────────────────────────────┐
│              Flutter App                │
│                                         │
│  ┌─────────────┐    ┌─────────────────┐ │
│  │  UI Layer   │    │  Business Logic  │ │
│  │ (Widgets)   │◄──►│  (Riverpod)     │ │
│  └─────────────┘    └────────┬────────┘ │
│                              │          │
│              ┌───────────────┼──────┐   │
│              ▼               ▼      │   │
│  ┌──────────────┐  ┌──────────────┐ │   │
│  │  SQLite DB   │  │  AI Service  │ │   │
│  │  (로컬 저장)  │  │  (HTTP 호출) │ │   │
│  └──────────────┘  └──────┬───────┘ │   │
│                           │         │   │
└───────────────────────────┼─────────┘   │
                            ▼             │
                   ┌─────────────────┐    │
                   │   Claude API    │    │
                   │  (Anthropic)    │    │
                   └─────────────────┘    │
```

---

## 레이어별 상세

### 1. UI Layer — Flutter Widgets
- 화면별 Widget 트리
- 사용자 입력 → Riverpod Provider에 이벤트 전달
- AI 제안 카드 컴포넌트 (수락 / 수정 / 거절 버튼 포함)

### 2. Business Logic — Riverpod Providers
- `RecordNotifier`: 데이터 입력 / 수정 / 삭제 처리
- `SuggestionNotifier`: AI 제안 요청 및 상태 관리
- `PatternAnalyzer`: 로컬 데이터에서 빈도·시간 패턴 추출

### 3. Data Layer

#### 로컬 저장 (SQLite)
```
records
  id          INTEGER PRIMARY KEY
  category    TEXT           -- 지출, 운동, 식단 등
  value       TEXT           -- 입력값 (JSON)
  recorded_at DATETIME
  source      TEXT           -- 'manual' | 'ai_accepted' | 'ai_modified'

patterns
  id          INTEGER PRIMARY KEY
  category    TEXT
  summary     TEXT           -- 패턴 요약 (AI 전송용)
  updated_at  DATETIME
```

#### AI 서비스 (Claude API)
- 로컬 패턴 요약을 컨텍스트로 전달
- 개인 식별 정보 제거 후 전송
- 요청 예시:
  ```
  최근 30일 기록 패턴: 매일 오전 9시 커피 4,500원, 주 4회 저녁 운동
  오늘 오전 9시 10분에 앱을 열었습니다.
  → 다음 기록을 제안해주세요.
  ```

---

## 데이터 흐름

```
사용자 입력
    │
    ▼
SQLite 저장
    │
    ▼
PatternAnalyzer (로컬 분석)
    │  빈도 / 시간대 / 카테고리 패턴 추출
    ▼
Claude API 호출 (비동기)
    │  패턴 요약 전송 → 제안 수신
    ▼
SuggestionCard 표시
    │
    ├─ 수락 → SQLite 저장 (source: ai_accepted)
    ├─ 수정 → SQLite 저장 (source: ai_modified)
    └─ 거절 → 패턴에 부정 피드백 반영
```

---

## 프로젝트 구조 (Flutter)

```
lib/
├── main.dart
├── core/
│   ├── database/        # SQLite 초기화, 마이그레이션
│   ├── ai/              # Claude API 클라이언트
│   └── utils/
├── features/
│   ├── record/          # 데이터 입력 기능
│   │   ├── data/        # Repository, DAO
│   │   ├── domain/      # 모델, 인터페이스
│   │   └── presentation/# 화면, 위젯, Provider
│   ├── suggestion/      # AI 제안 기능
│   └── history/         # 기록 조회 기능
└── shared/
    ├── widgets/
    └── theme/
```

---

## 주요 기술적 결정 사항

| 결정 | 선택 | 대안 | 이유 |
|------|------|------|------|
| 서버 없음 | SQLite 온디바이스 | Firebase | MVP 단순화, 개인정보 보호 |
| AI 온디맨드 호출 | 앱 실행 시 비동기 | 백그라운드 주기 실행 | 배터리 절약, 비용 절감 |
| 패턴 전송 방식 | 요약 텍스트만 전송 | 원본 데이터 전송 | 개인정보 최소화 |

---

## 외부 의존성

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `sqflite` | ^2.3 | SQLite ORM |
| `riverpod` | ^2.5 | 상태 관리 |
| `dio` | ^5.4 | HTTP 클라이언트 |
| `flutter_secure_storage` | ^9.0 | API 키 안전 저장 |
| `intl` | ^0.19 | 날짜/시간 포맷 |
