#Requires AutoHotkey v2.0

; 두벌식 영문 <-> 한글 양방향 오타 판별 및 변환 핵심 모듈

class HangulData {
    static KEY_MAP := Map(
        "r", "ㄱ", "R", "ㄲ", "s", "ㄴ", "e", "ㄷ", "E", "ㄸ",
        "f", "ㄹ", "a", "ㅁ", "q", "ㅂ", "Q", "ㅃ", "t", "ㅅ",
        "T", "ㅆ", "d", "ㅇ", "w", "ㅈ", "W", "ㅉ", "c", "ㅊ",
        "z", "ㅋ", "x", "ㅌ", "v", "ㅍ", "g", "ㅎ",
        "A", "ㅁ", "S", "ㄴ", "D", "ㅇ", "F", "ㄹ", "G", "ㅎ",
        "Z", "ㅋ", "X", "ㅌ", "C", "ㅊ", "V", "ㅍ",
        "k", "ㅏ", "o", "ㅐ", "i", "ㅑ", "O", "ㅒ", "j", "ㅓ",
        "p", "ㅔ", "u", "ㅕ", "P", "ㅖ", "h", "ㅗ", "y", "ㅛ",
        "n", "ㅜ", "b", "ㅠ", "m", "ㅡ", "l", "ㅣ",
        "K", "ㅏ", "I", "ㅑ", "J", "ㅓ", "U", "ㅕ", "H", "ㅗ",
        "Y", "ㅛ", "N", "ㅜ", "B", "ㅠ", "M", "ㅡ", "L", "ㅣ"
    )

    static CHO := Map(
        "ㄱ", 0, "ㄲ", 1, "ㄴ", 2, "ㄷ", 3, "ㄸ", 4, "ㄹ", 5,
        "ㅁ", 6, "ㅂ", 7, "ㅃ", 8, "ㅅ", 9, "ㅆ", 10, "ㅇ", 11,
        "ㅈ", 12, "ㅉ", 13, "ㅊ", 14, "ㅋ", 15, "ㅌ", 16, "ㅍ", 17, "ㅎ", 18
    )

    static JUNG := Map(
        "ㅏ", 0, "ㅐ", 1, "ㅑ", 2, "ㅒ", 3, "ㅓ", 4, "ㅔ", 5, "ㅕ", 6,
        "ㅖ", 7, "ㅗ", 8, "ㅘ", 9, "ㅙ", 10, "ㅚ", 11, "ㅛ", 12, "ㅜ", 13,
        "ㅝ", 14, "ㅞ", 15, "ㅟ", 16, "ㅠ", 17, "ㅡ", 18, "ㅢ", 19, "ㅣ", 20
    )

    static JONG := Map(
        "", 0, "ㄱ", 1, "ㄲ", 2, "ㄳ", 3, "ㄴ", 4, "ㄵ", 5, "ㄶ", 6,
        "ㄷ", 7, "ㄹ", 8, "ㄺ", 9, "ㄻ", 10, "ㄼ", 11, "ㄽ", 12, "ㄾ", 13,
        "ㄿ", 14, "ㅀ", 15, "ㅁ", 16, "ㅂ", 17, "ㅄ", 18, "ㅅ", 19, "ㅆ", 20,
        "ㅇ", 21, "ㅈ", 22, "ㅊ", 23, "ㅋ", 24, "ㅌ", 25, "ㅍ", 26, "ㅎ", 27
    )

    static COMB_V := Map(
        "ㅗㅏ", "ㅘ", "ㅗㅐ", "ㅙ", "ㅗㅣ", "ㅚ",
        "ㅜㅓ", "ㅝ", "ㅜㅔ", "ㅞ", "ㅜㅣ", "ㅟ",
        "ㅡㅣ", "ㅢ"
    )

    static COMB_J := Map(
        "ㄱㅅ", "ㄳ", "ㄴㅈ", "ㄵ", "ㄴㅎ", "ㄶ",
        "ㄹㄱ", "ㄺ", "ㄹㅁ", "ㄻ", "ㄹㅂ", "ㄼ", "ㄹㅅ", "ㄽ",
        "ㄹㅌ", "ㄾ", "ㄹㅍ", "ㄿ", "ㄹㅎ", "ㅀ", "ㅂㅅ", "ㅄ"
    )

    static SPLIT_J := Map(
        "ㄳ", ["ㄱ", "ㅅ"], "ㄵ", ["ㄴ", "ㅈ"], "ㄶ", ["ㄴ", "ㅎ"],
        "ㄺ", ["ㄹ", "ㄱ"], "ㄻ", ["ㄹ", "ㅁ"], "ㄼ", ["ㄹ", "ㅂ"],
        "ㄽ", ["ㄹ", "ㅅ"], "ㄾ", ["ㄹ", "ㅌ"], "ㄿ", ["ㄹ", "ㅍ"],
        "ㅀ", ["ㄹ", "ㅎ"], "ㅄ", ["ㅂ", "ㅅ"]
    )

    ; 영 -> 한 변환 시 우연히 완성형 음절이 되는 흔한 영단어 예외 목록
    static EN_SKIP := Map(
        "the", 1, "to", 1, "and", 1, "for", 1, "with", 1, "do", 1,
        "they", 1, "she", 1, "an", 1, "their", 1, "so", 1, "who", 1,
        "go", 1, "when", 1, "them", 1, "than", 1, "then", 1, "also", 1,
        "work", 1, "world", 1, "form", 1, "dorm", 1, "worm", 1,
        "torn", 1, "worn", 1, "corn", 1, "fork", 1, "cork", 1,
        "sort", 1, "fort", 1, "git", 1, "fix", 1, "sorry", 1,
        "check", 1, "slack", 1, "sudo", 1, "curl", 1, "fish", 1,
        "dns", 1, "tls", 1, "xml", 1, "ai", 1
    )

    ; 한 -> 영 역변환 시 한국어로 자주 쓰이지 않는 음절이 나오는 영단어 목록
    static EN_FORCE_KOR2ENG := Map(
        "the", 1, "for", 1, "with", 1, "they", 1, "she", 1, "their", 1,
        "who", 1, "when", 1, "them", 1, "than", 1, "then", 1, "also", 1,
        "world", 1, "form", 1, "sort", 1, "git", 1, "fix", 1, "sorry", 1,
        "check", 1, "slack", 1, "sudo", 1, "curl", 1, "fish", 1, "xml", 1, "ai", 1
    )

    ; 채팅에서 자주 쓰이는 2글자 이상 반복 자모 허용 키
    static CHAT_JAMO_KEYS := Map("z", "ㅋ", "g", "ㅎ", "b", "ㅠ", "n", "ㅜ", "d", "ㅇ")

    ; 한 -> 영 변환 시 제외할 한국어 초성 약어
    static KOR_SLANG_SKIP := Map(
        "rt", 1, "wt", 1, "tr", 1, "gd", 1, "qd", 1, "ss", 1, "rr", 1,
        "ee", 1, "qq", 1, "tt", 1, "ww", 1, "dd", 1, "zz", 1, "gg", 1,
        "bb", 1, "nn", 1
    )
}

EngToKor(text) {
    out := ""
    c := "", v := "", j := ""

    Flush() {
        if (c != "" && v != "") {
            code := 0xAC00 + (HangulData.CHO[c] * 21 + HangulData.JUNG[v]) * 28 + HangulData.JONG[j]
            out .= Chr(code)
        } else if (c != "") {
            out .= c
        } else if (v != "") {
            out .= v
        }
        c := "", v := "", j := ""
    }

    for _, ch in StrSplit(text) {
        if !HangulData.KEY_MAP.Has(ch) {
            Flush()
            out .= ch
            continue
        }
        k := HangulData.KEY_MAP[ch]
        if HangulData.CHO.Has(k) {
            if (c != "" && v != "") {
                if (j == "" && HangulData.JONG.Has(k)) {
                    j := k
                } else if (j != "" && HangulData.COMB_J.Has(j . k)) {
                    j := HangulData.COMB_J[j . k]
                } else {
                    Flush()
                    c := k
                }
            } else {
                Flush()
                c := k
            }
        } else {
            if (c != "" && v == "") {
                v := k
            } else if (c != "" && v != "" && j == "" && HangulData.COMB_V.Has(v . k)) {
                v := HangulData.COMB_V[v . k]
            } else if (c != "" && v != "" && j != "") {
                if HangulData.SPLIT_J.Has(j) {
                    pair := HangulData.SPLIT_J[j]
                    j := pair[1]
                    Flush()
                    c := pair[2]
                    v := k
                } else {
                    nj := j
                    j := ""
                    Flush()
                    c := nj
                    v := k
                }
            } else {
                Flush()
                v := k
            }
        }
    }
    Flush()
    return out
}

IsValidKoreanToken(rawToken) {
    token := RegExReplace(rawToken, "[,\.\?\!]+$", "")
    if (token == "" || !RegExMatch(token, "^[A-Za-z]+$"))
        return false

    if HangulData.EN_SKIP.Has(StrLower(token))
        return false

    first := StrLower(SubStr(token, 1, 1))
    if (StrLen(token) >= 2 && HangulData.CHAT_JAMO_KEYS.Has(first)) {
        allSame := true
        for _, ch in StrSplit(StrLower(token)) {
            if (ch != first) {
                allSame := false
                break
            }
        }
        if allSame
            return true
    }

    kor := EngToKor(token)
    if (kor == "")
        return false

    for _, ch in StrSplit(kor) {
        code := Ord(ch)
        if (code < 0xAC00 || code > 0xD7A3)
            return false
    }
    return true
}

IsValidKoreanSequence(buf) {
    trimmed := Trim(buf)
    if (trimmed == "")
        return false

    hasWord := false
    for _, tok in StrSplit(trimmed, " ") {
        if (tok == "")
            continue
        if RegExMatch(tok, "^[,\.\?\!]+$")
            continue
        hasWord := true
        if !IsValidKoreanToken(tok)
            return false
    }
    return hasWord
}

ShouldConvertEngToKor(rawBuf, &converted) {
    converted := ""
    cleaned := LTrim(rawBuf)
    if !IsValidKoreanSequence(cleaned)
        return false
    converted := EngToKor(cleaned)
    return (converted != "" && !(converted == cleaned))
}

ShouldConvert(rawBuf, &converted) {
    return ShouldConvertEngToKor(rawBuf, &converted)
}

; --- 한글 IME 조합 추적기 (한 -> 영 오타 변환 시 화면 글자 수 정확 계산) ---
class KorImeTracker {
    committedChunks := []
    c := ""
    cRaw := ""
    v := ""
    vRaw := ""
    j := ""
    jRaw := ""

    Reset() {
        this.committedChunks := []
        this.c := ""
        this.cRaw := ""
        this.v := ""
        this.vRaw := ""
        this.j := ""
        this.jRaw := ""
    }

    ActiveRaw() {
        return this.cRaw . this.vRaw . this.jRaw
    }

    ComposeActive() {
        if (this.c != "" && this.v != "") {
            code := 0xAC00 + (HangulData.CHO[this.c] * 21 + HangulData.JUNG[this.v]) * 28 + HangulData.JONG[this.j]
            return Chr(code)
        }
        return this.c . this.v
    }

    CommitActive() {
        raw := this.ActiveRaw()
        if (raw != "") {
            this.committedChunks.Push({raw: raw, text: this.ComposeActive()})
            this.c := "", this.cRaw := ""
            this.v := "", this.vRaw := ""
            this.j := "", this.jRaw := ""
        }
    }

    FeedChar(ch) {
        if !HangulData.KEY_MAP.Has(ch) {
            this.CommitActive()
            this.committedChunks.Push({raw: ch, text: ch})
            return
        }

        k := HangulData.KEY_MAP[ch]
        if HangulData.CHO.Has(k) {
            if (this.c != "" && this.v != "") {
                if (this.j == "" && HangulData.JONG.Has(k)) {
                    this.j := k
                    this.jRaw := ch
                } else if (this.j != "" && HangulData.COMB_J.Has(this.j . k)) {
                    this.j := HangulData.COMB_J[this.j . k]
                    this.jRaw .= ch
                } else {
                    this.CommitActive()
                    this.c := k
                    this.cRaw := ch
                }
            } else {
                this.CommitActive()
                this.c := k
                this.cRaw := ch
            }
        } else {
            if (this.c != "" && this.v == "") {
                this.v := k
                this.vRaw := ch
            } else if (this.c != "" && this.v != "" && this.j == "" && HangulData.COMB_V.Has(this.v . k)) {
                this.v := HangulData.COMB_V[this.v . k]
                this.vRaw .= ch
            } else if (this.c != "" && this.v != "" && this.j != "") {
                if HangulData.SPLIT_J.Has(this.j) {
                    pair := HangulData.SPLIT_J[this.j]
                    prevCode := 0xAC00 + (HangulData.CHO[this.c] * 21 + HangulData.JUNG[this.v]) * 28 + HangulData.JONG[pair[1]]
                    this.committedChunks.Push({raw: this.cRaw . this.vRaw . SubStr(this.jRaw, 1, 1), text: Chr(prevCode)})
                    this.c := pair[2]
                    this.cRaw := SubStr(this.jRaw, 2, 1)
                    this.v := k
                    this.vRaw := ch
                    this.j := "", this.jRaw := ""
                } else {
                    prevCode := 0xAC00 + (HangulData.CHO[this.c] * 21 + HangulData.JUNG[this.v]) * 28
                    this.committedChunks.Push({raw: this.cRaw . this.vRaw, text: Chr(prevCode)})
                    this.c := this.j
                    this.cRaw := this.jRaw
                    this.v := k
                    this.vRaw := ch
                    this.j := "", this.jRaw := ""
                }
            } else {
                this.CommitActive()
                this.v := k
                this.vRaw := ch
            }
        }
    }

    Backspace() {
        if (this.j != "") {
            if (StrLen(this.jRaw) == 2 && HangulData.SPLIT_J.Has(this.j)) {
                pair := HangulData.SPLIT_J[this.j]
                this.j := pair[1]
                this.jRaw := SubStr(this.jRaw, 1, 1)
            } else {
                this.j := "", this.jRaw := ""
            }
        } else if (this.v != "") {
            if (StrLen(this.vRaw) == 2) {
                firstChar := SubStr(this.vRaw, 1, 1)
                this.v := HangulData.KEY_MAP[firstChar]
                this.vRaw := firstChar
            } else {
                this.v := "", this.vRaw := ""
            }
        } else if (this.c != "") {
            this.c := "", this.cRaw := ""
        } else if (this.committedChunks.Length > 0) {
            this.committedChunks.Pop()
        }
    }

    GetRawText() {
        out := ""
        for _, chunk in this.committedChunks
            out .= chunk.raw
        return out . this.ActiveRaw()
    }

    GetScreenText() {
        out := ""
        for _, chunk in this.committedChunks
            out .= chunk.text
        return out . this.ComposeActive()
    }

    GetScreenLen() {
        return StrLen(this.GetScreenText())
    }

    TrimLeadingSpaces() {
        while (this.committedChunks.Length > 0 && this.committedChunks[1].raw == " ")
            this.committedChunks.RemoveAt(1)
    }

    LimitLength(maxChars := 100) {
        while (this.committedChunks.Length > 0 && StrLen(this.GetRawText()) > maxChars)
            this.committedChunks.RemoveAt(1)
    }
}

HasLoneJamo(korText) {
    for _, ch in StrSplit(korText) {
        code := Ord(ch)
        if (code >= 0x3131 && code <= 0x3163)
            return true
    }
    return false
}

IsAllSameChar(str) {
    if (StrLen(str) <= 1)
        return true
    lower := StrLower(str)
    first := SubStr(lower, 1, 1)
    for _, ch in StrSplit(lower) {
        if (ch != first)
            return false
    }
    return true
}

IsMistypedEnglishToken(rawToken) {
    core := RegExReplace(rawToken, "^[,\.\?\!\(\)\[\]\{\}\x22';:]+|[,\.\?\!\(\)\[\]\{\}\x22';:]+$", "")
    if (core == "")
        return false

    alphaOnly := RegExReplace(core, "[^A-Za-z]", "")
    if (StrLen(alphaOnly) < 2)
        return false

    ; 순수 영문자 1개 덩어리인 경우
    if RegExMatch(core, "^[A-Za-z]+$") {
        lower := StrLower(core)
        if HangulData.KOR_SLANG_SKIP.Has(lower)
            return false
        if IsAllSameChar(lower)
            return false
        if HangulData.EN_FORCE_KOR2ENG.Has(lower)
            return true
        return HasLoneJamo(EngToKor(core))
    }

    ; 기호/숫자가 섞인 경우 (URL, 파일명, snake_case, kebab-case 등)
    pos := 1
    hasMistypedRun := false
    while RegExMatch(core, "[A-Za-z]+", &m, pos) {
        run := m[0]
        lowerRun := StrLower(run)
        if (StrLen(run) >= 2 && !IsAllSameChar(lowerRun)) {
            if (HangulData.EN_FORCE_KOR2ENG.Has(lowerRun) || HasLoneJamo(EngToKor(run)))
                hasMistypedRun := true
        }
        pos := m.Pos + m.Len
    }
    return hasMistypedRun
}

ShouldConvertKorToEng(tracker, &rawOut, &screenLenOut) {
    rawOut := ""
    screenLenOut := 0

    tracker.TrimLeadingSpaces()
    raw := tracker.GetRawText()
    screen := tracker.GetScreenText()
    trimmed := Trim(raw)
    if (trimmed == "" || screen == raw)
        return false

    hasMistypedWord := false
    for _, tok in StrSplit(trimmed, " ") {
        if (tok == "")
            continue
        if RegExMatch(tok, "^[0-9,\.\?\!\(\)\[\]\{\}\x22';:\-_/:@]+$")
            continue
        if !IsMistypedEnglishToken(tok)
            return false
        hasMistypedWord := true
    }

    if !hasMistypedWord
        return false

    rawOut := raw
    screenLenOut := StrLen(screen)
    return (screenLenOut > 0)
}

CompareSemVer(v1, v2) {
    s1 := RegExReplace(Trim(v1), "^[vV]|-.*$", "")
    s2 := RegExReplace(Trim(v2), "^[vV]|-.*$", "")
    p1 := StrSplit(s1, ".")
    p2 := StrSplit(s2, ".")
    maxLen := Max(p1.Length, p2.Length)
    Loop maxLen {
        n1 := (A_Index <= p1.Length && IsInteger(p1[A_Index])) ? Integer(p1[A_Index]) : 0
        n2 := (A_Index <= p2.Length && IsInteger(p2[A_Index])) ? Integer(p2[A_Index]) : 0
        if (n1 > n2)
            return 1
        if (n1 < n2)
            return -1
    }
    return 0
}
