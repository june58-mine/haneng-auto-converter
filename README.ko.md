<div align="center">

[🇺🇸 English](./README.md) · **🇰🇷 한국어**

# 한영 오타 자동 변환기

**HanEng Auto Converter**

영타/한타 오타를 <kbd>한/영</kbd> 키 1회 입력만으로 즉시 상호 변환하고, 새 프로그램 실행 시 자동으로 한글(`가`) 모드로 시작하며, 트레이 설정 UI와 업데이트 확인 기능을 제공하는 초경량 Windows 유틸리티입니다.

<p>
  <img src="https://img.shields.io/badge/version-1.0.0-19191b?style=flat-square&labelColor=0f0f10" alt="Version 1.0.0" />
  <img src="https://img.shields.io/badge/license-MIT-19191b?style=flat-square&labelColor=0f0f10" alt="MIT License" />
  <img src="https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-19191b?style=flat-square&labelColor=0f0f10" alt="Windows 10 and 11" />
  <img src="https://img.shields.io/badge/AutoHotkey-v2.0-19191b?style=flat-square&labelColor=0f0f10" alt="AutoHotkey v2.0" />
</p>

</div>

## 주요 기능

### 양방향 한영 오타 변환

- **영타 → 한글 자동 변환** (`기본값: 켜짐`): 영문 모드에서 한글을 잘못 입력했을 때(`dkssudgktpdy`) <kbd>한/영</kbd> 키를 **1번** 누르면 직전 영문을 지우고 `안녕하세요`로 변환한 뒤 한글 모드로 전환합니다.
- **한타 → 영문 자동 변환** (`기본값: 켜짐`): 한글 모드에서 영어를 잘못 입력했을 때(`ㅗ디ㅣㅐ`, `햣 ㅔㅕ노`) <kbd>한/영</kbd> 키를 **1번** 누르면 화면의 한글을 `hello`, `git push`로 되돌리고 영문 모드로 전환합니다.
- **오탐 방지 및 정밀 자모 추적**: 정상적인 영단어(`hello`, `test`, `API`, `git`, `for`, `the` 등)와 정상적인 한국어 문장은 건드리지 않고, `ㅋㅋㅋ`·`ㅎㅎ`·`ㅠㅠ`·`ㅜㅜ`·`ㅇㅇ` 같은 채팅 자모는 유지·변환합니다. 또한 Windows 두벌식 조합 및 `Backspace` 분리 규칙을 추적해 화면 글자 수에 맞춰 정확히 지우고 바꿉니다.

### 새 프로그램 실행 시 한글 자동 시작

- **새 창 한글(`가`) 초기화** (`기본값: 켜짐`): 백그라운드 폴링 없이 Windows `SetWinEventHook`(`EVENT_SYSTEM_FOREGROUND`) 이벤트로 동작하여, 새 프로그램 창이 처음 열릴 때 영문(`A`) 상태면 자동으로 한글(`가`)로 전환합니다.
- **터미널 · 코드 에디터 기본 예외 처리**: `WindowsTerminal.exe`, `cmd.exe`, `powershell.exe`, `pwsh.exe`, `Code.exe`, `Cursor.exe`, `devenv.exe`, `idea64.exe`, `pycharm64.exe`, `webstorm64.exe`, `Antigravity.exe`, `wezterm-gui.exe`, `alacritty.exe`, `mintty.exe` 등은 기본적으로 자동 한글 전환 대상에서 제외합니다.
- **수동 전환 상태 존중**: 창당 최초 1회만 동작하므로, 이미 열린 창에서 사용자가 직접 영문/한글을 바꾼 상태는 그대로 유지됩니다.

### 트레이 설정 창 & 업데이트 확인

- **트레이 메뉴 및 설정 UI**: 작업 표시줄 트레이 아이콘을 더블클릭하거나 우클릭 → **설정...** 을 열어 양방향 변환, 새 앱 한글 자동 시작, Windows 시작프로그램 등록 여부를 GUI에서 바로 켜고 끌 수 있습니다.
- **예외 앱 직접 추가/삭제**: 실행 중인 앱 목록에서 고르거나, `.exe` 파일을 찾아보거나, 프로세스 이름을 직접 입력해 예외 목록에 추가·삭제할 수 있으며 기본값 복원도 지원합니다.
- **GitHub 업데이트 확인**: 트레이 메뉴 또는 설정 창 하단의 **업데이트 확인** 버튼을 누르면 `june58-mine/haneng-auto-converter`의 최신 릴리스 버전을 확인하고 새 버전이 있을 경우 다운로드 페이지로 바로 이동합니다.

## 설치 방법

1. 최신 릴리스에서 단독 실행 파일(`HanEngConverter.exe`)을 내려받습니다:

   <p>
     <a href="https://github.com/june58-mine/haneng-auto-converter/releases/latest/download/HanEngConverter.exe">
       <img src="https://img.shields.io/badge/Download_HanEngConverter.exe-v1.0.0-e5484d?style=for-the-badge&logo=windows&logoColor=white" alt="Download HanEngConverter.exe v1.0.0" />
     </a>
   </p>

2. 내려받은 `HanEngConverter.exe`를 실행합니다.
3. 부팅 시 자동 실행하려면 트레이 아이콘 우클릭 → **설정...** → **Windows 시작 시 자동 실행**을 체크하고 저장하세요.

> **참고 (Windows SmartScreen):** 코드 서명이 없는 오픈소스 빌드이므로 처음 실행 시 Windows Defender SmartScreen 경고가 표시될 수 있습니다. **추가 정보 → 실행**을 눌러 실행하세요.

<details>
<summary>소스(.ahk)로 직접 실행 및 .exe 수동 빌드 안내</summary>

1. [AutoHotkey v2.0+](https://www.autohotkey.com/)을 설치한 뒤 [`haneng_converter.ahk`](./haneng_converter.ahk)를 바로 실행할 수 있습니다. (단위 테스트는 [`tests/test_converter.ahk`](./tests/test_converter.ahk)에서 확인할 수 있습니다.)
2. `Ahk2Exe`로 `.exe`를 직접 빌드하려면 다음 명령을 실행하세요:
   ```powershell
   Ahk2Exe.exe /in haneng_converter.ahk /out dist\HanEngConverter.exe /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
   ```

</details>

## 변환 예시 및 제어 방법

### 변환 동작 예시

| 방향 | 입력한 내용 | <kbd>한/영</kbd> 1회 입력 후 | 동작 설명 |
| --- | --- | --- | --- |
| 영문 → 한글 | `dkssudgktpdy` | `안녕하세요` | 한글로 변환 후 한글 모드 전환 |
| 영문 → 한글 | `dkssud gktpdy` | `안녕 하세요` | 띄어쓰기가 포함된 구문 변환 |
| 영문 → 한글 | `zzz` | `ㅋㅋㅋ` | 반복 채팅 자모 변환 |
| 한글 → 영문 | `ㅗ디ㅣㅐ` | `hello` | 영문으로 변환 후 영문 모드 전환 |
| 한글 → 영문 | `햣 ㅔㅕ노` | `git push` | 영타 실수 문장 변환 |
| 한글 → 영문 | `ㅗㅅ센://해ㅐ힏.ㅊㅐㅡ` | `https://google.com` | URL/식별자 오타 변환 |
| 변환 안 함 | `hello`(영문) / `안녕하세요` / `ㅋㅋㅋ` | *(그대로 유지)* | 단순 한/영 모드 전환만 수행 |

### 트레이 메뉴

| 메뉴 항목 | 설명 |
| --- | --- |
| **설정...** *(더블클릭)* | 기능 토글, 시작프로그램 등록, 예외 앱 편집 창 열기 |
| **업데이트 확인...** | GitHub Releases 최신 버전 확인 |
| **자동 변환 활성화** | 전체 오타 변환 및 자동 전환 일시정지/재개 |
| **새 앱 한글 자동 시작** | 새 프로그램 실행 시 한글 자동 전환 빠른 토글 |
| **버퍼 초기화** | 현재 누적된 입력 버퍼 수동 비우기 |
| **종료** | 프로그램 종료 |

## 기술 및 호환 참고

- **초경량 백그라운드 리소스**: 이벤트 기반 AutoHotkey v2 훅(`InputHook` + `SetWinEventHook`)으로만 동작하여 대기 중 CPU 점유율이 사실상 `0%`이며, Windows 11 x64 실측 기준 메모리 사용량은 **Private 약 4.17 MB / Working Set 약 16.28 MB**입니다.
- **클립보드 미사용**: `SendText`(Unicode 입력)를 사용하므로 시스템 클립보드와 `Win + V` 클립보드 기록을 건드리지 않습니다.
- **설정 저장 위치**: 사용자 설정과 예외 앱 목록은 `%APPDATA%\HanEngAutoConverter\settings.ini`에 저장됩니다.
- **키보드 드라이버 및 권한 제한**: 표준 한국어 두벌식(`vk15` / `kbd101a.dll`) 기준으로 동작합니다. Windows 보안 정책(UIPI)상 일반 권한으로 실행 시 관리자 권한 창에는 키 전송 및 IME 조회가 제한될 수 있으며, 일부 최신 WinUI3/UWP 앱은 레거시 `WM_IME_CONTROL` 메시지를 무시할 수 있습니다.

## 라이선스

[MIT License](./LICENSE)를 따릅니다.
