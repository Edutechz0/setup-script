#!/bin/bash

# =========================================================
# EDUFWESH MANAGER - ULTIMATE ENTERPRISE v17.0
# (Features: Universal Data Parsing, Unicode Fonts, Pro Themes)
# =========================================================

# --- 1. VISUAL PREFERENCES ENGINE ---
THEME_FILE="/etc/edu_theme"
FONT_FILE="/etc/edu_font"        # For Figlet (Old style)
U_FONT_FILE="/etc/edu_ufont"     # For Fancy Unicode (New)
SCOPE_FILE="/etc/edu_scope"      # Banner Only vs Full

# Set Defaults
if [ ! -f "$THEME_FILE" ]; then echo "blue" > "$THEME_FILE"; fi
if [ ! -f "$FONT_FILE" ]; then echo "standard" > "$FONT_FILE"; fi
if [ ! -f "$U_FONT_FILE" ]; then echo "normal" > "$U_FONT_FILE"; fi
if [ ! -f "$SCOPE_FILE" ]; then echo "banner" > "$SCOPE_FILE"; fi

CURr_THEME=$(cat "$THEME_FILE")
CURr_UFONT=$(cat "$U_FONT_FILE")
CURr_SCOPE=$(cat "$SCOPE_FILE")

# --- 1.5 UNICODE FONT MAPPING ENGINE ---
# Default Texts
T_HEADER="EDUFWESH ENTERPRISE MANAGER"
T_U_MGMT="USER MANAGEMENT"
T_S_OPS="SERVER OPERATIONS"
T_CONFIG="CONFIGURATION & CLOUD"
T_EXIT="Exit Dashboard"
L_HOST="Host"
L_TIME="Time"
L_IP="IP"
L_ISP="ISP"
L_NS="NS"
L_SEC="Sec"
L_DAY="Daily"    
L_MONTH="Monthly"
L_RAM="RAM"
L_CPU="CPU"
L_SSH="SSH"
L_XRAY="XRAY"
L_WEB="WEB"

case $CURr_UFONT in
    "normal") ;; # Default
    "mono") # 𝙼𝚘𝚗𝚘𝚜𝚙𝚊𝚌𝚎
        T_HEADER="𝙴𝙳𝚄𝙵𝚆𝙴𝚂𝙷 𝙴𝙽𝚃𝙴𝚁𝙿𝚁𝙸𝚂𝙴 𝙼𝙰𝙽𝙰𝙶𝙴𝚁"; T_U_MGMT="𝚄𝚂𝙴𝚁 𝙼𝙰𝙽𝙰𝙶𝙴𝙼𝙴𝙽𝚃"
        T_S_OPS="𝚂𝙴𝚁𝚅𝙴𝚁 𝙾𝙿𝙴𝚁𝙰𝚃𝙸𝙾𝙽𝚂"; T_CONFIG="𝙲𝙾𝙽𝙵𝙸𝙶𝚄𝚁𝙰𝚃𝙸𝙾𝙽 & 𝙲𝙻𝙾𝚄𝙳"
        T_EXIT="𝙴𝚡𝚒𝚝 𝙳𝚊𝚜𝚑𝚋𝚘𝚊𝚛𝚍"
        L_HOST="𝙷𝚘𝚜𝚝"; L_TIME="𝚃𝚒𝚖𝚎"; L_IP="𝙸𝙿"; L_ISP="𝙸𝚂𝙿"; L_NS="𝙽𝚂"; L_SEC="𝚂𝚎𝚌"
        L_DAY="𝙳𝚊𝚒𝚕𝚢"; L_MONTH="𝙼𝚘𝚗𝚝𝚑"
        L_RAM="𝚁𝙰𝙼"; L_CPU="𝙲𝙿𝚄"; L_SSH="𝚂𝚂𝙷"; L_XRAY="𝚇𝚁𝙰𝚈"; L_WEB="𝚆𝙴𝙱" ;;
    "fraktur") # 𝕳𝖊𝖑𝖑𝖔
        T_HEADER="𝕰𝕯𝖀𝕱𝖂𝕰𝕾𝕳 𝕰𝕹𝕿𝕰𝕽𝕻𝕽𝕴𝕾𝕰 𝕸𝕬𝕹𝕬𝕲𝕰𝕽"; T_U_MGMT="𝖀𝕾𝕰𝕽 𝕸𝕬𝕹𝕬𝕲𝕰𝕸𝕰𝕹𝕿"
        T_S_OPS="𝕾𝕰𝕽𝖁𝕰𝕽 𝕺𝕻𝕰𝕽𝕬𝕿𝕴𝕺𝕹𝕾"; T_CONFIG="𝕮𝕺𝕹𝕱𝕴𝕲𝖀𝕽𝕬𝕿𝕴𝕺𝕹 & 𝕮𝕷𝕺𝖀𝕯"
        T_EXIT="𝕰𝖝𝖎𝖙 𝕯𝖆𝖘𝖍𝖇𝖔𝖆𝖗𝖉"
        L_HOST="𝕳𝖔𝖘𝖙"; L_TIME="𝕿𝖎𝖒𝖊"; L_IP="𝕴𝕻"; L_ISP="𝕴𝕾𝕻"; L_NS="𝕹𝕾"; L_SEC="𝕾𝖊𝖈"
        L_DAY="𝕯𝖆𝖎𝖑𝖞"; L_MONTH="𝕸𝖔𝖓𝖙𝖍"
        L_RAM="𝕽𝕬𝕸"; L_CPU="𝕮𝕻𝖀"; L_SSH="𝕾𝕾𝕳"; L_XRAY="𝖃𝕽𝕬𝖄"; L_WEB="𝖂𝕰𝕭" ;;
    "script") # ℋ𝒾
        T_HEADER="ℰ𝒟𝒰ℱ𝒲ℰ𝒮ℋ ℰ𝒩𝒯ℰℛ𝒫ℛℐ𝒮ℰ ℳ𝒜𝒩𝒜𝒢ℰℛ"; T_U_MGMT="𝒰𝒮ℰℛ ℳ𝒜𝒩𝒜𝒢ℰℳℰ𝒩𝒯"
        T_S_OPS="𝒮ℰℛ𝒱ℰℛ 𝒪𝒫ℰℛ𝒜𝒯ℐ𝒪𝒩𝒮"; T_CONFIG="𝒞𝒪𝒩ℱℐ𝒢𝒰ℛ𝒜𝒯ℐ𝒪𝒩 & 𝒞ℒ𝒪𝒰𝒟"
        T_EXIT="ℰ𝓍𝒾𝓉 𝒟𝒶𝓈𝒽𝒷ℴ𝒶𝓇𝒹"
        L_HOST="ℋℴ𝓈𝓉"; L_TIME="𝒯𝒾𝓂ℯ"; L_IP="ℐ𝒫"; L_ISP="ℐ𝒮𝒫"; L_NS="𝒩𝒮"; L_SEC="𝒮ℯ𝒸"
        L_DAY="𝒟𝒶𝒾𝓁𝓎"; L_MONTH="ℳℴ𝓃𝓉𝒽"
        L_RAM="ℛ𝒜ℳ"; L_CPU="𝒞𝒫𝒰"; L_SSH="𝒮𝒮ℋ"; L_XRAY="𝒳ℛ𝒜𝒴"; L_WEB="𝒲ℰℬ" ;;
    "double") # ℍ𝕖𝕝𝕝𝕠
        T_HEADER="𝔼𝔻𝕌𝔽𝕎𝔼𝕊ℍ 𝔼ℕ𝕋𝔼ℝℙℝ𝕀𝕊𝔼 𝕄𝔸ℕ𝔸𝔾𝔼ℝ"; T_U_MGMT="𝕌𝕊𝔼ℝ 𝕄𝔸ℕ𝔸𝔾𝔼𝕄𝔼ℕ𝕋"
        T_S_OPS="𝕊𝔼ℝ𝕍𝔼ℝ 𝕆ℙ𝔼ℝ𝔸𝕋𝕀𝕆ℕ𝕊"; T_CONFIG="ℂ𝕆ℕ𝔽𝕀𝔾𝕌ℝ𝔸𝕋𝕀𝕆ℕ & ℂ𝕃𝕆𝕌𝔻"
        T_EXIT="𝔼𝕩𝕚𝕥 𝔻𝕒𝕤𝕙𝕓𝕠𝕒𝕣𝕕"
        L_HOST="ℍ𝕠𝕤𝕥"; L_TIME="𝕋𝕚𝕞𝕖"; L_IP="𝕀ℙ"; L_ISP="𝕀𝕊ℙ"; L_NS="ℕ𝕊"; L_SEC="𝕊𝕖𝕔"
        L_DAY="𝔻𝕒𝕚𝕝𝕪"; L_MONTH="𝕄𝕠𝕟𝕥𝕙"
        L_RAM="ℝ𝔸𝕄"; L_CPU="ℂℙ𝕌"; L_SSH="𝕊𝕊ℍ"; L_XRAY="𝕏ℝ𝔸𝕐"; L_WEB="𝕎𝔼𝔹" ;;
    "bold_script") # 𝓗𝓲
        T_HEADER="𝓔𝓓𝓤𝓕𝓦𝓔𝓢𝓗 𝓔𝓝𝓣𝓔𝓡𝓟𝓡𝓘𝓢𝓔 𝓜𝓐𝓝𝓐𝓖𝓔𝓡"; T_U_MGMT="𝓤𝓢𝓔𝓡 𝓜𝓐𝓝𝓐𝓖𝓔𝓜𝓔𝓝𝓣"
        T_S_OPS="𝓢𝓔𝓡𝓥𝓔𝓡 𝓞𝓟𝓔𝓡𝓐𝓣𝓘𝓞𝓝𝓢"; T_CONFIG="𝓒𝓞𝓝𝓕𝓘𝓖𝓤𝓡𝓐𝓣𝓘𝓞𝓝 & 𝓒𝓛𝓞𝓤𝓓"
        T_EXIT="𝓔𝔁𝓲𝓽 𝓓𝓪𝓼𝓱𝓫𝓸𝓪𝓻𝓭"
        L_HOST="𝓗𝓸𝓼𝓽"; L_TIME="𝓣𝓲𝓶𝓮"; L_IP="𝓘𝓟"; L_ISP="𝓘𝓢𝓟"; L_NS="𝓝𝓢"; L_SEC="𝓢𝓮𝓬"
        L_DAY="𝓓𝓪𝓲𝓵𝔂"; L_MONTH="𝓜𝓸𝓷𝓽𝓱"
        L_RAM="𝓡𝓐𝓜"; L_CPU="𝓒𝓟𝓤"; L_SSH="𝓢𝓢𝓗"; L_XRAY="𝓧𝓡𝓐𝓨"; L_WEB="𝓦𝓔𝓑" ;;
    "small") # ʜᴇʟʟᴏ
        T_HEADER="ᴇᴅᴜғᴡᴇsʜ ᴇɴᴛᴇʀᴘʀɪsᴇ ᴍᴀɴᴀɢᴇʀ"; T_U_MGMT="ᴜsᴇʀ ᴍᴀɴᴀɢᴇᴍᴇɴᴛ"
        T_S_OPS="sᴇʀᴠᴇʀ ᴏᴘᴇʀᴀᴛɪᴏɴs"; T_CONFIG="ᴄᴏɴғɪɢᴜʀᴀᴛɪᴏɴ & ᴄʟᴏᴜᴅ"
        T_EXIT="ᴇxɪᴛ ᴅᴀsʜʙᴏᴀʀᴅ"
        L_HOST="ʜᴏsᴛ"; L_TIME="ᴛɪᴍᴇ"; L_IP="ɪᴘ"; L_ISP="ɪsᴘ"; L_NS="ɴs"; L_SEC="sᴇᴄ"
        L_DAY="ᴅᴀɪʟʏ"; L_MONTH="ᴍᴏɴᴛʜ"
        L_RAM="ʀᴀᴍ"; L_CPU="ᴄᴘᴜ"; L_SSH="ssʜ"; L_XRAY="xʀᴀʏ"; L_WEB="ᴡᴇʙ" ;;
    "squared") # 🄷🄸
        T_HEADER="🄴🄳🅄🄵🅆🄴🅂🄷 🄴🄽🅃🄴🅁🄿🅁🄸🅂🄴 🄼🄰🄽🄰🄶🄴🅁"; T_U_MGMT="🅄🅂🄴🅁 🄼🄰🄽🄰🄶🄴🄼🄴🄽🅃"
        T_S_OPS="🅂🄴🅁🅅🄴🅁 🄾🄿🄴🅁🄰🅃🄸🄾🄽🅂"; T_CONFIG="🄲🄾🄽🄵🄸🄶🅄🅁🄰🅃🄸🄾🄽 & 🄲🄻🄾🅄🄳"
        T_EXIT="🄴🅇🄸🅃 🄳🄰🅂🄷🄱🄾🄰🅁🄳"
        L_HOST="🄷🄾🅂🅃"; L_TIME="🅃🄸🄼🄴"; L_IP="🄸🄿"; L_ISP="🄸🅂🄿"; L_NS="🄽🅂"; L_SEC="🅂🄴🄲"
        L_DAY="🄳🄰🄸🄻🅈"; L_MONTH="🄼🄾🄽🅃🄷"
        L_RAM="🅁🄰🄼"; L_CPU="🄲🄿🅄"; L_SSH="🅂🅂🄷"; L_XRAY="🅇🅁🄰🅈"; L_WEB="🅆🄴🄱" ;;
    "bubble") # Ⓗⓘ
        T_HEADER="ⒺⒹⓊⒻⓌⒺⓈⒽ ⒺⓃⓉⒺⓇⓅⓇⒾⓈⒺ ⓂⒶⓃⒶⒼⒺⓇ"; T_U_MGMT="ⓊⓈⒺⓇ ⓂⒶⓃⒶⒼⒺⓂⒺⓃⓉ"
        T_S_OPS="ⓈⒺⓇⓋⒺⓇ ⓄⓅⒺⓇⒶⓉⒾⓄⓃⓈ"; T_CONFIG="ⒸⓄⓃⒻⒾⒼⓊⓇⒶⓉⒾⓄⓃ & ⒸⓁⓄⓊⒹ"
        T_EXIT="Ⓔⓧⓘⓣ Ⓓⓐⓢⓗⓑⓞⓐⓡⓓ"
        L_HOST="Ⓗⓞⓢⓣ"; L_TIME="Ⓣⓘⓜⓔ"; L_IP="ⒾⓅ"; L_ISP="ⒾⓈⓅ"; L_NS="ⓃⓈ"; L_SEC="Ⓢⓔⓒ"
        L_DAY="Ⓓⓐⓘⓛⓨ"; L_MONTH="Ⓜⓞⓝⓣⓗ"
        L_RAM="ⓇⒶⓂ"; L_CPU="ⒸⓅⓊ"; L_SSH="ⓈⓈⒽ"; L_XRAY="ⓍⓇⒶⓎ"; L_WEB="ⓌⒺⒷ" ;;
    "wide") # Ｈｉ
        T_HEADER="ＥＤＵＦＷＥＳＨ ＥＮＴＥＲＰＲＩＳＥ ＭＡＮＡＧＥＲ"; T_U_MGMT="ＵＳＥＲ ＭＡＮＡＧＥＭＥＮＴ"
        T_S_OPS="ＳＥＲＶＥＲ ＯＰＥＲＡＴＩＯＮＳ"; T_CONFIG="ＣＯＮＦＩＧＵＲＡＴＩＯＮ ＆ ＣＬＯＵＤ"
        T_EXIT="Ｅｘｉｔ Ｄａｓｈｂｏａｒｄ"
        L_HOST="Ｈｏｓｔ"; L_TIME="Ｔｉｍｅ"; L_IP="ＩＰ"; L_ISP="ＩＳＰ"; L_NS="ＮＳ"; L_SEC="Ｓｅｃ"
        L_DAY="Ｄａｉｌｙ"; L_MONTH="Ｍｏｎｔｈ"
        L_RAM="ＲＡＭ"; L_CPU="ＣＰＵ"; L_SSH="ＳＳＨ"; L_XRAY="ＸＲＡＹ"; L_WEB="ＷＥＢ" ;;
    "serif_bold") # 𝐇𝐢
        T_HEADER="𝐄𝐃𝐔𝐅𝐖𝐄𝐒𝐇 𝐄𝐍𝐓𝐄𝐑𝐏𝐑𝐈𝐒𝐄 𝐌𝐀𝐍𝐀𝐆𝐄𝐑"; T_U_MGMT="𝐔𝐒𝐄𝐑 𝐌𝐀𝐍𝐀𝐆𝐄𝐌𝐄𝐍𝐓"
        T_S_OPS="𝐒𝐄𝐑𝐕𝐄𝐑 𝐎𝐏𝐄𝐑𝐀𝐓𝐈𝐎𝐍𝐒"; T_CONFIG="𝐂𝐎𝐍𝐅𝐈𝐆𝐔𝐑𝐀𝐓𝐈𝐎𝐍 & 𝐂𝐋𝐎𝐔𝐃"
        T_EXIT="𝐄𝐱𝐢𝐭 𝐃𝐚𝐬𝐡𝐛𝐨𝐚𝐫𝐝"
        L_HOST="𝐇𝐨𝐬𝐭"; L_TIME="𝐓𝐢𝐦𝐞"; L_IP="𝐈𝐏"; L_ISP="𝐈𝐒𝐏"; L_NS="𝐍𝐒"; L_SEC="𝐒𝐞𝐜"
        L_DAY="𝐃𝐚𝐢𝐥𝐲"; L_MONTH="𝐌𝐨𝐧𝐭𝐡"
        L_RAM="𝐑𝐀𝐌"; L_CPU="𝐂𝐏𝐔"; L_SSH="𝐒𝐒𝐇"; L_XRAY="𝐗𝐑𝐀𝐘"; L_WEB="𝐖𝐄𝐁" ;;
    "sans_bold") # 𝗛𝗶
        T_HEADER="𝗘𝗗𝗨𝗙𝗪𝗘𝗦𝗛 𝗘𝗡𝗧𝗘𝗥𝗣𝗥𝗜𝗦𝗘 𝗠𝗔𝗡𝗔𝗚𝗘𝗥"; T_U_MGMT="𝗨𝗦𝗘𝗥 𝗠𝗔𝗡𝗔𝗚𝗘𝗠𝗘𝗡𝗧"
        T_S_OPS="𝗦𝗘𝗥𝗩𝗘𝗥 𝗢𝗣𝗘𝗥𝐀𝐓𝗜𝗢𝗡𝗦"; T_CONFIG="𝗖𝗢𝗡𝗙𝗜ＧＵＲＡＴＩ𝗢Ｎ & 𝗖𝗟𝗢𝐔𝗗"
        T_EXIT="𝗘𝘅𝗶𝘁 𝗗𝗮𝘀𝗵𝗯𝗼𝗮𝗿𝗱"
        L_HOST="𝗛𝗼𝘀𝘁"; L_TIME="𝗧𝗶𝗺𝗲"; L_IP="𝗜𝗣"; L_ISP="𝗜𝗦𝗣"; L_NS="𝗡𝗦"; L_SEC="𝗦𝗲𝗰"
        L_DAY="𝗗𝗮𝗶𝗹𝘆"; L_MONTH="𝗠𝗼𝗻𝘁𝗵"
        L_RAM="𝗥𝗔𝗠"; L_CPU="𝗖𝗣𝗨"; L_SSH="𝗦𝗦Ｈ"; L_XRAY="𝗫𝗥𝗔𝗬"; L_WEB="𝗪𝗘𝗕" ;;
    "italic") # 𝐻𝑖
        T_HEADER="𝐸𝐷𝑈𝐹𝑊𝐸𝑆𝐻 𝐸𝑁𝑇𝐸𝑅𝑃𝑅𝐼𝑆𝐸 𝑀𝐴𝑁𝐴𝐺𝐸𝑅"; T_U_MGMT="𝑈𝑆𝐸𝑅 𝑀𝐴𝑁𝐴𝐺𝐸𝑀𝐸𝑁𝑇"
        T_S_OPS="𝑆𝐸𝑅𝑉𝐸𝑅 𝑂𝑃𝐸𝑅𝐴𝑇𝐼𝑂𝑁𝑆"; T_CONFIG="𝐶𝑂𝑁𝐹𝐼𝐺𝑈𝑅𝐴𝑇𝐼𝑂𝑁 & 𝐶𝐿𝑂𝑈𝐷"
        T_EXIT="𝐸𝑥𝑖𝑡 𝐷𝑎𝑠ℎ𝑏ｏａ𝑟ｄ"
        L_HOST="𝐻𝑜𝑠𝑡"; L_TIME="𝑇𝑖𝑚𝑒"; L_IP="𝐼𝑃"; L_ISP="𝐼𝑆𝑃"; L_NS="𝑁𝑆"; L_SEC="𝑆𝑒𝑐"
        L_DAY="𝐷𝑎𝑖𝑙ｙ"; L_MONTH="𝑀𝑜𝑛𝑡ℎ"
        L_RAM="𝑅𝐴𝑀"; L_CPU="𝐶𝑃𝑈"; L_SSH="𝑆𝑆Ｈ"; L_XRAY="𝑋𝑅𝐴𝑌"; L_WEB="𝑊𝐸𝐵" ;;
esac

# APPLY SCOPE LOGIC
if [[ "$CURr_SCOPE" == "banner" ]]; then
    # Reset everything EXCEPT Header to normal if scope is just banner
    T_U_MGMT="USER MANAGEMENT"
    T_S_OPS="SERVER OPERATIONS"
    T_CONFIG="CONFIGURATION & CLOUD"
    T_EXIT="Exit Dashboard"
    L_HOST="Host"; L_TIME="Time"; L_IP="IP"; L_ISP="ISP"; L_NS="NS"; L_SEC="Sec"
    L_DAY="Daily"; L_MONTH="Month"
    L_RAM="RAM"; L_CPU="CPU"; L_SSH="SSH"; L_XRAY="XRAY"; L_WEB="WEB"
fi

# --- THEME COLORS (RESTORED PRO LIST) ---
case $CURr_THEME in
    "green")    C_MAIN='\033[1;32m'; C_ACCENT='\033[1;32m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;32m' ;;
    "purple")   C_MAIN='\033[1;35m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;35m' ;;
    "red")      C_MAIN='\033[1;31m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;31m' ;;
    "gold")     C_MAIN='\033[0;33m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[0;33m' ;;
    "ocean")    C_MAIN='\033[0;36m'; C_ACCENT='\033[1;34m'; C_TEXT='\033[1;37m'; C_BAR='\033[0;36m' ;;
    "retro")    C_MAIN='\033[0;31m'; C_ACCENT='\033[0;33m'; C_TEXT='\033[1;33m'; C_BAR='\033[0;33m' ;;
    "mono")     C_MAIN='\033[1;30m'; C_ACCENT='\033[1;37m'; C_TEXT='\033[0;37m'; C_BAR='\033[1;37m' ;;
    "dracula")  C_MAIN='\033[1;35m'; C_ACCENT='\033[1;32m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;31m' ;;
    "nord")     C_MAIN='\033[1;34m'; C_ACCENT='\033[1;37m'; C_TEXT='\033[0;36m'; C_BAR='\033[1;34m' ;;
    "gruvbox")  C_MAIN='\033[0;33m'; C_ACCENT='\033[1;32m'; C_TEXT='\033[1;37m'; C_BAR='\033[0;32m' ;;
    "synth")    C_MAIN='\033[1;35m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;36m' ;;
    "toxic")    C_MAIN='\033[1;92m'; C_ACCENT='\033[1;93m'; C_TEXT='\033[1;97m'; C_BAR='\033[1;92m' ;;
    "solar")    C_MAIN='\033[1;34m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;33m' ;;
    "royal")    C_MAIN='\033[1;35m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;33m' ;;
    *)          C_MAIN='\033[1;34m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;34m' ;;
esac

RESET='\033[0m'; C_LABEL='\033[0;90m'; C_SUCCESS='\033[1;32m'; C_ALERT='\033[1;91m'

# --- 2. INITIALIZATION & DEPENDENCIES ---
function init_sys() {
    if ! command -v zip &> /dev/null || ! command -v bc &> /dev/null || ! command -v figlet &> /dev/null || ! command -v vnstat &> /dev/null; then
        echo -e "${C_LABEL}Initializing system modules...${RESET}"
        apt-get update >/dev/null 2>&1
        apt-get install zip unzip curl bc net-tools vnstat figlet -y >/dev/null 2>&1
        systemctl enable --now vnstat >/dev/null 2>&1
    fi
    
    # PERMISSION FIX: Ensure vnstat can write to its own DB
    if [ -d "/var/lib/vnstat" ]; then
        chown -R vnstat:vnstat /var/lib/vnstat >/dev/null 2>&1
        chmod -R 775 /var/lib/vnstat >/dev/null 2>&1
    fi
}
init_sys

# --- GATHER INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)

# --- FIND NAME SERVER (NS) ---
if [ -f "/etc/xray/dns" ]; then NS_DOMAIN=$(cat /etc/xray/dns);
elif [ -f "/root/nsdomain" ]; then NS_DOMAIN=$(cat /root/nsdomain);
else NS_DOMAIN="Not Set"; fi

# =========================================================
# 3. BACKGROUND WATCHDOG (Preserved)
# =========================================================
function start_backup_watchdog() {
    (
        SUM_BEFORE=$(md5sum /etc/passwd /etc/xray/config.json 2>/dev/null)
        for i in {1..18}; do
            sleep 5
            SUM_AFTER=$(md5sum /etc/passwd /etc/xray/config.json 2>/dev/null)
            if [[ "$SUM_BEFORE" != "$SUM_AFTER" ]]; then
                STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off")
                if [[ "$STATUS" == "on" ]]; then
                    mkdir -p /root/backup_edu/ssh_backup
                    mkdir -p /root/backup_edu/xray_backup
                    cp -r /etc/xray/* /root/backup_edu/xray_backup/ 2>/dev/null
                    cp /etc/passwd /etc/shadow /etc/group /etc/gshadow /root/backup_edu/ssh_backup/ 2>/dev/null
                    rm -f /tmp/vpn_backup.zip
                    zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
                    chmod 777 /tmp/vpn_backup.zip
                    rm -rf /root/backup_edu

                    TYPE=$(cat /etc/edu_backup_type 2>/dev/null)
                    CAPTION="Auto-Backup [New User Event] | IP: $MYIP"
                    FILE="/tmp/vpn_backup.zip"

                    if [[ "$TYPE" == "discord" ]]; then
                        URL=$(cat /etc/edu_backup_dc_url)
                        curl -s -X POST -H "User-Agent: Mozilla/5.0" -F "payload_json={\"content\": \"$CAPTION\"}" -F "file=@$FILE" "$URL" > /dev/null
                    elif [[ "$TYPE" == "telegram" ]]; then
                        T=$(cat /etc/edu_backup_tg_token); I=$(cat /etc/edu_backup_tg_id)
                        curl -s -F document=@"$FILE" -F caption="$CAPTION" "https://api.telegram.org/bot$T/sendDocument?chat_id=$I" > /dev/null
                    fi
                fi
                exit 0
            fi
        done
    ) & > /dev/null 2>&1
}

# =========================================================
# 4. RESTORED v12.9 SELECTORS
# =========================================================

function create_account_selector() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           SELECT PROTOCOL TYPE${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] VMess Account"; echo -e "  [2] VLESS Account"; echo -e "  [3] Trojan Account"; echo -e ""; echo -e "  [0] Cancel"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Select > " p_opt
    case $p_opt in 1) clear ; start_backup_watchdog ; add-ws ;; 2) clear ; start_backup_watchdog ; add-vless ;; 3) clear ; start_backup_watchdog ; add-tr ;; 0) menu ;; *) menu ;; esac
}

function renew_selector() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           RENEW USER ACCOUNT${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] Renew SSH / WS"; echo -e "${C_LABEL}──────────────────────────────────────────────────${RESET}"; echo -e "  [2] Renew VMess"; echo -e "  [3] Renew VLESS"; echo -e "  [4] Renew Trojan"; echo -e ""; echo -e "  [0] Cancel"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Select > " r_opt
    case $r_opt in 1) clear ; start_backup_watchdog ; renew ;; 2) clear ; start_backup_watchdog ; renew-ws ;; 3) clear ; start_backup_watchdog ; renew-vless ;; 4) clear ; start_backup_watchdog ; renew-tr ;; 0) menu ;; *) menu ;; esac
}

# =========================================================
# 5. CORE FUNCTIONS (v12.9 Logic)
# =========================================================
function restart_services_pro() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           RESTARTING SYSTEM SERVICES${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    function restart_visual() { svc=$1; echo -ne "  Restarting $svc... "; systemctl restart $svc; if [ $? -eq 0 ]; then echo -e "${C_SUCCESS}DONE${RESET}"; else echo -e "${C_ALERT}FAIL${RESET}"; fi; sleep 0.5; }
    restart_visual "ssh"; restart_visual "xray"; restart_visual "nginx"; restart_visual "cron"
    echo -e ""; echo -e "${C_SUCCESS}  All services refreshed.${RESET}"; sleep 2; menu
}

function list_active() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "             ${C_TEXT}ACTIVE USER DATABASE${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_ACCENT} SSH ACCOUNTS${RESET}"; today=$(date +%s)
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" == *"never"* ]]; then echo -e "  ● ${C_SUCCESS}$username${RESET} (Lifetime)"; else
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -ge $today ]]; then echo -e "  ● ${C_SUCCESS}$username${RESET} ($exp_date)"; fi
            fi
        fi
    done < /etc/passwd
    echo ""; echo -e "${C_ACCENT} XRAY ACCOUNTS${RESET}"
    if [ -f "/etc/xray/config.json" ]; then grep '"email":' /etc/xray/config.json | cut -d '"' -f 4 | sed "s/^/  ● ${C_SUCCESS}/" | sed "s/$/${RESET}/"; fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; read -n 1 -s -r -p "Key..."; menu
}

function list_expired() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "             ${C_ALERT}EXPIRED USER ACCOUNTS${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    today=$(date +%s); count=0
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" != *"never"* ]]; then
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -lt $today && -n "$exp_sec" ]]; then echo -e "  ● ${C_ALERT}$username${RESET} (Expired: $exp_date)"; ((count++)); fi
            fi
        fi
    done < /etc/passwd
    if [[ $count -eq 0 ]]; then echo -e "  ${C_SUCCESS}(No expired SSH users found)${RESET}"; fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; read -n 1 -s -r -p "Key..."; menu
}

function restore_configs() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "             ${C_ACCENT}RESTORE BACKUP${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Upload 'vpn_backup.zip' to /tmp/. Ready? [y/n]: " ans; if [[ "$ans" != "y" ]]; then menu; fi
    if [ ! -f "/tmp/vpn_backup.zip" ]; then echo -e "${C_ALERT}File not found!${RESET}"; sleep 2; menu; fi
    echo -e "${C_LABEL}Restoring...${RESET}"; mkdir -p /root/restore_temp; unzip -o /tmp/vpn_backup.zip -d /root/restore_temp > /dev/null 2>&1
    rm -rf /etc/xray/*; cp -r /root/restore_temp/root/backup_edu/xray_backup/* /etc/xray/ 2>/dev/null
    cp /root/restore_temp/root/backup_edu/ssh_backup/* /etc/ 2>/dev/null; cp /root/restore_temp/ssh_backup/* /etc/ 2>/dev/null; rm -rf /root/restore_temp
    systemctl restart ssh sshd xray; echo -e "${C_SUCCESS}Restore Complete!${RESET}"; sleep 2; menu
}

function auto_reboot() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "             ${C_TEXT}AUTO-REBOOT SCHEDULER${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] Enable Daily (00:00)   [2] Disable"; read -p "Select > " x
    if [[ "$x" == "1" ]]; then echo "0 0 * * * root reboot" > /etc/cron.d/auto_reboot_edu; echo -e "${C_SUCCESS}Enabled!${RESET}"
    elif [[ "$x" == "2" ]]; then rm -f /etc/cron.d/auto_reboot_edu; echo -e "${C_ALERT}Disabled!${RESET}"; fi; sleep 1; menu
}

function change_banner() { clear; if ! command -v nano &> /dev/null; then apt-get install nano -y > /dev/null 2>&1; fi; nano /etc/issue.net; echo -e "${C_LABEL}Restarting SSH...${RESET}"; service ssh restart; service sshd restart; menu; }
function change_domain() { clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "Current: $DOMAIN"; read -p "New Domain: " d; if [[ -n "$d" ]]; then echo "$d" > /etc/xray/domain; echo "$d" > /root/domain; echo -e "${C_LABEL}Restarting Services...${RESET}"; systemctl restart nginx xray; echo -e "${C_SUCCESS}Updated!${RESET}"; fi; sleep 1; menu; }
function change_ns() { clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "Current NS: $NS_DOMAIN"; read -p "New NS: " n; if [[ -n "$n" ]]; then echo "$n" > /etc/xray/dns; echo "$n" > /root/nsdomain; echo -e "${C_SUCCESS}Updated!${RESET}"; fi; sleep 1; menu; }

# =========================================================
# 6. VISUAL UTILITIES
# =========================================================

function draw_bar() {
    local pct=$1; local width=18; local fill=$(echo "$pct / 100 * $width" | bc -l | awk '{printf("%d",$1 + 0.5)}')
    printf "["; for ((i=0; i<fill; i++)); do printf "${C_BAR}█${RESET}"; done; for ((i=fill; i<width; i++)); do printf "${C_LABEL}░${RESET}"; done; printf "] ${pct}%%"
}

function live_traffic_monitor() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           LIVE TRAFFIC MONITOR (Ctrl+C to Exit)${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "  Monitoring Interface: eth0..."
    IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    while true; do
        R1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
        sleep 1; R2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
        RKBPS=$(expr $R2 - $R1); RKBPS=$(expr $RKBPS / 1024); TKBPS=$(expr $T2 - $T1); TKBPS=$(expr $TKBPS / 1024)
        echo -ne "\r  ${C_SUCCESS}↓ DOWN:${RESET} ${RKBPS} KB/s    ${C_ALERT}↑ UP:${RESET} ${TKBPS} KB/s   "
    done
}

function generate_id_card() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           USER ID CARD GENERATOR${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "Enter username:"; read -p "Username: " user
    if ! id "$user" &>/dev/null; then echo -e "${C_ALERT}User not found!${RESET}"; sleep 2; menu; fi
    EXP=$(chage -l "$user" | grep "Account expires" | cut -d: -f2)
    clear
    echo -e "${C_MAIN}╔════════════════════════════════════════════╗${RESET}"; echo -e "${C_MAIN}║${RESET}           ${C_TEXT}PREMIUM VPN ACCESS${RESET}               ${C_MAIN}║${RESET}"; echo -e "${C_MAIN}╠════════════════════════════════════════════╣${RESET}"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}Username :${RESET} ${C_ACCENT}$user${RESET}"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}Password :${RESET} (Hidden/Encrypted)"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}Expiry   :${RESET} $EXP"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}Host IP  :${RESET} $MYIP"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}ISP      :${RESET} $ISP"; echo -e "${C_MAIN}╠════════════════════════════════════════════╣${RESET}"; echo -e "${C_MAIN}║${RESET}         ${C_SUCCESS}● STATUS: ACTIVE${RESET}                   ${C_MAIN}║${RESET}"; echo -e "${C_MAIN}╚════════════════════════════════════════════╝${RESET}"; echo -e ""
    read -n 1 -s -r -p "Key..."; menu
}

function detailed_status() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           SYSTEM DIAGNOSTICS${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    if systemctl is-active --quiet ssh; then echo -e "  SSH Service: ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  SSH Service: ${C_ALERT}STOPPED${RESET}"; fi
    if systemctl is-active --quiet xray; then echo -e "  Xray Core  : ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  Xray Core  : ${C_ALERT}STOPPED${RESET}"; fi
    if systemctl is-active --quiet nginx; then echo -e "  Nginx Web  : ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  Nginx Web  : ${C_ALERT}STOPPED${RESET}"; fi
    echo -e ""; echo -e "${C_ACCENT}ACTIVE PROTOCOLS:${RESET}"
    CONFIG="/etc/xray/config.json"
    if [ -f "$CONFIG" ]; then
        if grep -q "vmess" "$CONFIG"; then echo -e "  VMess      : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  VMess      : ${C_LABEL}MISSING${RESET}"; fi
        if grep -q "vless" "$CONFIG"; then echo -e "  VLESS      : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  VLESS      : ${C_LABEL}MISSING${RESET}"; fi
        if grep -q "trojan" "$CONFIG"; then echo -e "  Trojan     : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  Trojan     : ${C_LABEL}MISSING${RESET}"; fi
    fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; read -n 1 -s -r -p "Key..."; menu
}

# =========================================================
# 7. SETTINGS & THEMES (RESTORED & EXPANDED)
# =========================================================

function visual_settings() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           VISUAL PREFERENCES STUDIO${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_ACCENT} [A] COLOR THEMES${RESET}"
    echo -e "  [01] Corporate Blue   [06] Ocean Teal     [11] Solarized"
    echo -e "  [02] Hacker Green     [07] Retro Amber    [12] Gruvbox"
    echo -e "  [03] Cyber Purple     [08] Monochrome     [13] Synthwave"
    echo -e "  [04] Admin Red        [09] Dracula        [14] Toxic Lime"
    echo -e "  [05] Luxury Gold      [10] Nord Ice       [15] Royal Gold"
    echo -e ""
    echo -e "${C_ACCENT} [B] UNICODE FONT STYLE${RESET}"
    echo -e "  [21] Normal       [22] 𝙼𝚘𝚗𝚘      [23] ℍ𝕖𝕝𝕝𝕠     [24] 𝕳𝖊𝖑𝖑𝖔"
    echo -e "  [25] ℋ𝒾           [26] ʜᴇʟʟᴏ     [27] 𝓗𝓲        [28] 🄷🄸"
    echo -e "  [29] Ⓗⓘ          [30] Ｈｉ       [31] 𝐇𝐢        [32] 𝗛𝗶"
    echo -e "  [33] 𝐻𝑖"
    echo -e ""
    echo -e "${C_ACCENT} [C] FONT SCOPE${RESET}"
    echo -e "  [91] Banner Only (Safe)  [92] Full Interface (Max)"
    echo -e ""
    read -p "Select > " v_opt
    
    # Logic for Fonts & Themes
    case $v_opt in
        1|01) echo "blue" > /etc/edu_theme ;; 2|02) echo "green" > /etc/edu_theme ;; 3|03) echo "purple" > /etc/edu_theme ;; 4|04) echo "red" > /etc/edu_theme ;; 5|05) echo "gold" > /etc/edu_theme ;;
        6|06) echo "ocean" > /etc/edu_theme ;; 7|07) echo "retro" > /etc/edu_theme ;; 8|08) echo "mono" > /etc/edu_theme ;; 9|09) echo "dracula" > /etc/edu_theme ;; 10) echo "nord" > /etc/edu_theme ;;
        11) echo "solar" > /etc/edu_theme ;; 12) echo "gruvbox" > /etc/edu_theme ;; 13) echo "synth" > /etc/edu_theme ;; 14) echo "toxic" > /etc/edu_theme ;; 15) echo "royal" > /etc/edu_theme ;;
        
        21) echo "normal" > /etc/edu_ufont ;;
        22) echo "mono" > /etc/edu_ufont ;;
        23) echo "double" > /etc/edu_ufont ;; 
        24) echo "fraktur" > /etc/edu_ufont ;;
        25) echo "script" > /etc/edu_ufont ;;
        26) echo "small" > /etc/edu_ufont ;; 
        27) echo "bold_script" > /etc/edu_ufont ;;
        28) echo "squared" > /etc/edu_ufont ;;
        29) echo "bubble" > /etc/edu_ufont ;;
        30) echo "wide" > /etc/edu_ufont ;;
        31) echo "serif_bold" > /etc/edu_ufont ;;
        32) echo "sans_bold" > /etc/edu_ufont ;;
        33) echo "italic" > /etc/edu_ufont ;;
        
        91) echo "banner" > /etc/edu_scope ;;
        92) echo "all" > /etc/edu_scope ;;
        0) menu ;;
    esac
    echo -e "${C_SUCCESS}Updating Visuals...${RESET}"; sleep 1; exec "$0"
}

function backup_settings() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}       CLOUD SYNC CONFIGURATION${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off"); TYPE=$(cat /etc/edu_backup_type 2>/dev/null || echo "none")
    if [[ "$STATUS" == "on" ]]; then S_TXT="${C_SUCCESS}● ENABLED${RESET}"; else S_TXT="${C_ALERT}● DISABLED${RESET}"; fi
    echo -e "  Status: $S_TXT    Method: ${C_ACCENT}${TYPE^^}${RESET}"; echo -e "${C_LABEL}──────────────────────────────────────────────────${RESET}"
    echo -e "  [1] Enable Sync        [3] Setup Telegram"; echo -e "  [2] Disable Sync       [4] Setup Discord"; echo -e "  [5] ${C_ACCENT}Test Connection Now${RESET}"; echo -e ""; echo -e "  [0] Return"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Select > " b_opt
    case $b_opt in
        1) echo "on" > /etc/edu_backup_status; backup_settings ;; 2) echo "off" > /etc/edu_backup_status; backup_settings ;;
        3) clear; read -p "Token: " t; read -p "Chat ID: " i; echo "$t" > /etc/edu_backup_tg_token; echo "$i" > /etc/edu_backup_tg_id; echo "telegram" > /etc/edu_backup_type; backup_settings ;;
        4) clear; read -p "Webhook: " d; echo "$d" > /etc/edu_backup_dc_url; echo "discord" > /etc/edu_backup_type; backup_settings ;;
        5) auto_backup "force"; read -n 1 -s -r -p "Key..."; backup_settings ;; 0) menu ;;
    esac
}

function auto_backup() {
    MODE=$1
    if [[ "$MODE" == "force" ]]; then
        mkdir -p /root/backup_edu/ssh_backup; cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null; cp /etc/passwd /etc/shadow /etc/group /etc/gshadow /root/backup_edu/ssh_backup/ 2>/dev/null; rm -f /tmp/vpn_backup.zip; zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1; rm -rf /root/backup_edu
        TYPE=$(cat /etc/edu_backup_type 2>/dev/null); FILE="/tmp/vpn_backup.zip"; CAPTION="Manual Test: $(date) | IP: $MYIP"
        if [[ "$TYPE" == "discord" ]]; then URL=$(cat /etc/edu_backup_dc_url); curl -s -X POST -H "User-Agent: Mozilla/5.0" -F "payload_json={\"content\": \"$CAPTION\"}" -F "file=@$FILE" "$URL" > /dev/null; echo -e "${C_SUCCESS}Sent to Discord.${RESET}"; elif [[ "$TYPE" == "telegram" ]]; then T=$(cat /etc/edu_backup_tg_token); I=$(cat /etc/edu_backup_tg_id); curl -s -F document=@"$FILE" -F caption="$CAPTION" "https://api.telegram.org/bot$T/sendDocument?chat_id=$I" > /dev/null; echo -e "${C_SUCCESS}Sent to Telegram.${RESET}"; fi; sleep 1
    fi
}

# =========================================================
# 8. DASHBOARD
# =========================================================

function show_dashboard() {
    RAM_TOTAL=$(free -m | awk 'NR==2{print $2}'); RAM_USED=$(free -m | awk 'NR==2{print $3}'); RAM_PCT=$(echo "$RAM_USED / $RAM_TOTAL * 100" | bc -l | awk '{printf("%d",$1)}')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | tr -d ' '); LOAD_PCT=$(echo "$LOAD * 100 / 4" | bc -l | awk '{printf("%d",$1)}'); if [ "$LOAD_PCT" -gt 100 ]; then LOAD_PCT=100; fi
    SERVER_TIME=$(date "+%H:%M:%S"); LAST_LOGIN=$(last -n 1 -a | head -n 1 | awk '{print $10}')
    if systemctl is-active --quiet ssh; then S_SSH="${C_SUCCESS}ONLINE${RESET}"; else S_SSH="${C_ALERT}OFFLINE${RESET}"; fi
    if systemctl is-active --quiet xray; then S_XRAY="${C_SUCCESS}ONLINE${RESET}"; else S_XRAY="${C_ALERT}OFFLINE${RESET}"; fi
    if systemctl is-active --quiet nginx; then S_NGINX="${C_SUCCESS}ONLINE${RESET}"; else S_NGINX="${C_ALERT}OFFLINE${RESET}"; fi

    # --- FINALIZED DATA USAGE LOGIC ---
    IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    
    # AUTO-FIX: Force create vnstat DB if missing (Fixes "No Data")
    if command -v vnstat &> /dev/null; then
        # Check if interface is tracked. If not, add it.
        # Quiet check to see if database actually has data or exists
        if ! vnstat -i $IFACE &>/dev/null; then
             vnstat --add -i $IFACE >/dev/null 2>&1
             systemctl restart vnstat >/dev/null 2>&1
             # Wait 1 sec for service to spin up
             sleep 1
        fi
        
        # Force Update
        vnstat -u -i $IFACE >/dev/null 2>&1
        
        # Robust Parsing - Supports vnstat v1.x (Date format) and v2.x (ISO format)
        D_DATE_1=$(date +%Y-%m-%d) # v2.x style
        D_DATE_2=$(date +%m/%d/%y) # v1.x style
        
        # 1. Try to get Daily (grep for 'today' OR date format)
        RAW_D=$(vnstat -d -i $IFACE 2>/dev/null | grep -E "today|$D_DATE_1|$D_DATE_2" | head -n 1 | awk '{print $2 $3 " / " $5 $6}')
        
        # Fallback if grep fails (grab last line)
        if [[ -z "$RAW_D" ]]; then
             RAW_D=$(vnstat -d -i $IFACE 2>/dev/null | tail -n 3 | grep -v "estimated" | tail -n 1 | awk '{print $2 $3 " / " $5 $6}')
        fi

        # 2. Try to get Monthly
        RAW_M=$(vnstat -m -i $IFACE 2>/dev/null | grep -w "$(date +%b)" | awk '{print $3 $4 " / " $6 $7}')
        if [[ -z "$RAW_M" ]]; then
             RAW_M=$(vnstat -m -i $IFACE 2>/dev/null | tail -n 3 | grep -v "estimated" | tail -n 1 | awk '{print $3 $4 " / " $6 $7}')
        fi

        # Final Formatting
        if [[ -n "$RAW_D" && "$RAW_D" != "/" ]]; then DATA_D="$RAW_D"; else DATA_D="No Data"; fi
        if [[ -n "$RAW_M" && "$RAW_M" != "/" ]]; then DATA_M="$RAW_M"; else DATA_M="No Data"; fi
    else
        DATA_D="Err: No vnStat"
        DATA_M="Err: No vnStat"
    fi

    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_TEXT}  $T_HEADER${RESET}            ${C_LABEL}v17.0 ULT${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "$L_HOST" "$DOMAIN" "$L_TIME" "$SERVER_TIME"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "$L_IP" "$MYIP" "$L_ISP" "$ISP"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "$L_NS" "$NS_DOMAIN" "$L_SEC" "$LAST_LOGIN"
    echo -e "${C_LABEL}──────────────────────────────────────────────────────────${RESET}"
    printf "  ${C_LABEL}%-8s:${RESET} ${C_ACCENT}%-20s${RESET} ${C_LABEL}%-8s:${RESET} ${C_ACCENT}%s${RESET}\n" "$L_DAY" "$DATA_D" "$L_MONTH" "$DATA_M"
    echo -e "${C_LABEL}──────────────────────────────────────────────────────────${RESET}"
    echo -ne "  ${C_LABEL}$L_RAM :${RESET} "; draw_bar $RAM_PCT; echo ""
    echo -ne "  ${C_LABEL}$L_CPU :${RESET} "; draw_bar $LOAD_PCT; echo ""
    echo -e ""; echo -e "  ${C_LABEL}$L_SSH :${RESET} $S_SSH       ${C_LABEL}$L_XRAY :${RESET} $S_XRAY      ${C_LABEL}$L_WEB :${RESET} $S_NGINX"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

function show_menu() {
    show_dashboard
    echo -e "  ${C_ACCENT}$T_U_MGMT${RESET}"
    echo -e "  [01] Create User Account   [04] Monitor Users"
    echo -e "  [02] Create Xray Account   [05] List Active Users"
    echo -e "  [03] Renew User Services   [06] List Expired"
    echo -e "  [07] Lock/Unlock User"
    echo -e ""
    echo -e "  ${C_ACCENT}$T_S_OPS${RESET}"
    echo -e "  [08] System Diagnostics    [12] Restart Services"
    echo -e "  [09] Speedtest Benchmark   [13] Auto-Reboot Task"
    echo -e "  [10] Reboot Server         [14] Manual Backup"
    echo -e "  [11] Clear RAM Cache       [15] Restore Backup"
    echo -e ""
    echo -e "  ${C_ACCENT}$T_CONFIG${RESET}"
    echo -e "  [16] Update Domain Host    [20] Live Traffic Monitor"
    echo -e "  [17] Update NameServer     [21] User ID Card Gen"
    echo -e "  [18] SSH Banner Editor     [22] Settings (Theme/UI)"
    echo -e "  [19] Cloud Backup Setup"
    echo -e ""
    echo -e "  [00] $T_EXIT"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "  Enter Selection » " opt

    case $opt in
        01|1) clear; start_backup_watchdog; usernew ;;
        02|2) create_account_selector ;;
        03|3) renew_selector ;;
        04|4) clear; cek ;;
        05|5) list_active ;;
        06|6) list_expired ;;
        07|7) clear; member ;;
        08|8) detailed_status ;;
        09|9) clear; speedtest ;;
        10|10) reboot ;;
        11|11) 
            clear
            echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo -e "${C_TEXT}           RAM CACHE CLEANER${RESET}"
            echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
            echo -ne "  ${C_LABEL}Syncing Data...${RESET} "
            sync
            echo -e "${C_SUCCESS}OK${RESET}"
            echo -ne "  ${C_LABEL}Dropping Caches...${RESET} "
            echo 3 > /proc/sys/vm/drop_caches
            echo -e "${C_SUCCESS}DONE${RESET}"
            sleep 2
            menu 
            ;;
        12|12) restart_services_pro ;;
        13|13) auto_reboot ;; 
        14|14) auto_backup "force"; menu ;;
        15|15) restore_configs ;;
        16|16) change_domain ;;
        17|17) change_ns ;;
        18|18) change_banner ;;
        19|19) backup_settings ;;
        20|20) live_traffic_monitor ;;
        21|21) generate_id_card ;;
        22|22) visual_settings ;;
        00|0) exit 0 ;;
        *) menu ;;
    esac
}

function menu() { show_menu; }
show_menu
