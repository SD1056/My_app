# ADR-0001: 크로스플랫폼 프레임워크로 Flutter 선택

- **상태**: Accepted
- **결정일**: 2026-05-18

---

## 맥락

iOS와 Android를 동시에 지원해야 하는 B2C 모바일 앱을 1인이 개발한다.
플랫폼별 네이티브 개발(Swift + Kotlin)은 두 배의 공수가 필요하고,
크로스플랫폼 프레임워크 중 하나를 선택해야 했다.

## 결정

**Flutter(Dart)** 를 선택한다.

## 근거

- 단일 코드베이스로 iOS / Android 동시 빌드 가능
- Hot reload로 UI 개발 속도가 빠름
- `sqflite`, `flutter_riverpod`, `fl_chart` 등 필요한 패키지 생태계가 충분히 성숙
- 1인 개발에서 두 플랫폼 코드를 동기화하는 부담 제거

## 대안

| 대안 | 제외 이유 |
|------|-----------|
| React Native | JS/TS 기반이라 웹 개발자에게 친숙하나, 네이티브 브리지 레이어로 인한 성능 이슈 우려 |
| Swift (iOS 전용) | iOS 전용으로 Android 사용자 제외됨 |
| Kotlin Multiplatform | UI 공유가 아직 실험적, 러닝커브 높음 |

## 결과

**긍정적:**
- iOS / Android를 단일 Dart 코드베이스로 관리
- `flutter analyze` + GitHub Actions로 품질 자동화

**부정적:**
- Dart 언어에 대한 초기 학습 필요
- 플랫폼별 세밀한 UI 조정 시 플랫폼 채널 코드 필요
