module ithox.qrcode.common.characterseteci;

/// Character set constants.
enum CharacterEnun : int
{
    CP437 = 0,
    ISO8859_1 = 1,
    ISO8859_2 = 4,
    ISO8859_3 = 5,
    ISO8859_4 = 6,
    ISO8859_5 = 7,
    ISO8859_6 = 8,
    ISO8859_7 = 9,
    ISO8859_8 = 10,
    ISO8859_9 = 11,
    ISO8859_10 = 12,
    ISO8859_11 = 13,
    ISO8859_12 = 14,
    ISO8859_13 = 15,
    ISO8859_14 = 16,
    ISO8859_15 = 17,
    ISO8859_16 = 18,
    SJIS = 20,
    CP1250 = 21,
    CP1251 = 22,
    CP1252 = 23,
    CP1256 = 24,
    UNICODE_BIG_UNMARKED = 25,
    UTF8 = 26,
    ASCII = 27,
    BIG5 = 28,
    GB18030 = 29,
    EUC_KR = 30,
}

/**
* Encapsulates a Character Set ECI, according to "Extended Channel
* Interpretations" 5.3.1.1 of ISO 18004.
*/
class CharacterSetEci
{

    protected CharacterEnun _c;
    ///Map between character names and their ECI values.
    protected enum CharacterEnun[string] nameToEci = [
            "ISO-8859-1" : CharacterEnun.ISO8859_1, "ISO-8859-2"
            : CharacterEnun.ISO8859_2, "ISO-8859-3" : CharacterEnun.ISO8859_3,
            "ISO-8859-4" : CharacterEnun.ISO8859_4, "ISO-8859-5"
            : CharacterEnun.ISO8859_5, "ISO-8859-6" : CharacterEnun.ISO8859_6,
            "ISO-8859-7" : CharacterEnun.ISO8859_7, "ISO-8859-8"
            : CharacterEnun.ISO8859_8, "ISO-8859-9" : CharacterEnun.ISO8859_9,
            "ISO-8859-10" : CharacterEnun.ISO8859_10, "ISO-8859-11"
            : CharacterEnun.ISO8859_11, "ISO-8859-12"
            : CharacterEnun.ISO8859_12, "ISO-8859-13" : CharacterEnun.ISO8859_13,
            "ISO-8859-14" : CharacterEnun.ISO8859_14, "ISO-8859-15"
            : CharacterEnun.ISO8859_15, "ISO-8859-16" : CharacterEnun.ISO8859_16,
            "SHIFT-JIS" : CharacterEnun.SJIS, "WINDOWS-1250"
            : CharacterEnun.CP1250, "WINDOWS-1251" : CharacterEnun.CP1251,
            "WINDOWS-1252" : CharacterEnun.CP1252, "WINDOWS-1256"
            : CharacterEnun.CP1256, "UTF-16BE" : CharacterEnun.UNICODE_BIG_UNMARKED,
            "UTF-8" : CharacterEnun.UTF8, "ASCII"
            : CharacterEnun.ASCII, "GBK" : CharacterEnun.GB18030, "EUC-KR"
            : CharacterEnun.EUC_KR,
        ];

    this(CharacterEnun s)
    {
        this._c = s;

    }

    public @property CharacterEnun eci()
    {
        return this._c;
    }

    public static CharacterSetEci getCharacterSetEciByName(string enc)
    {
        //return nameToEci.get(enc, CharacterEnun.UTF8);
        return new CharacterSetEci(nameToEci.get(enc, CharacterEnun.UTF8));
    }

}
