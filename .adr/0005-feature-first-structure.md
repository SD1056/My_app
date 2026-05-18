# ADR-0005: Feature-first 폴더 구조 채택

- **상태**: Accepted
- **결정일**: 2026-05-18

---

## 맥락

Flutter 프로젝트의 `lib/` 폴더를 어떻게 구성할지 결정해야 했다.
크게 두 가지 방식이 있다:
- **Layer-first**: `data/`, `domain/`, `presentation/` 최상위 분리
- **Feature-first**: `record/`, `suggestion/`, `stats/` 등 기능별 최상위 분리

## 결정

**Feature-first** 구조를 채택한다.
각 기능 폴더 내부에서 `data/`, `domain/`, `presentation/`으로 레이어를 나눈다.

```
features/
├── record/
│   ├── data/        ← RecordDao
│   ├── domain/      ← Record 모델
│   └── presentation/← HomeScreen, RecordProvider
├── suggestion/
│   └── presentation/← SuggestionCard, SuggestionProvider
└── stats/
    └── presentation/← StatsScreen
```

## 근거

- 기능 단위로 파일을 찾는 것이 레이어 단위보다 직관적
- 새 기능 추가 시 해당 폴더만 건드리면 됨 (다른 기능에 영향 없음)
- 기능 단위로 삭제·리팩토링이 쉬움
- 1인 개발 환경에서 파일 탐색 효율 높음

## 대안

| 대안 | 제외 이유 |
|------|-----------|
| Layer-first | 관련 파일이 여러 폴더에 분산되어 기능 파악 시 파일 이동이 많음 |
| 단일 flat 구조 | 파일 수가 늘면 관리 불가 |

## 결과

**긍정적:**
- 기능별 응집도 높음
- 새 기능(예: `habit/`) 추가 시 기존 코드에 최소 영향

**부정적:**
- 레이어 간 공통 코드는 `core/`, `shared/`에 별도 관리 필요
- 팀 개발 시 컨벤션 명시가 필요
