# Architecture Decision Records

이 디렉토리는 프로젝트의 주요 아키텍처 결정을 기록합니다.

## 형식

각 ADR은 다음 구조를 따릅니다:
- **상태**: Accepted / Deprecated / Superseded
- **맥락**: 왜 이 결정이 필요했는가
- **결정**: 무엇을 선택했는가
- **대안**: 검토했지만 선택하지 않은 것들
- **결과**: 이 결정이 가져오는 트레이드오프

## 목록

| 번호 | 제목 | 상태 |
|------|------|------|
| [ADR-0001](0001-flutter-cross-platform.md) | 크로스플랫폼 프레임워크로 Flutter 선택 | Accepted |
| [ADR-0002](0002-local-sqlite-no-backend.md) | 서버 없이 SQLite 온디바이스 저장 | Accepted |
| [ADR-0003](0003-claude-api-cloud-ai.md) | 온디바이스 ML 대신 Claude API 사용 | Accepted |
| [ADR-0004](0004-riverpod-state-management.md) | 상태 관리로 Riverpod 선택 | Accepted |
| [ADR-0005](0005-feature-first-structure.md) | Feature-first 폴더 구조 채택 | Accepted |
| [ADR-0006](0006-on-demand-ai-suggestion.md) | AI 제안을 온디맨드(탭 시)로 호출 | Accepted |
