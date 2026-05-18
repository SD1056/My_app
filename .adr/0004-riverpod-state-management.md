# ADR-0004: 상태 관리로 Riverpod 선택

- **상태**: Accepted
- **결정일**: 2026-05-18

---

## 맥락

Flutter 앱에서 비동기 데이터(SQLite, AI API)를 여러 화면에 걸쳐 공유하고
UI를 반응적으로 업데이트하는 상태 관리 솔루션이 필요했다.

## 결정

**flutter_riverpod 2.x** 를 사용한다.
`AsyncNotifierProvider`로 비동기 상태를, `FutureProvider.autoDispose`로 일회성 비동기 작업을 처리한다.

## 근거

- `AsyncNotifierProvider`가 SQLite CRUD의 로딩/에러/데이터 상태를 간결하게 표현
- `autoDispose`로 사용하지 않는 AI 제안 요청을 자동 정리 (메모리 절약)
- Provider 간 의존성 선언이 명시적이어서 코드 추적이 쉬움
- `ref.invalidateSelf()`로 기록 추가/삭제 후 리스트를 단순하게 갱신 가능

## 현재 Provider 구조

```
recordDaoProvider (Provider)
    └── recordListProvider (AsyncNotifierProvider)
            └── suggestionProvider (FutureProvider.autoDispose)
                    └── aiEnabledProvider (StateNotifierProvider)
```

## 대안

| 대안 | 제외 이유 |
|------|-----------|
| Provider (구버전) | Riverpod의 전신, 타입 안전성 낮고 더 이상 권장되지 않음 |
| BLoC / Cubit | 보일러플레이트 많음, 단순 앱에 과도한 구조 |
| GetX | 과도한 전역 상태, 테스트 어려움 |
| setState만 사용 | 화면 간 상태 공유 불가, 비동기 처리 직접 관리해야 함 |

## 결과

**긍정적:**
- 비동기 상태의 loading / error / data 분기 처리가 `.when()` 한 줄로 해결
- 화면 간 상태 공유 자연스럽게 처리
- 컴파일 타임 타입 안전성

**부정적:**
- Provider 개념 학습 필요
- `riverpod_generator` 코드 생성 도구를 쓰면 더 편하지만 현재 미사용 (단순 선언형으로 충분)
