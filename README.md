<div align="center">

# 한영 오타 자동 변환기

**HanEng Auto Converter**

한/영 키를 잘못 눌러 오타가 났을 때 <kbd>한/영</kbd> 키 한 번으로 바로 고쳐 주고, 새 프로그램을 켤 때 자동으로 한글로 시작하게 해 주는 **초경량 Windows 유틸리티**입니다.

<p>
  <img src="https://img.shields.io/badge/version-1.0.0-19191b?style=flat-square&labelColor=0f0f10" alt="Version 1.0.0" />
  <img src="https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-19191b?style=flat-square&labelColor=0f0f10" alt="Windows 10 and 11" />
  <img src="https://img.shields.io/badge/RAM-~4%20MB-19191b?style=flat-square&labelColor=0f0f10" alt="RAM ~4 MB" />
  <img src="https://img.shields.io/badge/CPU-0%25%20idle-19191b?style=flat-square&labelColor=0f0f10" alt="CPU 0% idle" />
  <img src="https://img.shields.io/badge/license-MIT-19191b?style=flat-square&labelColor=0f0f10" alt="MIT License" />
</p>

<p>
  <a href="https://github.com/june58-mine/haneng-auto-converter/releases/latest/download/HanEngConverter.exe">
    <img src="https://img.shields.io/badge/Download_HanEngConverter.exe-v1.0.0-e5484d?style=for-the-badge&logo=windows&logoColor=white" alt="Download HanEngConverter.exe v1.0.0" />
  </a>
</p>

</div>

## 왜 가볍고 편할까요?

- **메모리 약 4 MB · 대기 시 CPU 0%**: 무거운 사전이나 상시 감시 루프 없이 동작해 백그라운드에서 켜 두어도 PC 성능에 부담을 주지 않습니다.
- **설치·의존성 없음**: AutoHotkey나 별도 런타임 없이 `HanEngConverter.exe` 파일 하나(`~1.2 MB`)만 받아 실행하면 바로 동작합니다.
- **클립보드 보존**: 복사해 둔 내용이나 `Win + V` 클립보드 기록을 건드리지 않고 글자만 깔끔하게 바꿔 줍니다.

---

## 주요 기능

### 1. 한/영 키 한 번으로 영타 ↔ 한타 오타 즉시 수정 (`기본값: 켜짐`)

- 영어로 잘못 친 한글(`dkssudgktpdy`)이나 한글로 잘못 친 영어(`ㅗ디ㅣㅐ`)를 지우고 다시 입력할 필요 없이, <kbd>한/영</kbd> 키를 **한 번**만 누르면 올바른 글자로 바꾸고 입력 모드까지 함께 전환해 줍니다.
- 정상적으로 입력한 영어 단어(`hello`, `git`, `test` 등)나 한국어 문장(`안녕하세요`, `ㅋㅋㅋ` 등)은 건드리지 않고 입력 모드만 바꿉니다.

### 2. 새 프로그램을 켤 때 자동으로 한글(`가`)로 시작 (`기본값: 켜짐`)

- Windows에서 메모장이나 브라우저 같은 새 창을 열 때마다 입력 상태가 영어로 초기화되는 불편함을 없애고, 창이 처음 열릴 때 자동으로 한글 모드로 맞춰 줍니다.
- 터미널이나 코드 에디터처럼 영어를 주로 쓰는 앱은 기본적으로 제외되어 있으며, 이미 열린 창에서 사용자가 직접 바꾼 한/영 상태는 그대로 유지됩니다.

### 3. 작업 표시줄 트레이 설정 & 업데이트 확인

- 작업 표시줄 오른쪽 트레이 아이콘을 더블클릭하거나 우클릭 → **설정...** 을 열면 기능별 켜기/끄기, **Windows 시작 시 자동 실행**, 한글 자동 시작 예외 앱 추가·삭제를 GUI에서 바로 바꿀 수 있습니다.
- 트레이 메뉴나 설정 창의 **업데이트 확인** 버튼으로 새 버전 출시 여부를 확인하고 다운로드 페이지로 바로 이동할 수 있습니다.

---

## 변환 예시

| 입력한 내용 | <kbd>한/영</kbd> 1회 입력 후 | 설명 |
| --- | --- | --- |
| `dkssudgktpdy` | `안녕하세요` | 영문 오타를 한글로 변환하고 한글 모드로 전환 |
| `dkssud gktpdy` | `안녕 하세요` | 띄어쓰기가 포함된 구문 변환 |
| `zzz` | `ㅋㅋㅋ` | 반복 채팅 자모 변환 |
| `ㅗ디ㅣㅐ` | `hello` | 한글 오타를 영문으로 변환하고 영문 모드로 전환 |
| `햣 ㅔㅕ노` | `git push` | 한글 상태로 잘못 친 영문 구문 변환 |
| `ㅗㅅ센://해ㅐ힏.ㅊㅐㅡ` | `https://google.com` | URL이나 파일명 오타 변환 |
| `hello`(영문) / `안녕하세요` / `ㅋㅋㅋ` | *(그대로 유지)* | 정상 입력은 건드리지 않고 한/영 전환만 수행 |

---

## 설치 및 사용법

1. 상단의 **Download HanEngConverter.exe** 버튼을 눌러 파일을 내려받습니다.
2. 내려받은 `HanEngConverter.exe`를 실행합니다.
3. 부팅할 때 자동으로 실행하려면 트레이 아이콘 우클릭 → **설정...** → **Windows 시작 시 자동 실행**을 체크하고 저장하세요.

> [!NOTE]
> **Windows SmartScreen 안내:** 코드 서명이 없는 오픈소스 빌드이므로 처음 실행 시 Windows Defender SmartScreen 경고가 표시될 수 있습니다. **추가 정보 → 실행**을 눌러 실행하세요.

### 트레이 메뉴

| 메뉴 항목 | 설명 |
| --- | --- |
| **설정...** *(더블클릭)* | 기능 켜기/끄기, 시작프로그램 등록, 예외 앱 편집 창 열기 |
| **업데이트 확인...** | GitHub Releases에서 최신 버전 확인 |
| **자동 변환 활성화** | 전체 오타 변환 및 자동 전환 일시정지/재개 |
| **새 앱 한글 자동 시작** | 새 프로그램 실행 시 한글 자동 시작 빠른 토글 |
| **버퍼 초기화** | 현재 누적된 입력 버퍼 수동 비우기 |
| **종료** | 프로그램 종료 |

---

## 기술 및 호환 참고

- **동작 방식 및 리소스 실측:** AutoHotkey v2 이벤트 훅(`InputHook`, `SetWinEventHook` / `EVENT_SYSTEM_FOREGROUND`) 기반으로 폴링 루프가 없으며, Windows 11 x64 실측 기준 **Private Memory `4.17 MB` / Working Set `16.28 MB`**, 대기 시 CPU `0%`입니다.
- **글자 교체 방식:** Windows Unicode 입력(`SendText`)과 두벌식 IME 조합·백스페이스 추적기(`KorImeTracker`)를 사용해 클립보드를 건드리지 않고 화면 글자 수에 맞춰 정확히 지우고 교체합니다.
- **기본 예외 앱 목록:** `WindowsTerminal.exe`, `cmd.exe`, `powershell.exe`, `pwsh.exe`, `Code.exe`, `Cursor.exe`, `devenv.exe`, `idea64.exe`, `pycharm64.exe`, `webstorm64.exe`, `Antigravity.exe`, `wezterm-gui.exe`, `alacritty.exe`, `mintty.exe`
- **설정 파일 위치:** `%APPDATA%\HanEngAutoConverter\settings.ini`
- **호환성 제한:** 표준 한국어 두벌식(`vk15` / `kbd101a.dll`) 기준으로 동작합니다. Windows 보안 정책(UIPI)상 일반 권한으로 실행 시 관리자 권한 창에는 키 전송 및 IME 조회가 제한되며, 일부 최신 WinUI3/UWP 앱에서는 `WM_IME_CONTROL` 조회가 제한될 수 있습니다.

<details>
<summary>소스(.ahk) 직접 실행 및 .exe 수동 빌드</summary>

1. [AutoHotkey v2.0+](https://www.autohotkey.com/)을 설치한 뒤 [`haneng_converter.ahk`](./haneng_converter.ahk)를 바로 실행할 수 있습니다. (단위 테스트는 [`tests/test_converter.ahk`](./tests/test_converter.ahk)에서 확인할 수 있습니다.)
2. `Ahk2Exe`로 `.exe`를 직접 빌드하려면 다음 명령을 실행하세요:
   ```powershell
   Ahk2Exe.exe /in haneng_converter.ahk /out dist\HanEngConverter.exe /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
   ```

</details>

## 라이선스

[MIT License](./LICENSE)를 따릅니다.
