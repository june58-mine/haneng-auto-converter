#Requires AutoHotkey v2.0
#Include "%A_ScriptDir%\..\hangul_core.ahk"

out := ""
passed := 0
failed := 0

AssertEq(name, actual, expected) {
    global out, passed, failed
    if (actual == expected) {
        passed++
    } else {
        failed++
        out .= "FAIL [" name "]: expected='" expected "' actual='" actual "'`n"
    }
}

AssertEngToKor(input, expectedShould, expectedKor := "") {
    global out, passed, failed
    conv := ""
    actualShould := ShouldConvertEngToKor(input, &conv)
    if (actualShould != expectedShould) {
        failed++
        out .= "FAIL EngToKor('" input "'): expected=" expectedShould " actual=" actualShould " (conv='" conv "')`n"
        return
    }
    if (expectedShould && !(conv == expectedKor)) {
        failed++
        out .= "FAIL EngToKorConvert('" input "'): expected='" expectedKor "' actual='" conv "'`n"
        return
    }
    passed++
}

FeedTracker(str) {
    t := KorImeTracker()
    for _, ch in StrSplit(str)
        t.FeedChar(ch)
    return t
}

AssertKorToEng(input, expectedShould, expectedRaw := "", expectedScreenLen := 0) {
    global out, passed, failed
    t := FeedTracker(input)
    rawOut := ""
    screenLenOut := 0
    actualShould := ShouldConvertKorToEng(t, &rawOut, &screenLenOut)
    if (actualShould != expectedShould) {
        failed++
        out .= "FAIL KorToEng('" input "'): expected=" expectedShould " actual=" actualShould " (screen='" t.GetScreenText() "')`n"
        return
    }
    if (expectedShould) {
        if !(rawOut == expectedRaw) {
            failed++
            out .= "FAIL KorToEngRaw('" input "'): expected='" expectedRaw "' actual='" rawOut "'`n"
            return
        }
        if (screenLenOut != expectedScreenLen) {
            failed++
            out .= "FAIL KorToEngLen('" input "'): expected=" expectedScreenLen " actual=" screenLenOut "`n"
            return
        }
    }
    passed++
}

; --- 1. EngToKor 단위 테스트 ---
AssertEq("hello-kor", EngToKor("dkssudgktpdy"), "안녕하세요")
AssertEq("thankyou", EngToKor("rkatkgkqslek"), "감사합니다")
AssertEq("compound-final-split", EngToKor("ekfrl"), "달기")
AssertEq("compound-final-stay", EngToKor("rkqtdjqtsms ekfrrkfql"), "값없는 닭갈비")
AssertEq("double-consonants", EngToKor("skfTl"), "날씨")
AssertEq("double-vowel-ye", EngToKor("dPwjf"), "예절")
AssertEq("double-cons-pp", EngToKor("Qkfmrp"), "빠르게")
AssertEq("double-cons-ss-jong", EngToKor("dkTld"), "아씽")
AssertEq("double-cons-jj", EngToKor("Wkwkdaus"), "짜장면")
AssertEq("double-cons-tt", EngToKor("Ektl"), "따시")
AssertEq("complex-jong-split", EngToKor("aktdlTrp"), "맛있게")
AssertEq("complex-jong-bs", EngToKor("djqtdj"), "없어")
AssertEq("complex-jong-lg", EngToKor("dlfrdj"), "읽어")
AssertEq("double-g-not-kk", EngToKor("rkrrk"), "각가")
AssertEq("double-cons-kk-jong", EngToKor("dkRkl"), "아까ㅣ")
AssertEq("compound-vowel-wa", EngToKor("dhk"), "와")
AssertEq("compound-vowel-wo", EngToKor("dnj"), "워")
AssertEq("compound-vowel-ui", EngToKor("dml"), "의")
AssertEq("mixed-punct", EngToKor("dkssud, gktpdy!"), "안녕, 하세요!")
AssertEq("capslock-upper", EngToKor("DKSSUD"), "안녕")

; --- 2. ShouldConvertEngToKor 테스트 ---
AssertEngToKor("dkssud", true, "안녕")
AssertEngToKor("dkssudgktpdy", true, "안녕하세요")
AssertEngToKor("dkssud gktpdy", true, "안녕 하세요")
AssertEngToKor("dkssud, gktpdy!", true, "안녕, 하세요!")
AssertEngToKor("rkatkgkqslek", true, "감사합니다")
AssertEngToKor("tkfkdgo", true, "사랑해")
AssertEngToKor("skfTl", true, "날씨")
AssertEngToKor("zzz", true, "ㅋㅋㅋ")
AssertEngToKor("gg", true, "ㅎㅎ")
AssertEngToKor("bbb", true, "ㅠㅠㅠ")
AssertEngToKor("dd", true, "ㅇㅇ")
AssertEngToKor("zzz dkssud", true, "ㅋㅋㅋ 안녕")
AssertEngToKor("DKSSUD", true, "안녕")

AssertEngToKor("", false)
AssertEngToKor(" ", false)
AssertEngToKor("a", false)
AssertEngToKor("g", false)
AssertEngToKor("z", false)
AssertEngToKor("hello", false)
AssertEngToKor("test", false)
AssertEngToKor("API", false)
AssertEngToKor("python", false)
AssertEngToKor("code", false)
AssertEngToKor("word", false)
AssertEngToKor("give", false)
AssertEngToKor("docker", false)
AssertEngToKor("the", false)
AssertEngToKor("for", false)
AssertEngToKor("git", false)
AssertEngToKor("with", false)
AssertEngToKor("work", false)
AssertEngToKor("world", false)
AssertEngToKor("check", false)
AssertEngToKor("slack", false)
AssertEngToKor("sorry", false)
AssertEngToKor("go", false)
AssertEngToKor("so", false)
AssertEngToKor("to", false)
AssertEngToKor("do", false)
AssertEngToKor("GIT", false)
AssertEngToKor("XML", false)
AssertEngToKor("DNS", false)

; --- 3. SubStr 확인 ---
s := "abcdef"
AssertEq("substr-last1", SubStr(s, -1), "f")
AssertEq("substr-pop1", SubStr(s, 1, -1), "abcde")
AssertEq("substr-last3", SubStr(s, -3), "def")

; --- 4. KorImeTracker 조합 및 백스페이스 테스트 ---
t1 := FeedTracker("hello")
AssertEq("tracker-hello-screen", t1.GetScreenText(), "ㅗ디ㅣㅐ")
AssertEq("tracker-hello-len", t1.GetScreenLen(), 4)
AssertEq("tracker-hello-raw", t1.GetRawText(), "hello")

t2 := FeedTracker("google")
AssertEq("tracker-google-screen", t2.GetScreenText(), "해ㅐ힏")
AssertEq("tracker-google-len", t2.GetScreenLen(), 3)

t3 := FeedTracker("git")
AssertEq("tracker-git-screen", t3.GetScreenText(), "햣")
AssertEq("tracker-git-len", t3.GetScreenLen(), 1)

t4 := FeedTracker("python")
AssertEq("tracker-python-screen", t4.GetScreenText(), "ㅔㅛ쇄ㅜ")
AssertEq("tracker-python-len", t4.GetScreenLen(), 4)

t5 := FeedTracker("hello world")
AssertEq("tracker-hw-screen", t5.GetScreenText(), "ㅗ디ㅣㅐ 재깅")
AssertEq("tracker-hw-len", t5.GetScreenLen(), 7)

tBs1 := FeedTracker("dhk")
tBs1.Backspace()
AssertEq("tracker-bs-wa", tBs1.GetScreenText(), "오")
AssertEq("tracker-bs-wa-raw", tBs1.GetRawText(), "dh")

tBs2 := FeedTracker("ekfr")
tBs2.Backspace()
AssertEq("tracker-bs-dak", tBs2.GetScreenText(), "달")
AssertEq("tracker-bs-dak-raw", tBs2.GetRawText(), "ekf")

tBs3 := FeedTracker("ekfrl")
tBs3.Backspace()
AssertEq("tracker-bs-dalgi", tBs3.GetScreenText(), "달ㄱ")
AssertEq("tracker-bs-dalgi-len", tBs3.GetScreenLen(), 2)
AssertEq("tracker-bs-dalgi-raw", tBs3.GetRawText(), "ekfr")

tBs4 := FeedTracker("dk ")
tBs4.Backspace()
tBs4.FeedChar("s")
AssertEq("tracker-bs-space-nomerge", tBs4.GetScreenText(), "아ㄴ")
AssertEq("tracker-bs-space-len", tBs4.GetScreenLen(), 2)
AssertEq("tracker-bs-space-raw", tBs4.GetRawText(), "dks")

; --- 5. ShouldConvertKorToEng 테스트 ---
AssertKorToEng("hello", true, "hello", 4)
AssertKorToEng("google", true, "google", 3)
AssertKorToEng("python", true, "python", 4)
AssertKorToEng("test", true, "test", 4)
AssertKorToEng("git", true, "git", 1)
AssertKorToEng("check", true, "check", 2)
AssertKorToEng("world", true, "world", 2)
AssertKorToEng("hello world", true, "hello world", 7)
AssertKorToEng("git push", true, "git push", 5)
AssertKorToEng("npm run dev", true, "npm run dev", 10)
AssertKorToEng("https://google.com", true, "https://google.com", 12)
AssertKorToEng("foo_bar", true, "foo_bar", 6)

AssertKorToEng("dkssudgktpdy", false)
AssertKorToEng("rkatkgkqslek", false)
AssertKorToEng("zzz", false)
AssertKorToEng("gg", false)
AssertKorToEng("bbb", false)
AssertKorToEng("dd", false)
AssertKorToEng("rt", false)
AssertKorToEng("wt", false)
AssertKorToEng("so", false)
AssertKorToEng("go", false)
AssertKorToEng("to", false)
AssertKorToEng("do", false)
AssertKorToEng("dns", false)
AssertKorToEng("tls", false)
AssertKorToEng("a", false)
AssertKorToEng("d", false)
AssertKorToEng("g", false)
AssertKorToEng("12345", false)

; --- 6. CompareSemVer 테스트 ---
AssertEq("semver-gt-patch", CompareSemVer("1.0.1", "1.0.0"), 1)
AssertEq("semver-gt-minor-v", CompareSemVer("v1.2.0", "1.1.9"), 1)
AssertEq("semver-eq-v", CompareSemVer("1.0.0", "v1.0.0"), 0)
AssertEq("semver-gt-10-vs-2", CompareSemVer("1.10.0", "1.2.0"), 1)
AssertEq("semver-prerelease-eq", CompareSemVer("1.0.0-beta.1", "1.0.0"), 0)

summary := "PASSED=" passed " FAILED=" failed "`n" out
outPath := A_Temp "\haneng_test_out.txt"
try FileDelete(outPath)
FileAppend(summary, outPath, "UTF-8")
ExitApp(failed > 0 ? 1 : 0)
