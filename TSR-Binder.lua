script_name("TSR-Binder")
script_author("Guonith & !.Dyshno")
script_version("v1.9.1")
SCRIPT_VERSION = "v1.9.1"  
SCRIPT_ACTIVE  = true  

require "lib.moonloader"
imgui    = require "mimgui"
encoding = require "encoding"
json     = require "dkjson"
vkeys    = require "vkeys"
ffi      = require "ffi"
iconv    = require "iconv"
sampev   = require "lib.samp.events"
local hasRequests, requests = pcall(require, "requests")

_cv = iconv.new("CP1251", "UTF-8")
_cv_u = iconv.new("UTF-8", "CP1251")
local function toChat(s)
  if not s or s == "" then return s end
  return _cv:iconv(s) or s
end
local function u8(s) return s end

--  настройки
TOGGLE_KEY    = vkeys.VK_HOME
capturingToggleKey = false  
DEFAULT_DELAY = 800
SAVE_FILE  = ""
AUTO_FILE  = ""
CHEAT_FILE = ""
NOTES_FILE = ""
TIME_FILE  = ""
LOG_FILE   = ""
local RADIO_FILE = ""
local LOG_READABLE_FILE = ""
local RADIO_READABLE_FILE = ""
local UPDATE_METADATA_URL = ""
local UPDATE_HTTP_HEADERS = {
  ["User-Agent"] = "TSR-Binder-Updater",
  ["Cache-Control"] = "no-cache",
}
BUF           = 256

KEY_MAP = {
  F1=vkeys.VK_F1,  F2=vkeys.VK_F2,  F3=vkeys.VK_F3,  F4=vkeys.VK_F4,
  F5=vkeys.VK_F5,  F6=vkeys.VK_F6,  F7=vkeys.VK_F7,  F8=vkeys.VK_F8,
  F9=vkeys.VK_F9,  F10=vkeys.VK_F10, F11=vkeys.VK_F11, F12=vkeys.VK_F12,
  NUMPAD0=vkeys.VK_NUMPAD0, NUMPAD1=vkeys.VK_NUMPAD1, NUMPAD2=vkeys.VK_NUMPAD2,
  NUMPAD3=vkeys.VK_NUMPAD3, NUMPAD4=vkeys.VK_NUMPAD4, NUMPAD5=vkeys.VK_NUMPAD5,
  NUMPAD6=vkeys.VK_NUMPAD6, NUMPAD7=vkeys.VK_NUMPAD7, NUMPAD8=vkeys.VK_NUMPAD8,
  NUMPAD9=vkeys.VK_NUMPAD9,
  INSERT=vkeys.VK_INSERT, DELETE=vkeys.VK_DELETE, END=vkeys.VK_END,
  PGUP=vkeys.VK_PRIOR, PGDOWN=vkeys.VK_NEXT,
  UP=vkeys.VK_UP, DOWN=vkeys.VK_DOWN, LEFT=vkeys.VK_LEFT, RIGHT=vkeys.VK_RIGHT,
  A=65,B=66,C=67,D=68,E=69,F=70,G=71,H=72,I=73,J=74,K=75,L=76,
  M=77,N=78,O=79,P=80,Q=81,R=82,S=83,T=84,U=85,V=86,W=87,X=88,Y=89,Z=90,
  ["0"]=48,["1"]=49,["2"]=50,["3"]=51,["4"]=52,
  ["5"]=53,["6"]=54,["7"]=55,["8"]=56,["9"]=57,
}

--  система тем(ебатория я хочу плакать)
THEMES = {
  [1] = { 
    name="Classic",
    winbg    ={0.05,0.05,0.07}, titlehi={0.50,0.22,0.00}, titlebg={0.35,0.15,0.00},
    frame    ={0.10,0.10,0.15}, frameh ={0.16,0.16,0.24},
    btn      ={0.50,0.22,0.00}, btnh   ={0.78,0.38,0.00}, btna   ={1.00,0.55,0.00},
    sep      ={0.90,0.50,0.00},
    tabact   ={0.55,0.25,0.00}, tabacth={0.70,0.35,0.00},
    tabinact ={0.18,0.18,0.22}, tabinh ={0.28,0.28,0.35},
    cheatbtn ={0.25,0.20,0.40}, cheatbtnh={0.42,0.32,0.65}, cheatbtna={0.55,0.42,0.80},
    neutral  ={0.14,0.14,0.22}, neutralh ={0.28,0.28,0.42},
    cneutral ={0.10,0.18,0.32}, cneutralh={0.18,0.32,0.55},
    aneutral ={0.12,0.18,0.28}, aneutralh={0.22,0.32,0.48},
    btnpos   ={0.08,0.32,0.08}, btnposh  ={0.12,0.52,0.12},
    btnpos2  ={0.08,0.40,0.08}, btnpos2h ={0.12,0.60,0.12},
    btnpos3  ={0.08,0.34,0.08}, btnpos3h ={0.12,0.54,0.12},
    btnneg   ={0.40,0.05,0.05}, btnnegh  ={0.70,0.10,0.10},
    btnneg2  ={0.55,0.10,0.10}, btnneg2h ={0.80,0.15,0.15},
    btnneg3  ={0.28,0.08,0.08}, btnneg3h ={0.55,0.12,0.12},
    btnneg4  ={0.25,0.10,0.10}, btnneg4h ={0.45,0.15,0.15},
    btnneg5  ={0.60,0.10,0.10}, btnneg5h ={0.80,0.15,0.15},
    btnstop  ={0.20,0.20,0.35}, btnsoph  ={0.30,0.30,0.55},
    btnlink  ={0.10,0.25,0.40}, btnlinkh ={0.15,0.38,0.60},
    ed_winbg ={0.06,0.06,0.09}, ed_titlehi={0.10,0.32,0.10}, ed_titlebg={0.07,0.22,0.07},
    ed_sep   ={0.20,0.60,0.20},
    au_winbg ={0.06,0.06,0.10}, au_titlehi={0.08,0.20,0.45}, au_titlebg={0.06,0.14,0.32},
    au_frame ={0.10,0.10,0.16}, au_frameh ={0.16,0.16,0.26},
    au_sep   ={0.20,0.40,0.80},
    au_btn   ={0.08,0.22,0.48}, au_btnh  ={0.12,0.32,0.68},
    au_stop  ={0.60,0.10,0.10}, au_stoph ={0.80,0.15,0.15},
    au_edit  ={0.20,0.20,0.35}, au_edith ={0.30,0.30,0.55},
    ch_winbg ={0.07,0.05,0.12}, ch_titlehi={0.28,0.18,0.50}, ch_titlebg={0.20,0.13,0.38},
    ch_frame ={0.08,0.06,0.14}, ch_frameh ={0.14,0.10,0.22},
    ch_btn   ={0.25,0.18,0.45}, ch_btnh  ={0.40,0.28,0.68},
    ch_scroll={0.05,0.04,0.09}, ch_grab  ={0.30,0.22,0.52},
    ch_tabact={0.40,0.28,0.68}, ch_tabacth={0.50,0.36,0.80},
    ch_tabinact={0.14,0.10,0.22}, ch_tabhh={0.24,0.18,0.38},
    ch_sav   ={0.08,0.34,0.08}, ch_savh  ={0.12,0.54,0.12},
    ch_cancel={0.28,0.08,0.08}, ch_cancelh={0.55,0.12,0.12},
    ch_hint  ={0.18,0.14,0.32}, ch_hinth ={0.35,0.26,0.58},
    ch_edit  ={0.25,0.18,0.45}, ch_edith ={0.40,0.28,0.68},
    ch_framebg={0.06,0.05,0.10}, ch_framebg2={0.06,0.05,0.12},
    ch_framebgh={0.10,0.08,0.18}, ch_framebga={0.12,0.09,0.22},
  },
  [2] = { 
    name="Deep Purple",
    winbg    ={0.102,0.059,0.180}, titlehi={0.239,0.082,0.408}, titlebg={0.102,0.059,0.180},
    frame    ={0.130,0.070,0.220}, frameh ={0.165,0.090,0.282},
    btn      ={0.294,0.000,0.510}, btnh   ={0.416,0.051,0.678}, btna   ={0.541,0.169,0.886},
    sep      ={0.227,0.122,0.420},
    tabact   ={0.541,0.169,0.886}, tabacth={0.416,0.051,0.678},
    tabinact ={0.165,0.090,0.282}, tabinh ={0.227,0.122,0.420},
    cheatbtn ={0.294,0.000,0.510}, cheatbtnh={0.416,0.051,0.678}, cheatbtna={0.541,0.169,0.886},
    neutral  ={0.165,0.090,0.282}, neutralh ={0.227,0.122,0.420},
    cneutral ={0.165,0.090,0.282}, cneutralh={0.294,0.000,0.510},
    aneutral ={0.165,0.090,0.282}, aneutralh={0.294,0.000,0.510},
    btnpos   ={0.294,0.000,0.510}, btnposh  ={0.416,0.051,0.678},
    btnpos2  ={0.294,0.000,0.510}, btnpos2h ={0.416,0.051,0.678},
    btnpos3  ={0.294,0.000,0.510}, btnpos3h ={0.416,0.051,0.678},
    btnneg   ={0.35,0.04,0.04},  btnnegh  ={0.65,0.08,0.08},
    btnneg2  ={0.35,0.04,0.04},  btnneg2h ={0.65,0.08,0.08},
    btnneg3  ={0.28,0.04,0.04},  btnneg3h ={0.50,0.06,0.06},
    btnneg4  ={0.28,0.04,0.04},  btnneg4h ={0.50,0.06,0.06},
    btnneg5  ={0.35,0.04,0.04},  btnneg5h ={0.65,0.08,0.08},
    btnstop  ={0.165,0.090,0.282}, btnsoph={0.227,0.122,0.420},
    btnlink  ={0.165,0.090,0.282}, btnlinkh={0.294,0.000,0.510},
    ed_winbg ={0.102,0.059,0.180}, ed_titlehi={0.165,0.090,0.282}, ed_titlebg={0.102,0.059,0.180},
    ed_sep   ={0.227,0.122,0.420},
    au_winbg ={0.102,0.059,0.180}, au_titlehi={0.165,0.090,0.282}, au_titlebg={0.102,0.059,0.180},
    au_frame ={0.130,0.070,0.220}, au_frameh ={0.165,0.090,0.282},
    au_sep   ={0.227,0.122,0.420},
    au_btn   ={0.294,0.000,0.510}, au_btnh  ={0.416,0.051,0.678},
    au_stop  ={0.35,0.04,0.04},   au_stoph ={0.65,0.08,0.08},
    au_edit  ={0.165,0.090,0.282}, au_edith ={0.227,0.122,0.420},
    ch_winbg ={0.102,0.059,0.180}, ch_titlehi={0.165,0.090,0.282}, ch_titlebg={0.102,0.059,0.180},
    ch_frame ={0.130,0.070,0.220}, ch_frameh ={0.165,0.090,0.282},
    ch_btn   ={0.294,0.000,0.510}, ch_btnh  ={0.416,0.051,0.678},
    ch_scroll={0.102,0.059,0.180}, ch_grab  ={0.294,0.000,0.510},
    ch_tabact={0.541,0.169,0.886}, ch_tabacth={0.416,0.051,0.678},
    ch_tabinact={0.165,0.090,0.282}, ch_tabhh={0.227,0.122,0.420},
    ch_sav   ={0.294,0.000,0.510}, ch_savh  ={0.416,0.051,0.678},
    ch_cancel={0.28,0.04,0.04},   ch_cancelh={0.50,0.06,0.06},
    ch_hint  ={0.165,0.090,0.282}, ch_hinth ={0.227,0.122,0.420},
    ch_edit  ={0.294,0.000,0.510}, ch_edith ={0.416,0.051,0.678},
    ch_framebg={0.130,0.070,0.220}, ch_framebg2={0.130,0.070,0.220},
    ch_framebgh={0.165,0.090,0.282}, ch_framebga={0.165,0.090,0.282},
  },
  [3] = { 
    name="Dark Green",
    winbg    ={0.04,0.10,0.06}, titlehi={0.08,0.28,0.12}, titlebg={0.04,0.10,0.06},
    frame    ={0.05,0.12,0.07}, frameh ={0.06,0.18,0.09},
    btn      ={0.04,0.38,0.12}, btnh   ={0.05,0.55,0.18}, btna   ={0.10,0.72,0.25},
    sep      ={0.08,0.35,0.14},
    tabact   ={0.10,0.72,0.25}, tabacth={0.05,0.55,0.18},
    tabinact ={0.06,0.18,0.09}, tabinh ={0.08,0.28,0.12},
    cheatbtn ={0.04,0.38,0.12}, cheatbtnh={0.05,0.55,0.18}, cheatbtna={0.10,0.72,0.25},
    neutral  ={0.06,0.18,0.09}, neutralh ={0.08,0.35,0.14},
    cneutral ={0.06,0.18,0.09}, cneutralh={0.04,0.38,0.12},
    aneutral ={0.06,0.18,0.09}, aneutralh={0.04,0.38,0.12},
    btnpos   ={0.04,0.38,0.12}, btnposh  ={0.05,0.55,0.18},
    btnpos2  ={0.04,0.38,0.12}, btnpos2h ={0.05,0.55,0.18},
    btnpos3  ={0.04,0.38,0.12}, btnpos3h ={0.05,0.55,0.18},
    btnneg   ={0.35,0.04,0.04}, btnnegh  ={0.65,0.08,0.08},
    btnneg2  ={0.35,0.04,0.04}, btnneg2h ={0.65,0.08,0.08},
    btnneg3  ={0.28,0.04,0.04}, btnneg3h ={0.50,0.06,0.06},
    btnneg4  ={0.28,0.04,0.04}, btnneg4h ={0.50,0.06,0.06},
    btnneg5  ={0.35,0.04,0.04}, btnneg5h ={0.65,0.08,0.08},
    btnstop  ={0.06,0.18,0.09}, btnsoph  ={0.08,0.28,0.12},
    btnlink  ={0.06,0.18,0.09}, btnlinkh ={0.04,0.38,0.12},
    ed_winbg ={0.04,0.10,0.06}, ed_titlehi={0.06,0.18,0.09}, ed_titlebg={0.04,0.10,0.06},
    ed_sep   ={0.08,0.35,0.14},
    au_winbg ={0.04,0.10,0.06}, au_titlehi={0.06,0.18,0.09}, au_titlebg={0.04,0.10,0.06},
    au_frame ={0.05,0.12,0.07}, au_frameh ={0.06,0.18,0.09},
    au_sep   ={0.08,0.35,0.14},
    au_btn   ={0.04,0.38,0.12}, au_btnh  ={0.05,0.55,0.18},
    au_stop  ={0.35,0.04,0.04}, au_stoph ={0.65,0.08,0.08},
    au_edit  ={0.06,0.18,0.09}, au_edith ={0.08,0.28,0.12},
    ch_winbg ={0.04,0.10,0.06}, ch_titlehi={0.06,0.18,0.09}, ch_titlebg={0.04,0.10,0.06},
    ch_frame ={0.05,0.12,0.07}, ch_frameh ={0.06,0.18,0.09},
    ch_btn   ={0.04,0.38,0.12}, ch_btnh  ={0.05,0.55,0.18},
    ch_scroll={0.04,0.10,0.06}, ch_grab  ={0.04,0.38,0.12},
    ch_tabact={0.10,0.72,0.25}, ch_tabacth={0.05,0.55,0.18},
    ch_tabinact={0.06,0.18,0.09}, ch_tabhh={0.08,0.28,0.12},
    ch_sav   ={0.04,0.38,0.12}, ch_savh  ={0.05,0.55,0.18},
    ch_cancel={0.28,0.04,0.04}, ch_cancelh={0.50,0.06,0.06},
    ch_hint  ={0.06,0.18,0.09}, ch_hinth ={0.08,0.35,0.14},
    ch_edit  ={0.04,0.38,0.12}, ch_edith ={0.05,0.55,0.18},
    ch_framebg={0.05,0.12,0.07}, ch_framebg2={0.05,0.12,0.07},
    ch_framebgh={0.06,0.18,0.09}, ch_framebga={0.06,0.18,0.09},
  },
  [4] = { 
    name="Crimson",
    winbg    ={0.10,0.04,0.04}, titlehi={0.35,0.07,0.07}, titlebg={0.10,0.04,0.04},
    frame    ={0.12,0.05,0.05}, frameh ={0.20,0.05,0.05},
    btn      ={0.50,0.05,0.05}, btnh   ={0.70,0.08,0.08}, btna   ={0.90,0.15,0.15},
    sep      ={0.45,0.06,0.06},
    tabact   ={0.90,0.15,0.15}, tabacth={0.70,0.08,0.08},
    tabinact ={0.20,0.05,0.05}, tabinh ={0.35,0.07,0.07},
    cheatbtn ={0.50,0.05,0.05}, cheatbtnh={0.70,0.08,0.08}, cheatbtna={0.90,0.15,0.15},
    neutral  ={0.20,0.05,0.05}, neutralh ={0.35,0.07,0.07},
    cneutral ={0.20,0.05,0.05}, cneutralh={0.50,0.05,0.05},
    aneutral ={0.20,0.05,0.05}, aneutralh={0.50,0.05,0.05},
    btnpos   ={0.50,0.05,0.05}, btnposh  ={0.70,0.08,0.08},
    btnpos2  ={0.50,0.05,0.05}, btnpos2h ={0.70,0.08,0.08},
    btnpos3  ={0.50,0.05,0.05}, btnpos3h ={0.70,0.08,0.08},
    btnneg   ={0.20,0.05,0.05}, btnnegh  ={0.35,0.07,0.07},
    btnneg2  ={0.35,0.05,0.05}, btnneg2h ={0.55,0.07,0.07},
    btnneg3  ={0.20,0.05,0.05}, btnneg3h ={0.35,0.07,0.07},
    btnneg4  ={0.20,0.05,0.05}, btnneg4h ={0.35,0.07,0.07},
    btnneg5  ={0.50,0.05,0.05}, btnneg5h ={0.70,0.08,0.08},
    btnstop  ={0.20,0.05,0.05}, btnsoph  ={0.35,0.07,0.07},
    btnlink  ={0.20,0.05,0.05}, btnlinkh ={0.35,0.07,0.07},
    ed_winbg ={0.10,0.04,0.04}, ed_titlehi={0.20,0.05,0.05}, ed_titlebg={0.10,0.04,0.04},
    ed_sep   ={0.45,0.06,0.06},
    au_winbg ={0.10,0.04,0.04}, au_titlehi={0.20,0.05,0.05}, au_titlebg={0.10,0.04,0.04},
    au_frame ={0.12,0.05,0.05}, au_frameh ={0.20,0.05,0.05},
    au_sep   ={0.45,0.06,0.06},
    au_btn   ={0.50,0.05,0.05}, au_btnh  ={0.70,0.08,0.08},
    au_stop  ={0.20,0.05,0.05}, au_stoph ={0.35,0.07,0.07},
    au_edit  ={0.20,0.05,0.05}, au_edith ={0.35,0.07,0.07},
    ch_winbg ={0.10,0.04,0.04}, ch_titlehi={0.20,0.05,0.05}, ch_titlebg={0.10,0.04,0.04},
    ch_frame ={0.12,0.05,0.05}, ch_frameh ={0.20,0.05,0.05},
    ch_btn   ={0.50,0.05,0.05}, ch_btnh  ={0.70,0.08,0.08},
    ch_scroll={0.10,0.04,0.04}, ch_grab  ={0.50,0.05,0.05},
    ch_tabact={0.90,0.15,0.15}, ch_tabacth={0.70,0.08,0.08},
    ch_tabinact={0.20,0.05,0.05}, ch_tabhh={0.35,0.07,0.07},
    ch_sav   ={0.50,0.05,0.05}, ch_savh  ={0.70,0.08,0.08},
    ch_cancel={0.20,0.05,0.05}, ch_cancelh={0.35,0.07,0.07},
    ch_hint  ={0.20,0.05,0.05}, ch_hinth ={0.35,0.07,0.07},
    ch_edit  ={0.50,0.05,0.05}, ch_edith ={0.70,0.08,0.08},
    ch_framebg={0.12,0.05,0.05}, ch_framebg2={0.12,0.05,0.05},
    ch_framebgh={0.20,0.05,0.05}, ch_framebga={0.20,0.05,0.05},
  },
}

currentTheme = 1
T = THEMES[currentTheme]
THEME_FILE = ""

local function buildThemeFromSimple(s)
  local a  = s.accent      or {0.5, 0.2, 0.0}
  local bg = s.bg          or {0.05, 0.05, 0.07}
  local ti = s.title       or {a[1]*0.9, a[2]*0.4, a[3]*0.1}
  local p  = s.positive    or {0.08, 0.40, 0.08}
  local n  = s.negative    or {0.40, 0.05, 0.05}

  local function lighter(rgb, f)
    return {math.min(rgb[1]*f,1), math.min(rgb[2]*f,1), math.min(rgb[3]*f,1)}
  end
  local function darker(rgb, f)
    return {rgb[1]*f, rgb[2]*f, rgb[3]*f}
  end
  local ah  = lighter(a, 1.4)
  local aa  = lighter(a, 1.9)
  local ph  = lighter(p, 1.4)
  local p2  = lighter(p, 1.1)
  local p2h = lighter(p, 1.5)
  local nh  = lighter(n, 1.5)
  local n2h = lighter(n, 1.8)
  local panel  = lighter(bg, 1.8)
  local frame  = lighter(bg, 1.4)
  local frameh = lighter(bg, 2.2)
  local neu    = darker(a, 0.35)
  local neuh   = darker(a, 0.60)

  return {
    name     = s.name or "Custom",
    winbg    = bg,      titlehi = ti,       titlebg = darker(ti, 0.65),
    frame    = frame,   frameh  = frameh,
    btn      = a,       btnh    = ah,        btna    = aa,
    sep      = a,
    tabact   = a,       tabacth = ah,
    tabinact = panel,   tabinh  = neuh,
    cheatbtn = a,       cheatbtnh = ah,      cheatbtna = aa,
    neutral  = neu,     neutralh  = neuh,
    cneutral = neu,     cneutralh = neuh,
    aneutral = neu,     aneutralh = neuh,
    btnpos   = p,       btnposh   = ph,
    btnpos2  = p2,      btnpos2h  = p2h,
    btnpos3  = p,       btnpos3h  = ph,
    btnneg   = n,       btnnegh   = nh,
    btnneg2  = lighter(n,1.2), btnneg2h = n2h,
    btnneg3  = darker(n,0.7),  btnneg3h = nh,
    btnneg4  = darker(n,0.6),  btnneg4h = nh,
    btnneg5  = lighter(n,1.4), btnneg5h = n2h,
    btnstop  = panel,   btnsoph  = frameh,
    btnlink  = {bg[1]+0.05, bg[2]+0.15, bg[3]+0.35},
    btnlinkh = {bg[1]+0.08, bg[2]+0.28, bg[3]+0.55},
    ed_winbg  = bg,     ed_titlehi = darker(p,0.8), ed_titlebg = darker(p,0.5),
    ed_sep    = p,
    au_winbg  = bg,     au_titlehi = {0.08,0.20,0.45}, au_titlebg = {0.06,0.14,0.32},
    au_frame  = frame,  au_frameh  = frameh,
    au_sep    = {0.20,0.40,0.80},
    au_btn    = {0.08,0.22,0.48}, au_btnh = {0.12,0.32,0.68},
    au_stop   = n,      au_stoph  = nh,
    au_edit   = panel,  au_edith  = frameh,
    ch_winbg  = bg,     ch_titlehi = darker(a,0.55), ch_titlebg = darker(a,0.40),
    ch_frame  = frame,  ch_frameh  = frameh,
    ch_btn    = a,      ch_btnh    = ah,
    ch_scroll = bg,     ch_grab    = a,
    ch_tabact = aa,     ch_tabacth = ah,
    ch_tabinact = panel, ch_tabhh  = neuh,
    ch_sav    = p,      ch_savh    = ph,
    ch_cancel = n,      ch_cancelh = nh,
    ch_hint   = neu,    ch_hinth   = neuh,
    ch_edit   = a,      ch_edith   = ah,
    ch_framebg  = frame, ch_framebg2 = frame,
    ch_framebgh = frameh, ch_framebga = frameh,
  }
end

--  загрузка пользовательских тем 
local function saveTheme()
  local f = io.open(THEME_FILE, "wb")
  if f then f:write(json.encode({theme=currentTheme})); f:close() end
end


local function loadTheme()
  local ok, f = pcall(io.open, THEME_FILE, "rb")
  if not ok or not f then return end
  local raw = f:read("*a"); f:close()
  local ok2, t = pcall(json.decode, raw)
  if ok2 and t and t.theme and THEMES[t.theme] then
    currentTheme = t.theme; T = THEMES[currentTheme]
  end
end


local function applyTheme(idx)
  currentTheme = idx; T = THEMES[currentTheme]; saveTheme()
end


local function loadUserThemes()
  while #THEMES > 4 do table.remove(THEMES) end

  local wd = getWorkingDirectory and getWorkingDirectory() or ""
  if wd == "" then return end
  local dir = wd .. "\\TSR-Binder"

  local content = ""
  local listFile = dir .. "\\tsr_themelist.tmp"
  os.execute('dir /b "' .. dir .. '\\*.theme.json" > "' .. listFile .. '" 2>nul')
  local f = io.open(listFile, "rb")
  if not f then return end
  content = f:read("*a"); f:close()
  os.remove(listFile)

  for fname in content:gmatch("[^\r\n]+") do
    fname = fname:match("^%s*(.-)%s*$")
    if fname ~= "" then
      local tf = io.open(dir .. "\\" .. fname, "rb")
      if tf then
        local raw = tf:read("*a"); tf:close()
        local ok, data = pcall(json.decode, raw)
        if ok and data and data.name then
          local function arr(v)
            if type(v) == "table" then return v end
            return nil
          end
          local simple = {
            name        = tostring(data.name),
            accent      = arr(data.accent),
            bg          = arr(data.bg),
            title       = arr(data.title),
            positive    = arr(data.positive),
            negative    = arr(data.negative),
          }
          local theme = buildThemeFromSimple(simple)
          theme._userfile = fname
          table.insert(THEMES, theme)
        end
      end
    end
  end
end

local function exportCurrentTheme()
  local wd = getWorkingDirectory and getWorkingDirectory() or ""
  if wd == "" then return end
  local t = THEMES[currentTheme]
  local simple = {
    name     = t.name .. " (export)",
    accent   = t.btn,
    bg       = t.winbg,
    title    = t.titlehi,
    positive = t.btnpos,
    negative = t.btnneg,
  }
  local ts = os.date("%Y%m%d_%H%M%S")
  local fname = wd .. "\\TSR-Binder\\theme_" .. ts .. ".theme.json"
  local f = io.open(fname, "wb")
  if f then
    f:write(json.encode(simple, {indent=true}))
    f:close()
    sampAddChatMessage(toChat("{FFD700}[TSR-Binder]{FFFFFF} Тема экспортирована: theme_" .. ts .. ".theme.json"), -1)
  end
end

-- регистронезависимый поиск (пиздец + утилиты)
_cyrUp = {
  ["\224"]="\192",
  ["\225"]="\193",
  ["\226"]="\194",
  ["\227"]="\195",
  ["\228"]="\196",
  ["\229"]="\197",
  ["\230"]="\198",
  ["\231"]="\199",
  ["\232"]="\200",
  ["\233"]="\201",
  ["\234"]="\202",
  ["\235"]="\203",
  ["\236"]="\204",
  ["\237"]="\205",
  ["\238"]="\206",
  ["\239"]="\207",
  ["\240"]="\208",
  ["\241"]="\209",
  ["\242"]="\210",
  ["\243"]="\211",
  ["\244"]="\212",
  ["\245"]="\213",
  ["\246"]="\214",
  ["\247"]="\215",
  ["\248"]="\216",
  ["\249"]="\217",
  ["\250"]="\218",
  ["\251"]="\219",
  ["\252"]="\220",
  ["\253"]="\221",
  ["\254"]="\222",
  ["\255"]="\223",
  ["\184"]="\168",
}
local function strContains(haystack, needle)
  if needle == "" then return true end
  if haystack:find(needle, 1, true) then return true end
  local function toUp(s)
    return (s:gsub(".", function(c)
      return _cyrUp[c] or c:upper()
    end))
  end
  return toUp(haystack):find(toUp(needle), 1, true) ~= nil
end
local function v4(rgb, a)
  return imgui.ImVec4(rgb[1], rgb[2], rgb[3], a or 1.0)
end

local function keyStrToCode(s)
  if not s or s == "" then return nil end
  return KEY_MAP[s:upper()]
end

local function wbuf(buf, size, s)
  ffi.fill(buf, size, 0)
  if s and s ~= "" then ffi.copy(buf, s, math.min(#s, size-1)) end
end

local function fmtTime(sec)
  return string.format("%02d:%02d", math.floor(sec/60), sec%60)
end

--  авто отыгровки оружия
rp = {
  weapon  = true,
  time    = true,
  mask    = true,
  armour  = true,
  maskOn      = false,
  maskBlocked = false,
  maskTimer   = nil,
  maskPutOnTime = 0,
}

-- /time отыгровки
timeRp = {
  meText   = '/me взглянул на часы с гравировкой "TSRG"',
  doText   = "Часы на левой руке.",
  useDo    = true,    
  meDelay  = 4000,    
  doDelay  = 4000,    
}
TIME_RP_FILE = ""
RP_FILE      = ""

-- /d 
myFraction     = ""    
-- Реестр фракций
FRAC_REGISTRY = {
  {id="GOV",   label="GOV",   variants={"GOV","гов","ГОВ", "gov", "Пра-во", "ALL", "all", "CO", "co"}},
  {id="LSSD",  label="LSSD",  variants={"LSSD","лссд","lssd", "ЛССД","РКШД","ркшд","RCSD","rcsd", "ALL", "all", "MJ", "mj"}},
  {id="RCSD",  label="RCSD",  variants={"LSSD","лссд","lssd", "ЛССД","РКШД","ркшд","RCSD","rcsd", "ALL", "all", "MJ", "mj"}},
  {id="LSPD",  label="LSPD",  variants={"LSPD","лспд","lspd", "ЛСПД", "ALL", "all", "MJ", "mj"}},
  {id="LVmPD", label="LVmPD", variants={"LVmPD","лвмпд","LVMPD", "ЛВмПД", "lvmpd", "ALL", "all", "MJ", "mj"}},
  {id="SFPD",  label="SFPD",  variants={"SFPD","сфпд","sfpd", "СФПД", "ALL", "all", "MJ", "mj"}},
  {id="FBI",   label="FBI",   variants={"FBI","фби","fbi", "ФБИ", "ФБР", "FBR", "ALL", "all", "MJ", "mj"}},
  {id="RLS",   label="RLS",   variants={"RLS","rlс","рлс", "РЛС", "ALL", "all", "MM", "mm"}},
  {id="RLV",   label="RLV",   variants={"RLV","рлв", "rlv", "РЛВ", "ALL", "all", "MM", "mm"}},
  {id="RSF",   label="RSF",   variants={"RSF","рсф", "rsf", "РСФ", "ALL", "all", "MM", "mm"}},
  {id="FD",    label="FD",    variants={"FD","фд", "fd", "ФД", "ALL", "all"}},
  {id="LSMC",  label="LSMC",  variants={"LSMC","ЛСМЦ","лсмц", "lsmc", "ALL", "all", "DH", "dh"}},
  {id="LVMC",  label="LVMC",  variants={"LVMC","лвмц","ЛВМЦ", "lvmc", "ALL", "all", "DH", "dh"}},
  {id="SFMC",  label="SFMC",  variants={"SFMC","сфмц","СФМЦ", "sfmc", "ALL", "all", "DH", "dh"}},
  {id="DJMC",  label="DJMC",  variants={"DJMC","джмц","ДЖМЦ", "djmc", "jmc", "JMC", "ЖМЦ", "жмц", "ДЖМЦ", "джмц", "ALL", "all", "DH", "dh"}},
  {id="FCC",  label="FCC",  variants={"FCC","fcc","ФИК", "фик", "ТСР", "тср", "ALL", "all", "MD", "md"}},
  {id="ANG",  label="ANG",  variants={"ANG","ang","АНГ", "анг", "ALL", "all", "MD", "md"}},
  {id="VNG",  label="VNG",  variants={"VNG","vng","ВНГ", "внг", "ALL", "all", "MD", "md"}},
}
FRAC_FILE      = ""    
dHistory       = {}    
dSelected      = 0    
showDReply     = false 
local function dMsg() return dHistory[dSelected] or {} end
local function lastD_sender() return (dHistory[dSelected] or {}).sender or "" end
local function lastD_from()   return (dHistory[dSelected] or {}).from   or "" end
local function lastD_to()     return (dHistory[dSelected] or {}).to     or "" end
local function lastD_text()   return (dHistory[dSelected] or {}).text   or "" end
showMain          = imgui.new.bool(true)
showEditor        = imgui.new.bool(false)
showAutoEditor    = imgui.new.bool(false)
showCheatsheet    = imgui.new.bool(false)
showDWindow       = imgui.new.bool(false)
showLogs          = imgui.new.bool(false)
showUpdateWindow  = imgui.new.bool(false)
updateState = {
  checking        = false,
  downloading     = false,
  hasUpdate       = false,
  currentVersion  = SCRIPT_VERSION,
  remoteVersion   = "-",
  changelogText   = u8"Нажмите Update для проверки новой версии.",
  statusText      = u8"Ожидание проверки.",
  scriptUrl       = "",
  pageUrl         = "",
  lastError       = "",
}
isLeaderMode      = false  
smartInvite       = false  
rankScan = {
  pending  = false,
  rank     = 0,
  org      = "",
  post     = "",
  status   = u8"Не сканировано",
}
sinviteBypassing  = false  
sinvitePendingCmd = nil   
-- Состояние активного собеседования
sinvSession = {
  active    = false,   
  targetId  = 0,       
  targetName= "",      
  stage     = 1,       
  show      = false,   
}
showSinvWindow = imgui.new.bool(false)
SINVITE_FILE      = ""
sinviteStages     = {}
sinviteDecline    = { lines = {{text="/me покачал головой", delay=800}, {text="К сожалению, вы нам не подходите.", delay=1200}} }
debugMode         = false  
dWindowJustOpened = false 
dAutoOpen         = 1  
inDReplyText   = nil   
inSearchBuf    = nil   
armourOn       = false  

-- ID оружий
WEAPON_NAMES = {
  [1]  = {name="Кастет",            type="back"},
  [2]  = {name="Мяч для гольфа",    type="back"},
  [3]  = {name="Дубинку",           type="back"},
  [4]  = {name="Нож",               type="holster"},
  [5]  = {name="Биту",              type="back"},
  [6]  = {name="Лопату",            type="back"},
  [7]  = {name="Бильярдный кий",    type="back"},
  [8]  = {name="Катану",            type="back"},
  [9]  = {name="Бензопилу",         type="back"},
  [22] = {name="Пистолет",          type="holster"},
  [23] = {name="Silenced Pistol",   type="holster"},
  [24] = {name="Desert Eagle",      type="holster"},
  [25] = {name="Дробовик",          type="back"},
  [26] = {name="Обрез",             type="back"},
  [27] = {name="Combat Shotgun",    type="back"},
  [28] = {name="Micro Uzi",         type="holster"},
  [29] = {name="MP5",               type="back"},
  [30] = {name="AK-47",             type="back"},
  [31] = {name="M4",                type="back"},
  [32] = {name="Tec-9",             type="holster"},
  [33] = {name="Rifle",             type="back"},
  [34] = {name="Снайперскую винтовку", type="back"},
  [35] = {name="RPG",               type="back"},
  [36] = {name="HS Rocket",         type="back"},
  [37] = {name="Огнемёт",           type="back"},
  [38] = {name="Minigun",           type="back"},
  [41] = {name="Spraycan",          type="holster"},
  [42] = {name="Огнетушитель",      type="back"},
  [43] = {name="Фотоаппарат",       type="holster"},
}


DRAW_BACK = {
  " медленно потянулся за спину и достал ",
  " уверенным движением извлёк из-за спины ",
  " резким движением достал из-за спины ",
}

HOLSTER_BACK = {
  " убрал ",
  " закинул ",
  " спрятал ",
}

HOLSTER_BACK_SFX = " за спину"

prevWeapon  = -1
weaponCheckTimer = 0

local function getWeaponSuffix(wtype, action)
  if wtype == "holster" then
    if action == "draw" then
      return " уверенным жестом достал из кобуры "
    else
      return nil  
    end
  else
    if action == "draw" then
      return DRAW_BACK[math.random(#DRAW_BACK)]
    else
      return HOLSTER_BACK[math.random(#HOLSTER_BACK)]
    end
  end
end

--  бинды
binds    = {}
cooldown = {}
bindStopFlag = false  
bop = { swapIdx=0, swapDir=0, copyIdx=0, deleteIdx=0 }
lastSent = ""
tm = {
  sessionStart = os.time(),
  dayStatsBase = {},
  weekSeconds  = 0,
  lastSaveTime = os.time(),
}
-- daystats
dayStats      = {}
prevWeekStats = {}  
prevWeekTotal = 0
local DAY_NAMES     = { u8"Понедельник", u8"Вторник", u8"Среда",
                        u8"Четверг", u8"Пятница", u8"Суббота", u8"Воскресенье" }

local function dbg(msg)
  if debugMode then
    local s = tostring(msg)
    sampAddChatMessage(toChat("{FF4400}[TSR-Binder DBG] {FFFFFF}" .. s), -1)
  end
end

local function formatTime(secs)
  local h = math.floor(secs / 3600)
  local m = math.floor((secs % 3600) / 60)
  local s = secs % 60
  return string.format("%02d:%02d:%02d", h, m, s)
end

local function isLocalPlayerReady()
  local okExists, exists = pcall(doesCharExist, PLAYER_PED)
  if okExists and not exists then return false end
  local okDead, dead = pcall(isCharDead, PLAYER_PED)
  if okDead and dead then return false end
  local okPlaying, playing = pcall(isPlayerPlaying, PLAYER_HANDLE)
  if okPlaying and not playing then return false end
  return true
end

local function getToggleKeyName()
  for name, code in pairs(KEY_MAP) do
    if code == TOGGLE_KEY then return name end
  end
  return "HOME"
end

local function getScannedRank()
  return tonumber(rankScan.rank) or 0
end

local function canUseDReply()
  return getScannedRank() >= 5
end

local function canUseLogs()
  return getScannedRank() >= 7
end

local function canUseSmartInvite()
  return getScannedRank() >= 9
end

local function refreshRankAccess()
  isLeaderMode = canUseSmartInvite()
  if not canUseLogs() then
    showLogs[0] = false
  end
  if not canUseSmartInvite() then
    smartInvite = false
    if activeTab == 6 then activeTab = 3 end
  end
  if not canUseDReply() then
    showDWindow[0] = false
  end
end

local function saveFracState()
  if FRAC_FILE == "" then return end
  local ff = io.open(FRAC_FILE, "wb")
  if not ff then return end
  ff:write(json.encode({
    frac = myFraction,
    dAutoOpen = dAutoOpen,
    toggleKey = getToggleKeyName(),
    staffRank = getScannedRank(),
    staffOrg = rankScan.org,
    staffPost = rankScan.post,
    staffStatus = rankScan.status,
  }))
  ff:close()
end

local function cleanDialogLine(line)
  return tostring(line or "")
    :gsub("{%x%x%x%x%x%x}", "")
    :gsub("\t", " ")
    :gsub("\r", "")
    :gsub("^%s+", "")
    :gsub("%s+$", "")
end

local function parseStatsAccess(text)
  local org, post, rank
  for rawLine in tostring(text or ""):gmatch("[^\n]+") do
    local line = cleanDialogLine(rawLine)
    if org == nil or org == "" then
      org = line:match("[Оо]рганизац[^:]*:%s*(.+)") or line:match("[Фф]ракц[^:]*:%s*(.+)")
    end
    if post == nil or post == "" then
      post = line:match("[Дд]олжност[^:]*:%s*(.+)") or line:match("[Рр]анг[^:]*:%s*(.+)")
    end
    if not rank then
      local found = line:match("[Дд]олжност[^:]*:.-%((%d+)%)")
        or line:match("[Дд]олжност[^:]*:.-%[(%d+)%]")
        or line:match("[Дд]олжност[^:]*:%s*(%d+)")
        or line:match("[Рр]анг[^:]*:%s*(%d+)")
      if found then rank = tonumber(found) end
    end
  end
  if post and not rank then
    rank = tonumber(post:match("%((%d+)%)") or post:match("%[(%d+)%]") or post:match("(%d+)"))
  end
  if not org and not post and not rank then return nil end
  return {
    org = org or "",
    post = post or "",
    rank = rank or 0,
  }
end

local function getRankScanText()
  if rankScan.pending then
    return u8"Сканирование /stats..."
  end
  if getScannedRank() > 0 then
    local org = rankScan.org ~= "" and rankScan.org or u8"Организация не найдена"
    local post = rankScan.post ~= "" and rankScan.post or u8"Должность не найдена"
    return org .. u8" | " .. post .. u8" | Ранг: " .. tostring(getScannedRank())
  end
  return rankScan.status or u8"Не сканировано"
end

local function getMskTime()
  local now = os.time()
  local utc = os.date("!*t", now)
  local msk_offset = 3 * 3600
  return now + msk_offset - (os.time(os.date("*t", now)) - now)
end

local function isWeekResetNeeded(savedWeekTs)
  local now = os.time()
  local mskOffset = 3 * 3600
  local nowMsk = now + mskOffset
  local t = os.date("!*t", nowMsk)
  local wday = t.wday
  local daysSinceMon = (wday == 1) and 6 or (wday - 2)
  local monMidnightMsk = nowMsk - (daysSinceMon * 86400) - (t.hour * 3600) - (t.min * 60) - t.sec
  local monResetUtc = monMidnightMsk - mskOffset + 5 * 3600
  if now < monResetUtc then monResetUtc = monResetUtc - 7 * 86400 end
  return (savedWeekTs or 0) < monResetUtc
end

deliveries = {
  TSR  = { count=0, last="", players={} },
  LS   = { count=0, last="", players={} },
  SF   = { count=0, last="", players={} },
}
deliveryLog = {}   -- полный лог
MAX_LOG     = 2000 -- максимум записей
wantedPending = nil  -- буфер ожидания строки
wantedCount   = 0    -- счётчик активности
radio = {
  log     = {},
  visible = true,
}
MAX_RADIO = 5000
local LOG_RENDER_LIMIT = 150
local RADIO_RENDER_LIMIT = 150
local deliveryLogDirty = false
local radioLogDirty = false
local lastLogFlushAt = 0
local LOG_FLUSH_INTERVAL = 20.0


local function saveTimeRp()
  if TIME_RP_FILE == "" then return end
  local f = io.open(TIME_RP_FILE, "wb")
  if f then f:write(json.encode(timeRp, {indent=true})); f:close() end
end

local function saveDeliveryLogNow()
  if LOG_FILE == "" then return end
  local lf = io.open(LOG_FILE, "wb")
  if lf then
    lf:write(json.encode(deliveryLog))
    lf:close()
  end
end

local function saveRadioLogNow()
  if RADIO_FILE == "" then return end
  local rf = io.open(RADIO_FILE, "wb")
  if rf then
    rf:write(json.encode(radio.log))
    rf:close()
  end
end

local function readWholeFile(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local data = f:read("*a")
  f:close()
  return data
end

local function writeWholeFile(path, data)
  local f = io.open(path, "wb")
  if not f then return false end
  f:write(data or "")
  f:close()
  return true
end

local function splitLines(text)
  local lines = {}
  text = tostring(text or ""):gsub("\r\n", "\n")
  for line in text:gmatch("([^\n]*)\n?") do
    if line == "" and #lines > 0 and lines[#lines] == "" then break end
    table.insert(lines, line)
  end
  if #lines == 0 then
    table.insert(lines, "")
  end
  return lines
end

local function normalizeVersion(ver)
  ver = tostring(ver or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  ver = ver:gsub("^version%s*", ""):gsub("^ver%s*", ""):gsub("^v", "")
  return ver
end

local function compareVersions(currentVer, remoteVer)
  local a = {}
  local b = {}
  for num in normalizeVersion(currentVer):gmatch("(%d+)") do table.insert(a, tonumber(num) or 0) end
  for num in normalizeVersion(remoteVer):gmatch("(%d+)") do table.insert(b, tonumber(num) or 0) end
  local maxLen = math.max(#a, #b)
  for i = 1, maxLen do
    local av = a[i] or 0
    local bv = b[i] or 0
    if av < bv then return -1 end
    if av > bv then return 1 end
  end
  return 0
end

local function buildChangelogText(raw)
  if type(raw) == "table" then
    local lines = {}
    for _, item in ipairs(raw) do
      if tostring(item or "") ~= "" then
        table.insert(lines, "• " .. tostring(item))
      end
    end
    return #lines > 0 and table.concat(lines, "\n") or u8"Список изменений не указан."
  end
  local text = tostring(raw or ""):gsub("\r\n", "\n"):gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then
    return u8"Список изменений не указан."
  end
  return text
end

local function resetUpdateState(message)
  updateState.checking = false
  updateState.downloading = false
  updateState.hasUpdate = false
  updateState.remoteVersion = "-"
  updateState.scriptUrl = ""
  updateState.pageUrl = ""
  updateState.lastError = ""
  updateState.statusText = message or u8"Ожидание проверки."
  updateState.changelogText = u8"Нажмите Update для проверки новой версии."
end

local function canCheckUpdates()
  return hasRequests and UPDATE_METADATA_URL ~= nil and UPDATE_METADATA_URL ~= ""
end

local function beginUpdateCheck()
  if updateState.checking or updateState.downloading then return end
  updateState.currentVersion = SCRIPT_VERSION
  if not hasRequests then
    resetUpdateState(u8"Библиотека requests.lua не найдена.")
    updateState.lastError = "requests.lua"
    return
  end
  if UPDATE_METADATA_URL == "" then
    resetUpdateState(u8"URL version.json не настроен.")
    updateState.lastError = "metadata_url"
    return
  end
  updateState.checking = true
  updateState.hasUpdate = false
  updateState.remoteVersion = "-"
  updateState.scriptUrl = ""
  updateState.pageUrl = ""
  updateState.lastError = ""
  updateState.statusText = u8"Проверка обновлений..."
  updateState.changelogText = u8"Загрузка информации с GitHub..."
  lua_thread.create(function()
    local ok, response = pcall(requests.get, UPDATE_METADATA_URL, {
      headers = UPDATE_HTTP_HEADERS,
      allow_redirects = true,
      timeout = 15,
    })
    if not ok or not response then
      updateState.checking = false
      updateState.statusText = u8"Не удалось связаться с GitHub."
      updateState.changelogText = tostring(response or ok)
      updateState.lastError = "request_failed"
      return
    end
    if tonumber(response.status_code) ~= 200 then
      updateState.checking = false
      updateState.statusText = u8"GitHub вернул ошибку."
      updateState.changelogText = "HTTP " .. tostring(response.status_code or "?")
      updateState.lastError = "http_" .. tostring(response.status_code or "unknown")
      return
    end
    local meta = response.json and response.json() or nil
    if type(meta) ~= "table" then
      local okJson, decoded = pcall(json.decode, response.text or "")
      if okJson then meta = decoded end
    end
    if type(meta) ~= "table" then
      updateState.checking = false
      updateState.statusText = u8"version.json поврежден или пуст."
      updateState.changelogText = u8"Не удалось разобрать ответ GitHub."
      updateState.lastError = "bad_json"
      return
    end
    local remoteVersion = tostring(meta.version or meta.latest_version or meta.tag or "")
    local scriptUrl = tostring(meta.script_url or meta.download_url or meta.url or "")
    local pageUrl = tostring(meta.page_url or meta.release_url or meta.github_url or "")
    updateState.remoteVersion = remoteVersion ~= "" and remoteVersion or "-"
    updateState.scriptUrl = scriptUrl
    updateState.pageUrl = pageUrl
    updateState.changelogText = buildChangelogText(meta.changelog or meta.changes or meta.notes)
    updateState.checking = false
    if remoteVersion == "" then
      updateState.hasUpdate = false
      updateState.statusText = u8"В version.json отсутствует поле version."
      updateState.lastError = "missing_version"
      return
    end
    local cmp = compareVersions(SCRIPT_VERSION, remoteVersion)
    if cmp < 0 then
      updateState.hasUpdate = true
      updateState.statusText = u8"Доступно новое обновление."
      if scriptUrl == "" then
        updateState.statusText = u8"Найдена новая версия, но отсутствует script_url."
        updateState.lastError = "missing_script_url"
      end
    else
      updateState.hasUpdate = false
      updateState.statusText = u8"У вас уже установлена актуальная версия."
    end
  end)
end

local function beginUpdateInstall()
  if updateState.downloading or updateState.checking then return end
  if not updateState.hasUpdate then
    beginUpdateCheck()
    return
  end
  if updateState.scriptUrl == "" then
    updateState.statusText = u8"Не указан script_url для загрузки."
    updateState.lastError = "missing_script_url"
    return
  end
  updateState.downloading = true
  updateState.statusText = u8"Загрузка новой версии..."
  updateState.lastError = ""
  lua_thread.create(function()
    local ok, response = pcall(requests.get, updateState.scriptUrl, {
      headers = UPDATE_HTTP_HEADERS,
      allow_redirects = true,
      timeout = 20,
    })
    if not ok or not response then
      updateState.downloading = false
      updateState.statusText = u8"Не удалось скачать новый файл."
      updateState.lastError = "download_failed"
      return
    end
    if tonumber(response.status_code) ~= 200 or not response.text or response.text == "" then
      updateState.downloading = false
      updateState.statusText = u8"GitHub вернул неверный файл обновления."
      updateState.lastError = "download_http_" .. tostring(response.status_code or "unknown")
      return
    end
    local newBody = response.text
    if not newBody:find("script_name%s*%(") then
      updateState.downloading = false
      updateState.statusText = u8"Скачанный файл не похож на Lua-скрипт."
      updateState.lastError = "invalid_script"
      return
    end
    local wd = getWorkingDirectory and getWorkingDirectory() or ""
    local currentPath = wd ~= "" and (wd .. "\\" .. script.this.filename) or script.this.path
    if not currentPath or currentPath == "" then
      updateState.downloading = false
      updateState.statusText = u8"Не удалось определить путь текущего скрипта."
      updateState.lastError = "missing_script_path"
      return
    end
    local currentBody = readWholeFile(currentPath)
    if not currentBody then
      updateState.downloading = false
      updateState.statusText = u8"Не удалось прочитать текущий файл скрипта."
      updateState.lastError = "read_current_failed"
      return
    end
    local backupPath = currentPath .. ".preupdate.bak"
    writeWholeFile(backupPath, currentBody)
    if not writeWholeFile(currentPath, newBody) then
      writeWholeFile(currentPath, currentBody)
      updateState.downloading = false
      updateState.statusText = u8"Не удалось записать новую версию."
      updateState.lastError = "write_current_failed"
      return
    end
    if deliveryLogDirty then
      saveDeliveryLogNow()
      deliveryLogDirty = false
    end
    if radioLogDirty then
      saveRadioLogNow()
      radioLogDirty = false
    end
    exportReadableLogs()
    updateState.downloading = false
    updateState.hasUpdate = false
    updateState.currentVersion = updateState.remoteVersion ~= "-" and updateState.remoteVersion or SCRIPT_VERSION
    updateState.statusText = u8"Обновление установлено. Перезагрузка скрипта..."
    sampAddChatMessage(toChat("{FFD700}[TSR-Binder]{FFFFFF} Обновление загружено. Перезагрузка скрипта..."), -1)
    wait(1200)
    thisScript():reload()
  end)
end

local function formatDeliveryEntryForFile(entry)
  local stamp = string.format("[%s] [%s]", entry.date or "--.--.----", entry.time or "--:--:--")
  if entry.type == "wanted" then
    local reason = (entry.reason and entry.reason ~= "") and (" (" .. entry.reason .. ")") or ""
    local accuser = (entry.accuser and entry.accuser ~= "") and (" | " .. entry.accuser) or ""
    return stamp .. " [Розыск] " .. (entry.player or "?") .. reason .. accuser
  elseif entry.type == "clearwanted" then
    return stamp .. " [Снят розыск] " .. (entry.rank or "") .. " " .. (entry.cop or "?") .. " -> " .. (entry.target or "?")
  elseif entry.type == "police" then
    local reason = (entry.reason and entry.reason ~= "") and (" (" .. entry.reason .. ")") or ""
    return stamp .. " [Полиция] " .. (entry.player or "?") .. " | " .. (entry.city or "") .. " | " .. (entry.location or "") .. reason
  elseif entry.type == "theft" then
    return stamp .. " [Угон] Новый угон транспортного средства"
  end
  return stamp .. " [Поставка] " .. (entry.player or "?") .. " -> " .. (entry.amount or "") .. " " .. (entry.goods or "") .. " [" .. (entry.factory or "") .. "]"
end

local function formatRadioEntryForFile(entry)
  local stamp = string.format("[%s] [%s]", entry.date or "--.--.----", entry.time or "--:--:--")
  local tag = entry.isNrp and " ((NRP)) " or " "
  return stamp .. tag .. (entry.player or "?") .. ": " .. (entry.text or "")
end

local function exportReadableLogs()
  if LOG_READABLE_FILE ~= "" then
    local lf = io.open(LOG_READABLE_FILE, "wb")
    if lf then
      lf:write("TSR-Binder | Chat Logs\n")
      lf:write("Сформировано: " .. os.date("%d.%m.%Y %H:%M:%S") .. "\n")
      lf:write("Раздел: поставки / розыск / полиция / угоны\n")
      lf:write(("="):rep(72) .. "\n")
      for i = #deliveryLog, 1, -1 do
        lf:write(formatDeliveryEntryForFile(deliveryLog[i]) .. "\n")
      end
      lf:close()
    end
  end
  if RADIO_READABLE_FILE ~= "" then
    local rf = io.open(RADIO_READABLE_FILE, "wb")
    if rf then
      rf:write("TSR-Binder | Radio Logs\n")
      rf:write("Сформировано: " .. os.date("%d.%m.%Y %H:%M:%S") .. "\n")
      rf:write("Раздел: рация /r\n")
      rf:write(("="):rep(72) .. "\n")
      for i = #radio.log, 1, -1 do
        rf:write(formatRadioEntryForFile(radio.log[i]) .. "\n")
      end
      rf:close()
    end
  end
end

local function loadTimeRp()
  if TIME_RP_FILE == "" then return end
  local f = io.open(TIME_RP_FILE, "rb")
  if not f then return end
  local raw = f:read("*a"); f:close()
  local ok, t = pcall(json.decode, raw)
  if ok and t then
    if t.meText   then timeRp.meText   = t.meText   end
    if t.doText   then timeRp.doText   = t.doText   end
    if t.useDo    ~= nil then timeRp.useDo   = t.useDo   end
  end
end

local function sinvGetText(ln)
  if ln.buf then return ffi.string(ln.buf) end
  return ln.text or ""
end

local function sinvGetDelay(ln)
  if ln.dbuf then return tonumber(ffi.string(ln.dbuf)) or 800 end
  return ln.delay or 800
end

local function sinviteInitBufs()
  for _, st in ipairs(sinviteStages) do
    for _, ln in ipairs(st.lines) do
      if not ln.buf then
        ln.buf  = imgui.new.char[256]()
        ln.dbuf = imgui.new.char[8]()
        ffi.fill(ln.buf, 256, 0); ffi.fill(ln.dbuf, 8, 0)
        if ln.text and ln.text ~= "" then ffi.copy(ln.buf, ln.text, math.min(#ln.text, 255)) end
        local ds = tostring(ln.delay or 800)
        ffi.copy(ln.dbuf, ds, math.min(#ds, 7))
      end
    end
  end
  for _, ln in ipairs(sinviteDecline.lines) do
    if not ln.buf then
      ln.buf  = imgui.new.char[256]()
      ln.dbuf = imgui.new.char[8]()
      ffi.fill(ln.buf, 256, 0); ffi.fill(ln.dbuf, 8, 0)
      if ln.text and ln.text ~= "" then ffi.copy(ln.buf, ln.text, math.min(#ln.text, 255)) end
      local ds = tostring(ln.delay or 800)
      ffi.copy(ln.dbuf, ds, math.min(#ds, 7))
    end
  end
end

local function saveSinvite()
  if SINVITE_FILE == "" then return end
  local stages = {}
  for _, st in ipairs(sinviteStages) do
    local lines = {}
    for _, ln in ipairs(st.lines) do
      table.insert(lines, {text=ffi.string(ln.buf), delay=tonumber(ffi.string(ln.dbuf)) or 800})
    end
    table.insert(stages, {lines=lines})
  end
  local declines = {}
  for _, ln in ipairs(sinviteDecline.lines) do
    table.insert(declines, {text=ffi.string(ln.buf), delay=tonumber(ffi.string(ln.dbuf)) or 800})
  end
  local f = io.open(SINVITE_FILE, "wb")
  if f then f:write(json.encode({stages=stages, decline={lines=declines}}, {indent=true})); f:close() end
end

local function loadSinvite()
  if SINVITE_FILE == "" then return end
  local f = io.open(SINVITE_FILE, "rb")
  if not f then return end
  local raw = f:read("*a"); f:close()
  local ok, t = pcall(json.decode, raw)
  if ok and t then
    if t.stages then sinviteStages = t.stages end
    if t.decline and t.decline.lines then sinviteDecline = t.decline end
  end
  sinviteInitBufs()
end

local function saveRp()
  if RP_FILE == "" then return end
  local f = io.open(RP_FILE, "wb")
  if f then
    f:write(json.encode({
      weapon = rp.weapon,
      time   = rp.time,
      mask   = rp.mask,
      armour = rp.armour,
    }))
    f:close()
  end
end

local function loadRp()
  if RP_FILE == "" then return end
  local f = io.open(RP_FILE, "rb")
  if not f then return end
  local raw = f:read("*a"); f:close()
  local ok, t = pcall(json.decode, raw)
  if ok and t then
    if t.weapon ~= nil then rp.weapon = t.weapon end
    if t.time   ~= nil then rp.time   = t.time   end
    if t.mask   ~= nil then rp.mask   = t.mask   end
    if t.armour ~= nil then rp.armour = t.armour end
  end
end

local function saveBinds()
  local t = {}
  for _, b in ipairs(binds) do
    local entries = {}
    for _, e in ipairs(b.entries) do table.insert(entries, {text=e.text, delay=e.delay}) end
    table.insert(t, {label=b.label, keyStr=b.keyStr, entries=entries})
  end
  local f = io.open(SAVE_FILE, "wb")
  if f then f:write(json.encode(t, {indent=true})); f:close() end
end

local function loadBinds()
  local f = io.open(SAVE_FILE, "rb")
  if not f then return end
  local raw = f:read("*a"); f:close()
  local t = json.decode(raw)
  if not t or type(t) ~= "table" then return end
  binds = {}
  for _, b in ipairs(t) do
    if b.label then
      local entries = {}
      if b.lines then
        for _, line in ipairs(b.lines) do table.insert(entries, {text=line, delay=DEFAULT_DELAY}) end
      elseif b.entries then
        for _, e in ipairs(b.entries) do
          table.insert(entries, {text=e.text or "", delay=tonumber(e.delay) or DEFAULT_DELAY})
        end
      end
      table.insert(binds, {label=b.label, keyStr=b.keyStr or "", keyCode=keyStrToCode(b.keyStr), entries=entries})
    end
  end
end

local function sendBind(b)
  local entries = {}
  local t = 0
  for _, e in ipairs(b.entries) do
    table.insert(entries, {text=e.text, delay=e.delay or DEFAULT_DELAY})
    t = t + (e.delay or DEFAULT_DELAY)
  end
  lastSent = b.label
  bindStopFlag = false
  lua_thread.create(function()
    for _, e in ipairs(entries) do
      if bindStopFlag then break end
      sampSendChat(toChat(e.text))
      local elapsed = 0
      local step = 50
      while elapsed < e.delay do
        wait(step)
        elapsed = elapsed + step
        if bindStopFlag then break end
      end
    end
  end)
  return t
end

autoMsgs = {}

local function saveAuto()
  local t = {}
  for _, a in ipairs(autoMsgs) do
    table.insert(t, {label=a.label, lines=a.lines, interval=a.interval, limit=a.limit})
  end
  local f = io.open(AUTO_FILE, "wb")
  if f then f:write(json.encode(t, {indent=true})); f:close() end
end

local function loadAuto()
  local f = io.open(AUTO_FILE, "rb")
  if not f then return end
  local raw = f:read("*a"); f:close()
  local t = json.decode(raw)
  if not t or type(t) ~= "table" then return end
  autoMsgs = {}
  for _, a in ipairs(t) do
    if a.interval then
      local lines = a.lines
      if not lines and a.text then
        lines = {{text=a.text, delay=800}}
      end
      if lines then
        table.insert(autoMsgs, {
          label    = a.label or (lines[1] and lines[1].text or ""):sub(1,20),
          lines    = lines,
          interval = tonumber(a.interval) or 60,
          limit    = tonumber(a.limit) or 0,
          active   = false,
          lastSentAt = 0, 
          count    = 0,
        })
      end
    end
  end
end

-- UI-состояние и буферы редакторов            
activeTab     = 1

-- редактор биндов
ed = {
  mode        = "new",
  idx         = 0,
  capturingKey = false,
  inLabel = nil,
  inKey = nil,
  rows        = {},
  msg         = "",
  msgTimer    = 0,
  msg_ok      = false,
}

-- Редактор авто сообщений
aed = {
  mode     = "new",
  idx      = 0,
  inLabel  = nil,
  inSec    = nil,
  inLimit  = nil,
  rows     = {},
  msg      = "",
  msgTimer = 0,
  msg_ok   = false,
}

-- шпора
cs = {
  editMode  = false,
  onlyMode  = false,
  buf       = nil,
  lines     = {},
}
CHEAT_BUF = 4096


-- заметки
cheatTab   = 1      
NOTE_BUF   = 4096
nt = {
  buf   = nil,
  dirty = false,
}

local function saveNotes()
  local txt = ffi.string(nt.buf)
  local f = io.open(NOTES_FILE, "wb")
  if f then f:write(txt); f:close() end
  nt.dirty = false
end

local function loadNotes()
  local f = io.open(NOTES_FILE, "rb")
  if not f then return end
  local txt = f:read("*a"); f:close()
  if txt and txt ~= "" then
    ffi.fill(nt.buf, NOTE_BUF, 0)
    ffi.copy(nt.buf, txt, math.min(#txt, NOTE_BUF-1))
  end
end

local function saveCheatsheet()
  local txt = ffi.string(cs.buf)
  local f = io.open(CHEAT_FILE, "wb")
  if f then f:write(txt); f:close() end
  cs.lines = {}
  for line in (txt.."\n"):gmatch("([^\n]*)\n") do
    table.insert(cs.lines, line)
  end
end

local function loadCheatsheet()
  local f = io.open(CHEAT_FILE, "rb")
  if not f then return end
  local txt = f:read("*a"); f:close()
  ffi.fill(cs.buf, CHEAT_BUF, 0)
  ffi.copy(cs.buf, txt, math.min(#txt, CHEAT_BUF-1))
  cs.lines = {}
  for line in (txt.."\n"):gmatch("([^\n]*)\n") do
    table.insert(cs.lines, line)
  end
end

-- редактор биндов и логика данных 
local function newRow(text, delay)
  local tb = imgui.new.char[BUF]()
  local db = imgui.new.char[16]()
  ffi.fill(tb, BUF, 0); ffi.fill(db, 16, 0)
  if text and text ~= "" then ffi.copy(tb, text, math.min(#text, BUF-1)) end
  local ds = tostring(delay or DEFAULT_DELAY)
  ffi.copy(db, ds, math.min(#ds, 15))
  return {textBuf=tb, delayBuf=db}
end

local function clearEditor()
  ffi.fill(ed.inLabel, BUF, 0); ffi.fill(ed.inKey, 32, 0)
  ed.rows = {newRow("", DEFAULT_DELAY)}
  ed.msg = ""; ed.msgTimer = 0; ed.capturingKey = false
end

local function openNew()
  clearEditor(); ed.mode="new"; ed.idx=0; showEditor[0]=true
end

local function openEdit(idx)
  local b = binds[idx]; if not b then return end
  clearEditor()
  wbuf(ed.inLabel, BUF, b.label); wbuf(ed.inKey, 32, b.keyStr)
  ed.rows = {}
  for _, e in ipairs(b.entries) do table.insert(ed.rows, newRow(e.text, e.delay)) end
  if #ed.rows == 0 then table.insert(ed.rows, newRow("", DEFAULT_DELAY)) end
  ed.mode="edit"; ed.idx=idx; showEditor[0]=true
end

local function setMsg(text, ok)
  ed.msg=text; ed.msgTimer=150; ed.msg_ok=ok or false
end

--  редактор авто msg
local function newAutoRow(text, delay)
  local tb = imgui.new.char[BUF]()
  local db = imgui.new.char[16]()
  ffi.fill(tb, BUF, 0); ffi.fill(db, 16, 0)
  if text and text ~= "" then ffi.copy(tb, text, math.min(#text, BUF-1)) end
  local ds = tostring(delay or 800)
  ffi.copy(db, ds, math.min(#ds, 15))
  return {textBuf=tb, delayBuf=db}
end

local function clearAutoEditor()
  ffi.fill(aed.inLabel, BUF, 0)
  wbuf(aed.inSec,   16, "60")
  wbuf(aed.inLimit, 16, "0")
  aed.rows = {newAutoRow("", 800)}
  aed.msg = ""; aed.msgTimer = 0
end

local function openAutoNew()
  clearAutoEditor(); aed.mode="new"; aed.idx=0
  showAutoEditor[0] = true
end

local function openAutoEdit(idx)
  local a = autoMsgs[idx]; if not a then return end
  clearAutoEditor()
  wbuf(aed.inLabel, BUF, a.label)
  wbuf(aed.inSec,   16,  tostring(a.interval))
  wbuf(aed.inLimit, 16,  tostring(a.limit or 0))
  aed.rows = {}
  local lines = a.lines or {}
  for _, ln in ipairs(lines) do
    table.insert(aed.rows, newAutoRow(ln.text, ln.delay))
  end
  if #aed.rows == 0 then table.insert(aed.rows, newAutoRow("", 800)) end
  aed.mode="edit"; aed.idx=idx
  showAutoEditor[0] = true
end

local function setAutoMsg(text, ok)
  aed.msg=text; aed.msgTimer=150; aed.msg_ok=ok or false
end

--  хуета для дебила созданная дебилом
local function isGameFocused()
  if sampIsChatInputActive() then return false end
  if sampIsDialogActive()    then return false end
  if isPauseMenuActive()     then return false end
  return true
end

local function tabBtn(label, isActive, width)
  if isActive then
    imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabact))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
  else
    imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabinact, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabinh))
  end
  local clicked = imgui.Button(label, imgui.ImVec2(width or 85, 24))
  imgui.PopStyleColor(2)
  return clicked
end

-- главная функция                          
function main()
  if not isSampLoaded() then return end
  wait(2000)
  local wd  = getWorkingDirectory()
  local dir = wd .. "\\TSR-Binder"
  os.execute('mkdir "' .. dir .. '" 2>nul')
  SAVE_FILE   = dir .. "\\tsr_binds.json"
  AUTO_FILE   = dir .. "\\tsr_auto.json"
  CHEAT_FILE  = dir .. "\\tsr_cheatsheet.txt"
  NOTES_FILE  = dir .. "\\tsr_notes.json"
  THEME_FILE  = dir .. "\\tsr_theme.json"
  LOG_FILE      = dir .. "\\tsr_delivlog.json"
  LOG_READABLE_FILE = dir .. "\\tsr_delivlog_readable.txt"
  SINVITE_FILE  = dir .. "\\tsr_sinvite.json"
  SINVITE_FILE  = dir .. "\\tsr_sinvite.json"
  TIME_RP_FILE  = dir .. "\\tsr_timexp.json"
  RP_FILE       = dir .. "\\tsr_rp.json"
  RADIO_FILE  = dir .. "\\tsr_radio.json"
  RADIO_READABLE_FILE = dir .. "\\tsr_radio_readable.txt"
  FRAC_FILE   = dir .. "\\tsr_frac.json"
  TIME_FILE   = dir .. "\\tsr_time.json"
  -- загрузка фракции
  do
    local ff = io.open(FRAC_FILE, "rb")
    if ff then
      local raw = ff:read("*a"); ff:close()
      local ok, t = pcall(json.decode, raw)
      if ok and t and t.frac then myFraction = t.frac end
      if ok and t and t.dAutoOpen ~= nil then
        if t.dAutoOpen == true then dAutoOpen = 1
        elseif t.dAutoOpen == false then dAutoOpen = 0
        else dAutoOpen = tonumber(t.dAutoOpen) or 1 end
      end
      if ok and t and t.toggleKey and KEY_MAP[t.toggleKey] then
        TOGGLE_KEY = KEY_MAP[t.toggleKey]
      end
      if ok and t then
        rankScan.rank = tonumber(t.staffRank) or 0
        rankScan.org = t.staffOrg or ""
        rankScan.post = t.staffPost or ""
        rankScan.status = t.staffStatus or (rankScan.rank > 0 and u8"Ранг загружен" or u8"Не сканировано")
      end
    end
  end
  refreshRankAccess()
  -- загрузка лога поставок
  do
    if LOG_FILE ~= "" then
      local lf = io.open(LOG_FILE, "rb")
      if lf then
        local raw = lf:read("*a"); lf:close()
        local ok, t = pcall(json.decode, raw)
        if ok and type(t) == "table" then
          deliveryLog = t
          local trimmed = false
          while #deliveryLog > MAX_LOG do
            table.remove(deliveryLog)
            trimmed = true
          end
          if trimmed then deliveryLogDirty = true end
        end
      end
    end
  end
  -- загрузка лога рации
  do
    if RADIO_FILE ~= "" then
      local rf = io.open(RADIO_FILE, "rb")
      if rf then
        local raw = rf:read("*a"); rf:close()
        local ok, t = pcall(json.decode, raw)
        if ok and type(t) == "table" then
          radio.log = t
          local trimmed = false
          while #radio.log > MAX_RADIO do
            table.remove(radio.log)
            trimmed = true
          end
          if trimmed then radioLogDirty = true end
        end
      end
    end
  end
  -- накопленное время неделя
  do
    if TIME_FILE ~= "" then
      local tf = io.open(TIME_FILE, "rb")
      if tf then
        local raw = tf:read("*a"); tf:close()
        local ok, t = pcall(json.decode, raw)
        if ok and t then
          if isWeekResetNeeded(t.savedAt) then
            prevWeekStats = t.days or {}
            prevWeekTotal = t.week or 0
            tm.weekSeconds   = 0
            dayStats      = {}
            tm.dayStatsBase  = {}
          else
            dayStats      = t.days or {}
            for k,v in pairs(dayStats) do tm.dayStatsBase[k] = v end
            prevWeekStats = t.prevDays or {}
            prevWeekTotal = t.prevWeek or 0
            local todayKey = os.date("%Y-%m-%d")
            local weekSum = 0
            for k, v in pairs(dayStats) do
              if k ~= todayKey then weekSum = weekSum + v end
            end
            tm.weekSeconds = weekSum
          end
        end
      end
    end
  end
  -- анализ буферов
  inDReplyText = imgui.new.char[256]()
  ed.inLabel    = imgui.new.char[BUF]()
  ed.inKey      = imgui.new.char[32]()
  aed.inLabel   = imgui.new.char[BUF]()
  aed.inSec     = imgui.new.char[16]()
  aed.inLimit   = imgui.new.char[16]()
  cs.buf        = imgui.new.char[4096]()
  nt.buf        = imgui.new.char[4096]()
  inSearchBuf  = imgui.new.char[64]()
  timeRp.inMe      = imgui.new.char[256]()
  timeRp.inDo      = imgui.new.char[256]()
  ffi.copy(timeRp.inMe,      timeRp.meText,            math.min(#timeRp.meText,   255))
  ffi.copy(timeRp.inDo,      timeRp.doText,            math.min(#timeRp.doText,   255))

  loadUserThemes(); loadBinds(); loadAuto(); loadCheatsheet(); loadNotes(); pcall(loadTheme); pcall(loadSinvite); sinviteInitBufs(); pcall(loadTimeRp); pcall(loadRp)
  ffi.fill(timeRp.inMe, 256, 0); ffi.copy(timeRp.inMe, timeRp.meText, math.min(#timeRp.meText, 255))
  ffi.fill(timeRp.inDo, 256, 0); ffi.copy(timeRp.inDo, timeRp.doText, math.min(#timeRp.doText, 255))
  sampAddChatMessage("{FFD700}[TSR-Binder]{FFFFFF} Loaded successfully, Press HOME to activate.", -1)
  sampAddChatMessage("{FFD700}[TSR-Binder]{FFFFFF} Made By Guonith | aka William_DeCasto | Fr Scottdale 03.", -1)

  SCRIPT_ACTIVE = true
  while true do
    wait(0)

    -- перебинд клавиши
    if capturingToggleKey then
      for name, code in pairs(KEY_MAP) do
        if wasKeyPressed(code) then
          TOGGLE_KEY = code
          capturingToggleKey = false
          if FRAC_FILE ~= "" then
            local ff = io.open(FRAC_FILE, "rb")
            local cur = {}
            if ff then local ok,t = pcall(json.decode, ff:read("*a")); ff:close(); if ok and t then cur=t end end
            cur.toggleKey = name
            local fw = io.open(FRAC_FILE, "wb")
            if fw then fw:write(json.encode(cur)); fw:close() end
          end
          sampAddChatMessage(toChat("{FFD700}[TSR-Binder]{FFFFFF} Клавиша открытия: " .. name), -1)
          break
        end
      end
    elseif wasKeyPressed(TOGGLE_KEY) and isGameFocused() then
      showMain[0] = not showMain[0]
    end


    cs.onlyMode = showCheatsheet[0] and not showMain[0]


    if ed.capturingKey and showEditor[0] then
      for name, code in pairs(KEY_MAP) do
        if wasKeyPressed(code) then
          ffi.fill(ed.inKey, 32, 0)
          ffi.copy(ed.inKey, name, math.min(#name, 31))
          ed.capturingKey = false; break
        end
      end
    end

    if not showEditor[0] and not showAutoEditor[0] and isGameFocused() then
      for i, b in ipairs(binds) do
        if b.keyCode and wasKeyPressed(b.keyCode) and not cooldown[i] then
          cooldown[i] = true
          local total = sendBind(b)
          lua_thread.create(function() wait(total+300); cooldown[i]=false end)
        end
      end
    end

    -- авто отыгровка оружия
    if rp.weapon then
      weaponCheckTimer = weaponCheckTimer + 1
      if weaponCheckTimer >= 10 then 
        weaponCheckTimer = 0
        if not isLocalPlayerReady() then
          prevWeapon = -1
        else
        local curWeapon = getCurrentCharWeapon(PLAYER_PED)
        local inCar = isCharInAnyCar(PLAYER_PED)
        if not inCar and curWeapon ~= prevWeapon then
          local wdata = WEAPON_NAMES[curWeapon]
          local pdata = WEAPON_NAMES[prevWeapon]
          if pdata and (curWeapon == 0 or curWeapon == 1) then
            local msg
            if pdata.type == "holster" then
              msg = "/me убрал " .. pdata.name .. " в кобуру"
            else
              local verb = HOLSTER_BACK[math.random(#HOLSTER_BACK)]
              msg = "/me" .. verb .. pdata.name .. HOLSTER_BACK_SFX
            end
            local m = msg
            lua_thread.create(function() wait(300); sampSendChat(toChat(m)) end)
          end
          if wdata and (prevWeapon == 0 or prevWeapon == 1 or prevWeapon == -1) then
            local msg
            if wdata.type == "holster" then
              msg = "/me уверенным жестом достал " .. wdata.name .. " из кобуры"
            else
              local phrase = DRAW_BACK[math.random(#DRAW_BACK)]
              msg = "/me" .. phrase .. wdata.name
            end
            local m = msg
            lua_thread.create(function() wait(300); sampSendChat(toChat(m)) end)
          end
          prevWeapon = curWeapon
        elseif inCar then
          prevWeapon = curWeapon
        end
        end
      end
    end

    local nowT = os.time()
    for _, a in ipairs(autoMsgs) do
      if a.active then
        if nowT - (a.lastSentAt or 0) >= a.interval then
          a.lastSentAt = nowT
          a.count = a.count + 1
          local lines = a.lines or {}
          lua_thread.create(function()
            for _, ln in ipairs(lines) do
              sampSendChat(toChat(ln.text or ""))
              wait(ln.delay or 800)
            end
          end)
          if a.limit > 0 and a.count >= a.limit then
            a.active = false
            a.count  = 0
          end
        end
      end
    end

    if ed.msgTimer   > 0 then ed.msgTimer   = ed.msgTimer   - 1 end
    if aed.msgTimer   > 0 then aed.msgTimer   = aed.msgTimer   - 1 end
    if os.clock() - lastLogFlushAt >= LOG_FLUSH_INTERVAL then
      if deliveryLogDirty then
        saveDeliveryLogNow()
        deliveryLogDirty = false
      end
      if radioLogDirty then
        saveRadioLogNow()
        radioLogDirty = false
      end
      lastLogFlushAt = os.clock()
    end
    if sinvitePendingCmd then
      sampSendChat(sinvitePendingCmd)
      sinvitePendingCmd = nil
    end
  end
end 

-- перехват команд
-- Перехват Escape: закрываем биндер и блокируем передачу в игру
local WM_KEYDOWN = 0x100
local VK_ESCAPE  = 0x1B
function onWindowMessage(msg, wparam, lparam)
  if not SCRIPT_ACTIVE then return end
  if msg == WM_KEYDOWN and wparam == VK_ESCAPE then
    if showMain[0] then
      showMain[0] = false
      consumeWindowMessage(true, false)  -- блокируем Escape, игра не получит его
    end
    -- если биндер закрыт — не блокируем, Escape уйдёт в игру и откроет паузу
  end
end

sampev.onShowDialog = function(id, style, title, button1, button2, text)
  local titleUtf = pcall(function() return _cv_u:iconv(title) end) and _cv_u:iconv(title) or title
  local textUtf = pcall(function() return _cv_u:iconv(text) end) and _cv_u:iconv(text) or text
  dbg("DIALOG id=" .. id .. " style=" .. style .. " title=" .. tostring(titleUtf):sub(1,45))

  local parsed = parseStatsAccess(textUtf)
  if parsed and (rankScan.pending or tostring(titleUtf):lower():find("стат") or tostring(textUtf):find("Организа") or tostring(textUtf):find("Должност")) then
    rankScan.pending = false
    rankScan.org = parsed.org
    rankScan.post = parsed.post
    rankScan.rank = tonumber(parsed.rank) or 0
    if rankScan.rank > 0 then
      rankScan.status = u8"Ранг подтянут"
      refreshRankAccess()
      saveFracState()
      sampAddChatMessage(toChat(string.format("{FFD700}[TSR-Binder]{FFFFFF} Скан ранга: %s | %s | %d ранг", rankScan.org ~= "" and rankScan.org or "?", rankScan.post ~= "" and rankScan.post or "?", rankScan.rank)), -1)
    else
      rankScan.status = u8"Вы не состоите в организации или ранг не распознан."
      refreshRankAccess()
      saveFracState()
      sampAddChatMessage(toChat("{FFAA44}[TSR-Binder]{FFFFFF} /stats прочитан, но числовой ранг не распознан."), -1)
    end
  end
end

sampev.onChatMessage = function(id, color, name, msg)
  dbg("CHAT [" .. tostring(name) .. "]: " .. tostring(msg):sub(1,50))
end

sampev.onSendCommand = function(cmd)
  dbg("CMD: " .. cmd)
  local c = cmd:lower()
  if c == "/stats" then
    rankScan.pending = true
    rankScan.status = u8"Сканирование /stats..."
  end
  if c == "/reload" then
    for _, d in pairs(deliveries) do d.count=0; d.last=""; d.players={} end
    deliveryLog = {}
    wantedCount = 0
    radio.log = {}
    saveRadioLogNow()
    saveDeliveryLogNow()
    deliveryLog = {}
  end

  -- перехват /invite
  if sinviteBypassing then
    sinviteBypassing = false
    return 
  end
  if smartInvite and c:match("^/invite%s+(%d+)") then
    local idStr = c:match("^/invite%s+(%d+)")
    local targetId = tonumber(idStr)
    if targetId then
      if not sampIsPlayerConnected(targetId) then
        sampAddChatMessage(toChat("{FF4444}[Smart-invite] Игрок с ID " .. targetId .. " не найден."), -1)
        return false
      end
      -- проверка расстояния
      local ok, x, y, z = pcall(sampGetPlayerPos, targetId)
      if ok and isLocalPlayerReady() then
        local px, py, pz = getCharCoordinates(PLAYER_PED)
        local dist = math.sqrt((x-px)^2 + (y-py)^2 + (z-pz)^2)
        if dist > 5 then
          sampAddChatMessage(toChat("{FF4444}[Smart-invite] Игрок слишком далеко (" .. math.floor(dist) .. " м)."), -1)
          return false
        end
      end

      local name = sampGetPlayerNickname(targetId) or ("ID_" .. targetId)
      sinvSession.active     = true
      sinvSession.targetId   = targetId
      sinvSession.targetName = name
      sinvSession.stage      = 1
      showSinvWindow[0]      = true
      if #sinviteStages > 0 then
        local stage = sinviteStages[1]
        lua_thread.create(function()
          for _, ln in ipairs(stage.lines) do
            local txt = sinvGetText(ln)
            if txt ~= "" then sampSendChat(toChat(txt)) end
            wait(sinvGetDelay(ln))
          end
        end)
      end
      return false 
    end
  end

  -- /time
  if rp.time and c == "/time" then
    lua_thread.create(function()
      wait(timeRp.meDelay or 1200)
      sampSendChat(toChat(timeRp.meText))
      wait(timeRp.doDelay or 3100)
      if timeRp.useDo then
        local doMsg = timeRp.doText:gsub("{time}", os.date("%H:%M:%S"))
        sampSendChat(toChat("/do " .. doMsg))
      end
    end)
  end

  -- /mask toggle
  if rp.mask and c == "/mask" then
    rp.maskBlocked = false
    -- Убиваем старый таймер если есть
    if rp.maskTimer then
      rp.maskTimer = nil
    end
    local wasMaskOn = rp.maskOn
    lua_thread.create(function()
      wait(800)
      if rp.maskBlocked then
        rp.maskBlocked = false
        return
      end
      if not wasMaskOn then
        -- Надеваем маску
        sampSendChat(toChat("/me медленно натянул маску на лицо, скрыв черты"))
        rp.maskOn = true
        rp.maskPutOnTime = os.time()
        -- Запускаем новый таймер
        local putOnTime = rp.maskPutOnTime
        rp.maskTimer = lua_thread.create(function()
          wait(1800 * 1000)
          -- Проверяем что это тот же "сеанс" маски
          if rp.maskOn and rp.maskPutOnTime == putOnTime then
            sampSendChat(toChat("/me стянул маску с лица и убрал её в карман"))
            rp.maskOn = false
            rp.maskTimer = nil
          end
        end)
      else
        -- Снимаем маску вручную
        sampSendChat(toChat("/me стянул маску с лица и убрал её в карман"))
        rp.maskOn = false
        rp.maskTimer = nil
      end
    end)
  end

  -- /armour toggle
  if rp.armour and c == "/armour" then
    lua_thread.create(function()
      local wasOn = armourOn
      wait(800)
      if not isLocalPlayerReady() then
        armourOn = false
        return
      end
      local armourVal = getCharArmour(PLAYER_PED)
      if not wasOn then
        if armourVal > 0 then
          sampSendChat(toChat("/me накинул на себя бронежилет, застегнув все крепления"))
          armourOn = true
        end
      else
        if armourVal == 0 then
          sampSendChat(toChat("/me снял с себя бронежилет и отложил в сторону"))
          armourOn = false
        end
      end
    end)
  end
end

function onScriptTerminate(script, quitGame)
  if script ~= thisScript() then return end
  if deliveryLogDirty then
    saveDeliveryLogNow()
    deliveryLogDirty = false
  end
  if radioLogDirty then
    saveRadioLogNow()
    radioLogDirty = false
  end
  exportReadableLogs()
end


_cv_u = iconv.new("UTF-8", "CP1251")
sampev.onServerMessage = function(color, msg)
  local msgUtf = _cv_u:iconv(msg) or msg
  dbg("SRV [" .. string.format("%06X", color) .. "]: " .. msgUtf:sub(1,55))
  if msgUtf:find("У Вас нет маски") or msgUtf:find("У вас нет маски") then
    rp.maskBlocked = true
  end
  -- сбрасываем состояние без отыгровки по истечении времени
  if rp.maskOn and (msgUtf:find("аска.*снята") or msgUtf:find("аска.*истек") or msgUtf:find("аска.*закончил")) then
    rp.maskOn = false
    rp.maskTimer = nil
  end

  -- поставки на склад
  do
    local amount, goods, factory = msgUtf:match("(%d[%d.,]*)%s+(%S+)%s+на склад завода%s+(.*)")
    if amount and factory then
      local entry = nil
      local fl = factory:lower()
      if fl:find("тср") or fl:find("tsr") then
        entry = deliveries.TSR
      elseif fl:find("лс") or fl:find("лос") or fl:find("ls") or fl:find("армии л") then
        entry = deliveries.LS
      elseif fl:find("сф") or fl:find("sf") or fl:find("санта") or fl:find("армии с") then
        entry = deliveries.SF
      else
        entry = deliveries.TSR 
      end
      entry.count = entry.count + 1
      entry.last  = amount .. " " .. goods
      local pname = msgUtf:match("^([%w_]+)%[%d+%]")
      if pname then
        entry.players[pname] = (entry.players[pname] or 0) + 1
        local logEntry = {
          type    = "delivery",
          date    = os.date("%d.%m.%Y"),
          time    = os.date("%H:%M:%S"),
          player  = pname,
          amount  = amount,
          goods   = goods,
          factory = factory,
        }
        table.insert(deliveryLog, 1, logEntry)
        if #deliveryLog > MAX_LOG then table.remove(deliveryLog) end
        -- сейв лог файла
        deliveryLogDirty = true
      end
    end
  end

  do
    local player, text = msgUtf:match("%[R%].-%s([%u][%a]*_[%w_]+%[%d+%]):%s*(.*)")
    if not player then
      player, text = msgUtf:match("%[R%].+([%u][%w_]+%[%d+%]):%s*(.*)")
    end
    if player then
      local pname = player:match("(.-)%[") or player
      local isNrp = text:find("%(%(") ~= nil 
      table.insert(radio.log, 1, {
        date   = os.date("%d.%m.%Y"),
        time   = os.date("%H:%M:%S"),
        player = pname,
        text   = text,
        isNrp  = isNrp,
      })
      if #radio.log > MAX_RADIO then table.remove(radio.log) end
      radioLogDirty = true
    end
  end

  do
    local clean = msgUtf:gsub("{%x%x%x%x%x%x}", "")
    if clean:find("%[%D") and clean:find("розыск") and clean:find("звезд") then
      local player, stars, accuser =
        clean:match("([%u][%w_%-]+)%[%d+%]%s+%S+%s+%S+%s+в розыск на%s+(%d+)%s+%S+%.%s+%S+:%s+([%w_%(%)%d]+)")
      if not player then
        player, stars = clean:match("([%u][%D]+)%s+%S+%s+%S+%s+в розыск на%s+(%d+)")
        accuser = ""
      end
      if player then
        player = player:match("^%s*(.-)%s*$") 
      end
      if player and stars then
        local entry = {
          type    = "wanted",
          date    = os.date("%d.%m.%Y"),
          time    = os.date("%H:%M:%S"),
          player  = player,
          stars   = stars,
          accuser = accuser or "",
          reason  = "",
        }
        wantedCount = wantedCount + 1
        wantedPending = entry
        table.insert(deliveryLog, 1, entry)
        if #deliveryLog > MAX_LOG then table.remove(deliveryLog) end
        deliveryLogDirty = true
      end

    elseif clean:find("Причина:") and not clean:find("звезд") and not clean:find("полицию") and wantedPending ~= nil then
      local reason = clean:match("Причина:%s*(.+)")

      if reason then
        for _, e in ipairs(deliveryLog) do
          if e.type == "wanted" and (e.reason == nil or e.reason == "") then
            e.reason = reason:match("^(.-)%s*$") -- trim trailing spaces

            deliveryLogDirty = true
            break
          end
        end
      end

    elseif clean:find("нимание") and clean:find("розыск") then
      local player = clean:match("([%u][%w_]+)%[%d+%]")
      local reason = clean:match("Причина:%s*([^|]+)")
      local stars  = clean:match("[Уу]ровень розыска:%s*(%d+)")
      if player then
        if reason then reason = reason:match("^%s*(.-)%s*$") end
        local entry = {
          type    = "wanted",
          date    = os.date("%d.%m.%Y"),
          time    = os.date("%H:%M:%S"),
          player  = player,
          stars   = stars or "?",
          accuser = "",
          reason  = reason or "",
        }
        wantedCount = wantedCount + 1
        table.insert(deliveryLog, 1, entry)
        if #deliveryLog > MAX_LOG then table.remove(deliveryLog) end
        deliveryLogDirty = true
      end

    elseif clean:find("вызывает полицию") then
      local player, city, location =
        clean:match("([%u][%w_]+)%[%d+%]%s+с города '([^']+)',%s*вызывает полицию,%s*местоположение:%s*(.+)")
      if player then
        if location then location = location:match("^(.-)%.?%s*$") end
        local entry = {
          type     = "police",
          date     = os.date("%d.%m.%Y"),
          time     = os.date("%H:%M:%S"),
          player   = player,
          city     = city or "",
          location = location or "",
          reason   = "",
        }
        wantedCount = wantedCount + 1
        wantedPending = entry
        table.insert(deliveryLog, 1, entry)
        if #deliveryLog > MAX_LOG then table.remove(deliveryLog) end
        deliveryLogDirty = true
      end
    elseif clean:find("очистил розыск") then
      local rank, cop, target = clean:match("(%S+)%s+([%u][%w_]+)%s+очистил розыск%s+([%u][%w_]+)%[%d+%]")
      if cop and target then
        local entry = {
          type   = "clearwanted",
          date   = os.date("%d.%m.%Y"),
          time   = os.date("%H:%M:%S"),
          cop    = cop,
          rank   = rank or "",
          target = target,
        }
        wantedCount = wantedCount + 1
        table.insert(deliveryLog, 1, entry)
        if #deliveryLog > MAX_LOG then table.remove(deliveryLog) end
        deliveryLogDirty = true
      end

    elseif clean:find("угон") and clean:find("/theft") then
      local entry = {
        type  = "theft",
        date  = os.date("%d.%m.%Y"),
        time  = os.date("%H:%M:%S"),
      }
      wantedCount = wantedCount + 1
      table.insert(deliveryLog, 1, entry)
      if #deliveryLog > MAX_LOG then table.remove(deliveryLog) end
      deliveryLogDirty = true

    elseif clean:find("ричина вызова:") then
      local reason = clean:match("ричина вызова:%s*(.+)")
      if reason and wantedPending and wantedPending.type == "police" then
        wantedPending.reason = reason
        wantedPending = nil
        deliveryLogDirty = true
      end
    end
  end

  do
    local senderFull, from, to, text = msgUtf:match(
      "%[D%].+([%u][%w_]+%[%d+%]):%s*%[([^%]]+)%]%s+[Tt][Oo]%s+%[([^%]]+)%]:?%s*(.*)")
    if not senderFull then
      senderFull, from, to, text = msgUtf:match(
        "%[D%].+([%u][%w_]+%[%d+%]):%s*%[([^%]]+)%]%s*%-%s*%[([^%]]+)%]:?%s*(.*)")
    end
    -- неработающая хуйня я ее рот ебал
    local sender = senderFull and senderFull:match("(.-)%[") or senderFull

    if sender then
      local prevSelected = dSelected
      table.insert(dHistory, 1, {
        sender = sender, from = from, to = to, text = text or "",
      })
      if #dHistory > 10 then table.remove(dHistory) end
      -- фикс выбранного сообщения
      if prevSelected > 0 and prevSelected <= #dHistory then
        dSelected = prevSelected + 1
        if dSelected > #dHistory then dSelected = #dHistory end
      else
        dSelected = 1
      end
      showDReply = true
      if myFraction ~= "" and canUseDReply() then
        local shouldOpen = false
        if dAutoOpen == 1 then
          shouldOpen = true
        elseif dAutoOpen == 2 then
          -- Открываем только если to совпадает с нашей фракцией по реестру
          if myFraction ~= "" then
            local toRaw = (to or ""):lower()
            -- Ищем нашу фракцию в реестре
            for _, fr in ipairs(FRAC_REGISTRY) do
              if fr.id == myFraction then
                for _, v in ipairs(fr.variants) do
                  if toRaw == v or toRaw:find(v, 1, true) then
                    shouldOpen = true
                    break
                  end
                end
                break
              end
            end
            -- Также проверяем прямое совпадение (id в любом регистре)
            if not shouldOpen then
              local frLow = myFraction:lower()
              shouldOpen = (toRaw == frLow) or (toRaw:find(frLow, 1, true) ~= nil)
            end
          end
        end
        if shouldOpen then
          showDWindow[0] = true
          if inDReplyText and not showDWindow[0] then ffi.fill(inDReplyText, 256, 0) end
        end
      end
    end

  end
end

-- главное окно и вспомогательные функции
local function drawSinviteTab()
  imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabinact, 0.90))
  imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
  imgui.PushStyleColor(imgui.Col.ButtonActive,  v4(T.tabact))
  imgui.PushStyleColor(imgui.Col.Text,          imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
  if imgui.Button("< ##sinvback", imgui.ImVec2(22, 20)) then
    activeTab = 3
  end
  imgui.PopStyleColor(4)
  imgui.SameLine()
  local sinvTitleW = imgui.CalcTextSize(u8"SmartInv Settings").x
  imgui.SetCursorPosX((imgui.GetWindowWidth() - sinvTitleW) * 0.5)
  imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.75, 0.75, 0.75, 1.0))
  imgui.Text(u8"SmartInv Settings")
  imgui.PopStyleColor()
  imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(0.50, 0.50, 0.50, 0.80))
  imgui.Separator()
  imgui.PopStyleColor()
  imgui.Spacing()

  local sinvH = imgui.GetContentRegionAvail().y - 30
  imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0,0,0,0))
  imgui.BeginChild("##sinvscroll", imgui.ImVec2(-1, sinvH), false)

  local toDelStage = nil
  local toDelLine  = nil

  for si, stage in ipairs(sinviteStages) do
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Этап " .. si)
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.85))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
    if imgui.Button(u8"Удалить##sdel"..si, imgui.ImVec2(60, 18)) then toDelStage = si end
    imgui.PopStyleColor(2)

    for li, line in ipairs(stage.lines) do
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55,0.55,0.55,1.0))
      imgui.Text(string.format("%2d", li))
      imgui.PopStyleColor()
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.frame))
      imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.frameh))
      imgui.PushItemWidth(imgui.GetWindowWidth() - 100)
      if line.buf then imgui.InputText("##sl"..si.."_"..li, line.buf, 256) end
      imgui.PopItemWidth()
      imgui.SameLine()
      imgui.PushItemWidth(40)
      if line.dbuf then imgui.InputText("##sd"..si.."_"..li, line.dbuf, 8) end
      imgui.PopItemWidth()
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.85))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
      if imgui.Button("X##sx"..si.."_"..li, imgui.ImVec2(18, 18)) and #stage.lines > 1 then
        toDelLine = {stage=si, line=li}
      end
    end

    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnlink, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnlinkh))
    if imgui.Button(u8"+строка##sadd"..si, imgui.ImVec2(70, 18)) then
      local nb = imgui.new.char[256](); local db = imgui.new.char[8]()
      ffi.copy(db, "800", 3)
      table.insert(stage.lines, {text="", delay=800, buf=nb, dbuf=db})
    end
    imgui.PopStyleColor(2)
    imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(0.35,0.35,0.35,0.60))
    imgui.Separator(); imgui.PopStyleColor(); imgui.Spacing()
  end

  if toDelStage then table.remove(sinviteStages, toDelStage) end
  if toDelLine  then table.remove(sinviteStages[toDelLine.stage].lines, toDelLine.line) end

  imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
  imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
  if imgui.Button(u8"+ Добавить этап##saddstage", imgui.ImVec2(-1, 22)) then
    local nb = imgui.new.char[256](); local db = imgui.new.char[8]()
    ffi.copy(db, "800", 3)
    table.insert(sinviteStages, {lines={{text="", delay=800, buf=nb, dbuf=db}}})
  end
  imgui.PopStyleColor(2)

  imgui.Spacing()
  imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(0.50,0.50,0.50,0.80))
  imgui.Separator(); imgui.PopStyleColor(); imgui.Spacing()
  imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.35, 0.35, 1.0))
  imgui.Text(u8"Этап отказа (Discard)")
  imgui.PopStyleColor(); imgui.Spacing()

  local toDelDecline = nil
  for li, line in ipairs(sinviteDecline.lines) do
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55,0.55,0.55,1.0))
    imgui.Text(string.format("%2d", li)); imgui.PopStyleColor(); imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.frame))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.frameh))
    imgui.PushItemWidth(imgui.GetWindowWidth() - 100)
    if line.buf then imgui.InputText("##dl_"..li, line.buf, 256) end
    imgui.PopItemWidth(); imgui.SameLine()
    imgui.PushItemWidth(40)
    if line.dbuf then imgui.InputText("##dd_"..li, line.dbuf, 8) end
    imgui.PopItemWidth(); imgui.PopStyleColor(2); imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.85))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
    if imgui.Button("X##dx_"..li, imgui.ImVec2(18, 18)) and #sinviteDecline.lines > 1 then
      toDelDecline = li
    end
    imgui.PopStyleColor(2)
  end
  if toDelDecline then table.remove(sinviteDecline.lines, toDelDecline) end

  imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnlink, 0.90))
  imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnlinkh))
  if imgui.Button(u8"+строка##daddline", imgui.ImVec2(70, 18)) then
    local nb = imgui.new.char[256](); local db = imgui.new.char[8]()
    ffi.copy(db, "800", 3)
    table.insert(sinviteDecline.lines, {text="", delay=800, buf=nb, dbuf=db})
  end
  imgui.PopStyleColor(2)

  imgui.EndChild()
  imgui.PopStyleColor()

  imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
  imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
  if imgui.Button(u8"СОХРАНИТЬ##sinvsave", imgui.ImVec2(-1, 26)) then
    saveSinvite()
    sampAddChatMessage(toChat("{FFD700}[TSR-Binder]{FFFFFF} Smart-invite сохранён."), -1)
  end
  imgui.PopStyleColor(2)
end

-- UI главного окна            
function drawMainWindow(self)
    self.HideCursor = isKeyDown(2)
    imgui.PushStyleColor(imgui.Col.WindowBg,       v4(T.winbg, 0.97))
    imgui.PushStyleColor(imgui.Col.TitleBgActive,  v4(T.titlehi))
    imgui.PushStyleColor(imgui.Col.TitleBg,        v4(T.titlebg))
    imgui.PushStyleColor(imgui.Col.Button,         v4(T.btn, 0.85))
    imgui.PushStyleColor(imgui.Col.ButtonHovered,  v4(T.btnh))
    imgui.PushStyleColor(imgui.Col.ButtonActive,   v4(T.btna))
    imgui.PushStyleColor(imgui.Col.Separator,      v4(T.sep, 0.35))

    imgui.SetNextWindowPos(imgui.ImVec2(30, 100), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(300, 100), imgui.ImVec2(380, 700))
    imgui.Begin(u8"TSR-BINDER " .. SCRIPT_VERSION .. " | Made By Guonith & !.Dyshno", showMain, imgui.WindowFlags.NoScrollbar)

    -- таймеры сессия/неделя
    do
      local sessSecs = os.time() - tm.sessionStart
      local todayKey = os.date("%Y-%m-%d")
      local todayTotal = (tm.dayStatsBase[todayKey] or 0) + sessSecs
      local sessStr  = u8"Сессия: " .. formatTime(sessSecs)
      local weekStr  = u8"Неделя: " .. formatTime(tm.weekSeconds + todayTotal)
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.75, 0.75, 0.75, 1.0))
      imgui.Text(sessStr)
      imgui.SameLine()
      local weekX = imgui.GetWindowWidth() - imgui.CalcTextSize(weekStr).x - 10
      imgui.SetCursorPosX(weekX)
      imgui.Text(weekStr)
      imgui.PopStyleColor()

      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1.0, 1.0, 1.0, 0.18))
      imgui.Separator()
      imgui.PopStyleColor()
      if os.time() - tm.lastSaveTime >= 30 and TIME_FILE ~= "" then
        tm.lastSaveTime = os.time()
        local tf = io.open(TIME_FILE, "wb")
        if tf then
          local days = {}
          for k,v in pairs(dayStats) do days[k] = v end
          days[todayKey] = todayTotal
          tf:write(json.encode({ week = tm.weekSeconds + todayTotal, savedAt = os.time(), days = days, prevDays = prevWeekStats, prevWeek = prevWeekTotal }))
          tf:close()
        end
      end
    end
    imgui.Spacing()

    if tabBtn(u8"[БИНДЫ]", activeTab==1, 70) then activeTab=1 end
    imgui.SameLine()
    if tabBtn(u8"[АВТО-MSG]", activeTab==2) then activeTab=2 end

    imgui.SameLine()
    if canUseLogs() then
      imgui.PushStyleColor(imgui.Col.Button,        showLogs[0] and v4(T.tabact) or v4(T.tabinact, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
      if imgui.Button(u8"[logs]", imgui.ImVec2(52, 24)) then
        showLogs[0] = not showLogs[0]
      end
      imgui.PopStyleColor(2)
      imgui.SameLine()
    end
    imgui.SameLine()

    do
      local hasDMsg = showDReply and myFraction ~= "" and canUseDReply()
      if hasDMsg then
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.cneutral, 0.95))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.cneutralh))
      else
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabinact, 0.50))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabinh, 0.50))
      end
      if imgui.Button(u8"/d", imgui.ImVec2(26, 24)) and hasDMsg then
        showDWindow[0] = not showDWindow[0]
      end
      if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        if hasDMsg then
          imgui.Text(u8"Ответить: " .. lastD_sender() .. " [" .. lastD_from() .. "]")
        else
          imgui.Text(u8"Нет входящих /d")
        end
        imgui.EndTooltip()
      end
      imgui.PopStyleColor(2)
    end
    imgui.SameLine()
    -- настройки
    if activeTab == 3 then
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabact))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
    else
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabinact, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabinh))
    end
    if imgui.Button("S", imgui.ImVec2(24, 24)) then
      activeTab = (activeTab == 3) and 1 or 3
    end
    if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.Text("Settings")
      imgui.EndTooltip()
    end
    imgui.PopStyleColor(2)
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Button,        v4(T.cheatbtn, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.cheatbtnh))
    imgui.PushStyleColor(imgui.Col.ButtonActive,  v4(T.cheatbtna))
    if imgui.Button(u8"?", imgui.ImVec2(24, 24)) then
      showCheatsheet[0] = not showCheatsheet[0]
    end
    if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.Text("Cheatsheet")
      imgui.EndTooltip()
    end
    imgui.PopStyleColor(3)
    imgui.SameLine()
    -- кнопка ts
    if activeTab == 4 then
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabact))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
    else
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabinact, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabinh))
    end
    imgui.PushStyleColor(imgui.Col.ButtonActive, v4(T.btna))
    if imgui.Button("TS", imgui.ImVec2(24, 24)) then
      activeTab = (activeTab == 4) and 1 or 4
    end
    if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.Text("Time Statistic")
      imgui.EndTooltip()
    end
    imgui.PopStyleColor(3)
    imgui.Separator()

    -- бинды
    if activeTab == 1 then
      imgui.Spacing()
      if inSearchBuf then
        imgui.PushStyleColor(imgui.Col.FrameBg,        imgui.ImVec4(0.08, 0.08, 0.08, 0.90))
        imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.12, 0.12, 0.12, 0.95))
        imgui.PushItemWidth(imgui.GetWindowWidth() * 0.50)
        imgui.InputTextWithHint(u8"##search", u8"Поиск...", inSearchBuf, 64)
        imgui.PopItemWidth()
        local dl = imgui.GetWindowDrawList()
        local p = imgui.GetItemRectMin()
        local s = imgui.GetItemRectMax()
        dl:AddRect(p, s, imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.45, 0.45, 0.45, 0.80)), 3.0)
        imgui.PopStyleColor(2)
      end
      imgui.Spacing()
      if #binds == 0 then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.5, 0.5, 0.5, 1.0))
        imgui.TextWrapped(u8"Нажмите ДОБАВИТЬ чтобы добавить бинд")
        imgui.PopStyleColor()
      else
        local ROW_H    = 26
        local MAX_ROWS = 11
        local needScroll = #binds > MAX_ROWS
        local childH   = math.min(#binds, MAX_ROWS) * ROW_H
        imgui.PushStyleColor(imgui.Col.ChildBg,              imgui.ImVec4(0,0,0,0))
        imgui.PushStyleColor(imgui.Col.ScrollbarBg,          imgui.ImVec4(0,0,0,0.20))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrab,        v4(T.btn, 0.50))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabHovered, v4(T.btnh, 0.70))
        local scrollFlags = needScroll and 0 or imgui.WindowFlags.NoScrollbar
        imgui.BeginChild("##bindsscroll", imgui.ImVec2(-1, childH), false, scrollFlags)
        local searchQ = inSearchBuf and ffi.string(inSearchBuf) or ""
        for i, b in ipairs(binds) do
          if searchQ ~= "" and not strContains(b.label, searchQ) then
            goto continue_search
          end
          do

          local busy = cooldown[i]
          if b.keyStr and b.keyStr ~= "" then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.65, 0.0, 0.85))
            imgui.Text("["..b.keyStr.."]")
            imgui.PopStyleColor()
            imgui.SameLine()
          end
          if busy then
            imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(0.00, 0.45, 0.15, 0.85))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.60, 0.20, 1.00))
          end
          local winW = imgui.GetWindowWidth()
          local btnW = winW - (22 * 5) - 56 
          if b.keyStr and b.keyStr ~= "" then
            btnW = btnW - (imgui.CalcTextSize("["..b.keyStr.."]").x + 8)
          end
          if btnW < 40 then btnW = 40 end
          if imgui.Button(b.label.."##btn"..i, imgui.ImVec2(btnW, 22)) then
            if not busy then
              cooldown[i] = true
              local total = sendBind(b)
              lua_thread.create(function() wait(total+300); cooldown[i]=false end)
            end
          end

          if busy then imgui.PopStyleColor(2) end
          imgui.SameLine()

          imgui.PushStyleColor(imgui.Col.Button,        v4(T.cneutral, 0.85))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.cneutralh))
          if imgui.Button("C##c"..i, imgui.ImVec2(22, 22)) then
            bop.copyIdx = i
          end
          imgui.PopStyleColor(2)
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.aneutral, 0.85))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.aneutralh))
          if imgui.Button("^##u"..i, imgui.ImVec2(22, 22)) and i > 1 then
            bop.swapIdx = i
            bop.swapDir = -1
          end
          imgui.SameLine()
          if imgui.Button("v##dn"..i, imgui.ImVec2(22, 22)) and i < #binds then
            bop.swapIdx = i
            bop.swapDir = 1
          end
          imgui.PopStyleColor(2)
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.neutral, 0.85))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.neutralh))
          if imgui.Button("E##e"..i, imgui.ImVec2(22, 22)) then openEdit(i) end
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.85))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
          if imgui.Button("X##d"..i, imgui.ImVec2(22, 22)) then
            bop.deleteIdx = i
          end
          imgui.PopStyleColor(4)
          end
          ::continue_search::
        end
        imgui.EndChild()
        imgui.PopStyleColor(4)
      end

      if bop.deleteIdx ~= 0 then
        table.remove(binds, bop.deleteIdx)
        saveBinds()
        bop.deleteIdx = 0
      end
      if bop.copyIdx ~= 0 then
        local b = binds[bop.copyIdx]
        if b then
          local entries = {}
          for _, e in ipairs(b.entries) do
            table.insert(entries, {text=e.text, delay=e.delay})
          end
          local copy = {label=b.label.." (2)", keyStr=b.keyStr or "", keyCode=keyStrToCode(b.keyStr), entries=entries}
          table.insert(binds, bop.copyIdx+1, copy)
          saveBinds()
        end
        bop.copyIdx = 0
      end
      if bop.swapIdx ~= 0 then
        local j = bop.swapIdx + bop.swapDir
        if j >= 1 and j <= #binds then
          binds[bop.swapIdx], binds[j] = binds[j], binds[bop.swapIdx]
          saveBinds()
        end
        bop.swapIdx = 0; bop.swapDir = 0
      end
      imgui.Separator()
      local anyBusy = false
      for _, v in pairs(cooldown) do if v then anyBusy = true; break end end
      if anyBusy and not bindStopFlag then
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
        if imgui.Button(u8"!! СТОП", imgui.ImVec2(-1, 24)) then
          bindStopFlag = true
          for k in pairs(cooldown) do cooldown[k] = false end
        end
        imgui.PopStyleColor(2)
      else
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
        if imgui.Button(u8"+ ДОБАВИТЬ БИНД", imgui.ImVec2(-1, 24)) then openNew() end
        imgui.PopStyleColor(2)
      end
      if lastSent ~= "" then
        imgui.Spacing()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 1.0))
        imgui.TextWrapped(">> "..lastSent)
        imgui.PopStyleColor()
      end
      local anyDelivery = canUseLogs() and (deliveries.TSR.count > 0 or deliveries.LS.count > 0 or deliveries.SF.count > 0)
      if anyDelivery then
        imgui.Spacing()
        local rows = {
          { key="TSR", label=u8"ТСР",      d=deliveries.TSR },
          { key="LS",  label=u8"Армия ЛС", d=deliveries.LS  },
          { key="SF",  label=u8"Армия СФ", d=deliveries.SF  },
        }
        for _, row in ipairs(rows) do
          if row.d.count > 0 then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.20, 0.75, 0.30, 1.0))
            imgui.Text(u8"Склад " .. row.label .. ": " .. row.d.count .. u8" пост.")
            imgui.PopStyleColor()
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.35, 0.35, 0.35, 1.0))
            imgui.Text(u8"  >> " .. row.d.last)
            for pname, cnt in pairs(row.d.players) do
              imgui.Text(u8"     " .. pname .. ": " .. cnt)
            end
            imgui.PopStyleColor()
          end
        end
      end
    end

    -- авто msg
    if activeTab == 2 then
      if #autoMsgs == 0 then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.5, 0.5, 0.5, 1.0))
        imgui.TextWrapped(u8"Шаблонов авто-сообщений нету, используйте ДОБАВИТЬ чтобы сделать их")
        imgui.PopStyleColor()
      else
        for i, a in ipairs(autoMsgs) do
          if a.active then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.2, 0.9, 0.3, 1.0))
            imgui.Text("[ON]")
            imgui.PopStyleColor()
          else
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.35, 0.35, 0.35, 1.0))
            imgui.Text("[--]")
            imgui.PopStyleColor()
          end
          imgui.SameLine()

          local lbl = a.label
          if a.active then
            local elapsed = os.time() - (a.lastSentAt or 0)
            local rem = math.max(0, a.interval - elapsed)
            local limitInfo = (a.limit > 0) and (" "..a.count.."/"..a.limit) or ""
            lbl = a.label.." ("..fmtTime(rem)..limitInfo..")"
          end
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.85, 0.85, 0.85, 1.0))
          imgui.Text(lbl)
          imgui.PopStyleColor()
          imgui.SameLine()

          if a.active then
            imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg2, 0.90))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnneg2h))
            if imgui.Button("STOP##s"..i, imgui.ImVec2(48, 20)) then
              a.active=false; a.elapsed=0; a.count=0
            end
          else
            imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos2, 0.90))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnpos2h))
            if imgui.Button("START##s"..i, imgui.ImVec2(48, 20)) then
              a.active=true; a.elapsed=0; a.count=0
            end
          end
          imgui.PopStyleColor(2)
          imgui.SameLine()

          imgui.PushStyleColor(imgui.Col.Button,        v4(T.neutral, 0.85))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.neutralh))
          if imgui.Button("E##ae"..i, imgui.ImVec2(22, 20)) then openAutoEdit(i) end
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.85))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
          if imgui.Button("X##ad"..i, imgui.ImVec2(22, 20)) then
            table.remove(autoMsgs, i); saveAuto()
          end
          imgui.PopStyleColor(4)
        end
      end

      imgui.Separator()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
      if imgui.Button(u8"+ ДОБАВИТЬ АВТО-MSG", imgui.ImVec2(-1, 24)) then openAutoNew() end
      imgui.PopStyleColor(2)
    end

    if activeTab == 4 then
      -- статистика активности
      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.Text(u8"График активности — текущая неделя")
      imgui.PopStyleColor()
      imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1,1,1,0.18))
      imgui.Separator()
      imgui.PopStyleColor()
      imgui.Spacing()

      -- определение понедельника
      local now  = os.time()
      local t    = os.date("*t", now)
      local wday = t.wday  
      local daysSinceMon = (wday == 1) and 6 or (wday - 2)
      local sessSecs = os.time() - tm.sessionStart
      local todayKey = os.date("%Y-%m-%d")

      for d = 0, 6 do
        local dayTs  = now - (daysSinceMon - d) * 86400
        local dayKey = os.date("%Y-%m-%d", dayTs)
        local secs = dayStats[dayKey] or 0
        if dayKey == todayKey then
          secs = (tm.dayStatsBase[todayKey] or 0) + sessSecs
        end
        local isToday = (dayKey == todayKey)
        local dayName = DAY_NAMES[d + 1]

        -- метка дня
        if isToday then
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.20, 1.0))
        else
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70, 0.70, 0.70, 1.0))
        end
        imgui.Text(dayName)
        imgui.PopStyleColor()
        imgui.SameLine(imgui.GetWindowWidth() * 0.46)

        -- время
        if secs > 0 then
          imgui.PushStyleColor(imgui.Col.Text, isToday
            and imgui.ImVec4(0.40, 0.90, 0.50, 1.0)
            or  imgui.ImVec4(0.55, 0.75, 0.55, 1.0))
        else
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.35, 0.35, 0.35, 1.0))
        end
        imgui.Text(secs > 0 and formatTime(secs) or u8"—")
        imgui.PopStyleColor()
      end

      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1,1,1,0.18))
      imgui.Separator()
      imgui.PopStyleColor()
      imgui.Spacing()
      -- Итог за неделю
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.Text(u8"Итого за неделю:")
      imgui.PopStyleColor()
      imgui.SameLine(imgui.GetWindowWidth() * 0.46)
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.90, 0.50, 1.0))
      imgui.Text(formatTime(tm.weekSeconds + (tm.dayStatsBase[todayKey] or 0) + sessSecs))
      imgui.PopStyleColor()
      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1,1,1,0.18))
      imgui.Separator()
      imgui.PopStyleColor()
      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.Text(u8"Прошлая неделя")
      imgui.PopStyleColor()
      imgui.Spacing()

      if next(prevWeekStats) == nil then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.35, 0.35, 0.35, 1.0))
        imgui.Text(u8"  Нет данных")
        imgui.PopStyleColor()
      else
        local prevMon = now - (daysSinceMon + 7) * 86400
        for d = 0, 6 do
          local dayTs  = prevMon + d * 86400
          local dayKey = os.date("%Y-%m-%d", dayTs)
          local secs   = prevWeekStats[dayKey] or 0
          local dayName = DAY_NAMES[d + 1]
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
          imgui.Text(dayName)
          imgui.PopStyleColor()
          imgui.SameLine(imgui.GetWindowWidth() * 0.46)
          imgui.PushStyleColor(imgui.Col.Text, secs > 0
            and imgui.ImVec4(0.45, 0.65, 0.45, 1.0)
            or  imgui.ImVec4(0.30, 0.30, 0.30, 1.0))
          imgui.Text(secs > 0 and formatTime(secs) or u8"—")
          imgui.PopStyleColor()
        end
        imgui.Spacing()
        imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1,1,1,0.18))
        imgui.Separator()
        imgui.PopStyleColor()
        imgui.Spacing()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.65, 0.55, 0.0, 1.0))
        imgui.Text(u8"Итого за прошлую неделю:")
        imgui.PopStyleColor()
        imgui.SameLine(imgui.GetWindowWidth() * 0.46)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.35, 0.70, 0.40, 1.0))
        imgui.Text(formatTime(prevWeekTotal))
        imgui.PopStyleColor()
      end
    end

    if activeTab == 3 then
      imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1.0, 1.0, 1.0, 0.18))
      imgui.Spacing()

      local function settingRow(label, state, labelOn, labelOff, extraBtn)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
        imgui.Text(label)
        imgui.PopStyleColor()
        imgui.SameLine(imgui.GetWindowWidth() * 0.46)
        local btnW = extraBtn and (imgui.GetWindowWidth() * 0.50 - 44) or (imgui.GetWindowWidth() * 0.50)
        if state then
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos2, 0.90))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnpos2h))
          imgui.Button(labelOn.."##"..label, imgui.ImVec2(btnW, 24))
          imgui.PopStyleColor(2)
          if imgui.IsItemClicked() then return false end
        else
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg4, 0.90))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnneg4h))
          imgui.Button(labelOff.."##"..label, imgui.ImVec2(btnW, 24))
          imgui.PopStyleColor(2)
          if imgui.IsItemClicked() then return true end
        end
        return state
      end

      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.Text(u8"Клавиша открытия:")
      imgui.PopStyleColor()
      imgui.SameLine(imgui.GetWindowWidth() * 0.46)
      if capturingToggleKey then
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.btna, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btn))
        if imgui.Button(u8">> НАЖМИТЕ КЛАВИШУ##togglecap", imgui.ImVec2(-1, 24)) then
          capturingToggleKey = false
        end
        imgui.PopStyleColor(2)
      else
        local curKeyName = "HOME"
        for name, code in pairs(KEY_MAP) do
          if code == TOGGLE_KEY then curKeyName = name; break end
        end
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos2, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnpos2h))
        if imgui.Button("[" .. curKeyName .. "]  Изменить##togglekey", imgui.ImVec2(-1, 24)) then
          capturingToggleKey = true
        end
        imgui.PopStyleColor(2)
      end

      imgui.Separator()

      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)
      imgui.Text(u8"Тема оформления:")
      imgui.SetCursorPosY(imgui.GetCursorPosY() - 5)
      imgui.PopStyleColor()
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabact))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
      imgui.PushStyleColor(imgui.Col.ButtonActive,  v4(T.btna))
      local themePopupW = imgui.GetWindowWidth() * 0.50 - 8
      if imgui.Button(THEMES[currentTheme].name.."  v##themepopup", imgui.ImVec2(themePopupW, 24)) then
        imgui.OpenPopup("theme_select")
      end
      local themeBtnMin = imgui.GetItemRectMin()
      local themeBtnMax = imgui.GetItemRectMax()
      imgui.PopStyleColor(3)
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.neutral, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.neutralh))
      if imgui.Button("R##reload_themes", imgui.ImVec2(26, 24)) then
        loadUserThemes()
        if not THEMES[currentTheme] then currentTheme=1 end
        T = THEMES[currentTheme]
      end
      if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8"Перечитать *.theme.json из папки скрипта")
        imgui.EndTooltip()
      end
      imgui.PopStyleColor(2)
      local themePopupActualW = themeBtnMax.x - themeBtnMin.x
      local themePopupX = themeBtnMin.x
      local themePopupY = themeBtnMax.y
      local themeItemH   = 22
      local themeVisible = math.min(#THEMES, 8)
      local themeChildH  = themeVisible * themeItemH + 4
      imgui.SetNextWindowPos(imgui.ImVec2(themePopupX, themePopupY), imgui.Cond.Appearing)
      imgui.SetNextWindowSize(imgui.ImVec2(themePopupActualW, themeChildH + 10), imgui.Cond.Appearing)
      imgui.PushStyleColor(imgui.Col.PopupBg, v4(T.winbg))
      if imgui.BeginPopup("theme_select") then
        imgui.BeginChild("##themelist", imgui.ImVec2(themePopupActualW - 12, themeChildH), false)
        for ti, th in ipairs(THEMES) do
          local isActive = currentTheme == ti
          if isActive then
            imgui.PushStyleColor(imgui.Col.Text, v4(T.btna))
          else
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.85, 0.85, 0.85, 1.0))
          end
          if imgui.Selectable(th.name.."##sel"..ti, isActive, 0, imgui.ImVec2(themePopupActualW - 28, themeItemH)) then
            applyTheme(ti)
            imgui.CloseCurrentPopup()
          end
          imgui.PopStyleColor()
        end
        imgui.EndChild()
        imgui.EndPopup()
      end
      imgui.PopStyleColor(1)

      imgui.Separator()

      -- экспорт темы
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)
      imgui.Text(u8"Экспорт темы:")
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.0))
      imgui.Text(u8"(?)")
      imgui.PopStyleColor()
      if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.85, 0.0, 1.0))
        imgui.Text(u8"Экспорт .json файла для создания собственной темы.")
        imgui.PopStyleColor()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.85, 0.85, 0.85, 1.0))
        imgui.Text(u8"После нажатия на кнопку Экспорт.json")
        imgui.Text(u8"будет создан файл с шаблонным кодом.")
        imgui.Text(u8"Файл сохраняется по пути:")
        imgui.Text(u8"\\Arizona Games Launcher\\bin\\arizona\\moonloader\\TSR-Binder\\theme_export.json")
        imgui.Text(u8"")
        imgui.Text(u8"Для удобства советую скопировать данный код и кинуть его ИИ.")
        imgui.Text(u8"Задайте подобный промт:")
        imgui.Text(u8"Сгенерируй мне тему по данному шаблону используя HEX-цвета.")
        imgui.Text(u8"")
        imgui.Text(u8"Пространство для творчества огромное,")
        imgui.Text(u8"от моно-хрома до киберпанк стиля.")
        imgui.Text(u8"По данному коду вы и сами можете")
        imgui.Text(u8"потыкать циферки и создать себе тему,")
        imgui.Text(u8"но через ИИ будет проще, и быстрее,")
        imgui.Text(u8"а так же будет легче корректировать её.")
        imgui.Text(u8"")
        imgui.Text(u8"«Предела совершенству нет.»")
        imgui.Text(u8"©Неизвестный")
        imgui.PopStyleColor()
        imgui.EndTooltip()
      end
      imgui.SetCursorPosY(imgui.GetCursorPosY() - 5)
      imgui.PopStyleColor()
      imgui.SameLine(imgui.GetWindowWidth() * 0.44)
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos2, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnpos2h))
      if imgui.Button(u8"Экспорт .json##export_theme", imgui.ImVec2(-1, 24)) then
        exportCurrentTheme()
      end
      imgui.PopStyleColor(2)

      imgui.Separator()

      -- авто отыгровка оружия
      local prevRpWeapon = rp.weapon
      local prevRpTime   = rp.time
      local prevRpMask   = rp.mask
      local prevRpArmour = rp.armour

      rp.weapon = settingRow(u8"Авто-отыгровка оружия:", rp.weapon,
        u8"[ON]  /me оружие", u8"[OFF] /me оружие")
      if not rp.weapon then prevWeapon = -1 end
      if rp.weapon and prevWeapon == -1 then
        if isLocalPlayerReady() then
          prevWeapon = getCurrentCharWeapon(PLAYER_PED)
        end
      end

      imgui.Separator()

      -- /time
      rp.time = settingRow(u8"Авто-отыгровка /time:", rp.time,
        u8"[ON]  /time", u8"[OFF] /time", true)

      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.neutral, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.neutralh))
      if imgui.Button(u8"Ред.##timeedit", imgui.ImVec2(36, 24)) then
        activeTab = 5
      end
      imgui.PopStyleColor(2)

      imgui.Separator()

      -- /mask
      rp.mask = settingRow(u8"Авто-отыгровка /mask:", rp.mask,
        u8"[ON]  /mask", u8"[OFF] /mask")

      imgui.Separator()

      -- /armour
      rp.armour = settingRow(u8"Авто-отыгровка /armour:", rp.armour,
        u8"[ON]  /armour", u8"[OFF] /armour")

      -- Сохраняем если что-то изменилось
      if rp.weapon ~= prevRpWeapon or rp.time ~= prevRpTime or
         rp.mask ~= prevRpMask or rp.armour ~= prevRpArmour then
        saveRp()
      end

      imgui.Separator()

      -- орг /d — выбор из реестра
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.Text(u8"Моя фракция (/d):")
      imgui.PopStyleColor()
      imgui.SameLine(imgui.GetWindowWidth() * 0.46)
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabact, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
      local fracBtnW = imgui.GetWindowWidth() * 0.50
      if imgui.Button((myFraction ~= "" and myFraction or u8"— выбрать —").." v##fracpopup", imgui.ImVec2(fracBtnW, 24)) then
        imgui.OpenPopup("frac_select")
      end
      imgui.PopStyleColor(2)
      -- Popup фиксируем под кнопкой
      local fracBtnMin = imgui.GetItemRectMin()
      local fracBtnMax = imgui.GetItemRectMax()
      local fracPopupW = fracBtnMax.x - fracBtnMin.x
      local fracPopupX = fracBtnMin.x
      local fracPopupY = fracBtnMax.y
      local fracItemH = 22
      local fracVisibleItems = math.min(#FRAC_REGISTRY, 8)
      local fracPopupH = fracVisibleItems * fracItemH + 10
      imgui.SetNextWindowPos(imgui.ImVec2(fracPopupX, fracPopupY), imgui.Cond.Appearing)
      imgui.SetNextWindowSize(imgui.ImVec2(fracPopupW, fracPopupH), imgui.Cond.Appearing)
      imgui.PushStyleColor(imgui.Col.PopupBg, v4(T.winbg))
      if imgui.BeginPopup("frac_select") then
        imgui.BeginChild("##frac_select_list", imgui.ImVec2(fracPopupW - 12, fracPopupH - 8), false)
        for _, fr in ipairs(FRAC_REGISTRY) do
          local isActive = myFraction == fr.id
          if isActive then
            imgui.PushStyleColor(imgui.Col.Text, v4(T.btna))
          else
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.85,0.85,0.85,1.0))
          end
          if imgui.Selectable(fr.label.."##frs"..fr.id, isActive, 0, imgui.ImVec2(fracPopupW - 28, fracItemH)) then
            myFraction = fr.id
            saveFracState()
            sampAddChatMessage(toChat("{FFD700}[TSR-Binder]{FFFFFF} Фракция: [" .. myFraction .. "] выбрана."), -1)
            imgui.CloseCurrentPopup()
          end
          imgui.PopStyleColor()
        end
        imgui.EndChild()
        imgui.EndPopup()
      end
      imgui.PopStyleColor()

      imgui.Separator()

      -- окно /d 3 режима
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.Text(u8"Авто-окно /d:")
      imgui.PopStyleColor()
      imgui.SameLine(imgui.GetWindowWidth() * 0.24)
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.0))
      imgui.Text(u8"(?)")
      imgui.PopStyleColor()
      if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.85, 0.0, 1.0))
        imgui.Text(u8"Режимы работы авто-окна /d")
        imgui.PopStyleColor()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.85, 0.85, 0.85, 1.0))
        imgui.Text(u8"Вручную: открывается только по")
        imgui.Text(u8"нажатию кнопки в main меню.")
        imgui.Text(u8"————————————————————————————————")
        imgui.Text(u8"Всегда: открывается автоматически")
        imgui.Text(u8"при каждом сообщении.")
        imgui.Text(u8"————————————————————————————————")
        imgui.Text(u8"Моя фр.: открывается только")
        imgui.Text(u8"при обращении к вашей фракции.")
        imgui.Text(u8"————————————————————————————————")
        imgui.Text(u8"Имеется реестр фракций, но возможны ошибки.")
        imgui.Text(u8"Проверено на: LSSD/lssd/ЛССД/лссд")
        imgui.PopStyleColor()
        imgui.EndTooltip()
      end
      imgui.SameLine(imgui.GetWindowWidth() * 0.46)
      local dAutoLabels = {u8"Вручную", u8"Всегда", u8"Моя фр."}
      local dAutoW = (imgui.GetWindowWidth() * 0.49) / 3 - 2
      for di = 0, 2 do
        if di > 0 then imgui.SameLine() end
        if dAutoOpen == di then
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabact, 0.95))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
        else
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabinact, 0.85))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabinh))
        end
        if imgui.Button(dAutoLabels[di+1].."##dauto"..di, imgui.ImVec2(dAutoW, 22)) then
          dAutoOpen = di
          if FRAC_FILE ~= "" then
            saveFracState()
          end
        end
        imgui.PopStyleColor(2)
      end

      imgui.Separator()

      -- подтяжка ранга
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.Text(u8"Подтянуть ранг:")
      imgui.PopStyleColor()
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.0))
        imgui.SameLine()
        imgui.Text(u8"(?)")
        imgui.PopStyleColor()
        if imgui.IsItemHovered() then
          imgui.BeginTooltip()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.85, 0.0, 1.0))
          imgui.Text(u8"Подтягивание ранга")
          imgui.PopStyleColor()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.85, 0.85, 0.85, 1.0))
          imgui.Text(u8"Нажмите на кнопку Scan, и биндер автоматически подтянет")
          imgui.Text(u8"вашу должность в организации.")
          imgui.Text(u8"Сводка функций:")
          imgui.Text(u8"1-4 ранг: Обычный режим.")
          imgui.Text(u8"5-6 ранг: Разблокировка Fast /d")
          imgui.Text(u8"7-8 ранг: Разблокировка Fast /d, и logs.")
          imgui.Text(u8"9-10 ранг: Режим Зам/Лидер, с поддержкой Smart-invite")
          imgui.Text(u8"и унаследованием пред. функций.")
          imgui.PopStyleColor()
          imgui.EndTooltip()
        end
      imgui.SameLine(imgui.GetWindowWidth() * 0.46)
      imgui.PushStyleColor(imgui.Col.Button,        rankScan.pending and v4(T.neutral, 0.90) or v4(T.btnpos, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, rankScan.pending and v4(T.neutralh) or v4(T.btnposh))
      local rankScanBtnW = imgui.GetWindowWidth() * 0.50
      if imgui.Button(rankScan.pending and u8"Scan..." or "Scan##rankscan", imgui.ImVec2(rankScanBtnW, 24)) then
        rankScan.pending = true
        rankScan.status = u8"Сканирование /stats..."
        sampSendChat("/stats")
      end
      imgui.PopStyleColor(2)
      local rankClr = imgui.ImVec4(0.75, 0.75, 0.75, 1.0)
      if canUseSmartInvite() then
        rankClr = imgui.ImVec4(0.35, 0.90, 0.45, 1.0)
      elseif canUseLogs() then
        rankClr = imgui.ImVec4(0.60, 0.80, 1.0, 1.0)
      elseif canUseDReply() then
        rankClr = imgui.ImVec4(0.90, 0.85, 0.45, 1.0)
      elseif getScannedRank() > 0 then
        rankClr = imgui.ImVec4(0.85, 0.55, 0.55, 1.0)
      end
      imgui.PushStyleColor(imgui.Col.Text, rankClr)
      imgui.TextWrapped(getRankScanText())
      imgui.PopStyleColor()

      -- Smart-invite 
      if canUseSmartInvite() then
        imgui.Separator()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
        imgui.Text(u8"Smart-invite:")
        imgui.PopStyleColor()
        imgui.SameLine()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.0))
        imgui.Text(u8"(?)")
        imgui.PopStyleColor()
        if imgui.IsItemHovered() then
          imgui.BeginTooltip()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.85, 0.0, 1.0))
          imgui.Text(u8"Smart-invite")
          imgui.PopStyleColor()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.85, 0.85, 0.85, 1.0))
          imgui.Text(u8"При /invite [ID] запускает сценарий")
          imgui.Text(u8"собеседования. Управление через")
          imgui.Text(u8"всплывающее окно: Next / Discard / Exit.")
          imgui.PopStyleColor()
          imgui.EndTooltip()
        end
        imgui.SameLine(imgui.GetWindowWidth() * 0.46)
        if smartInvite then
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos2, 0.90))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnpos2h))
          if imgui.Button(u8"[ON]  Smart##smartinvite", imgui.ImVec2(imgui.GetWindowWidth() * 0.50 - 44, 24)) then
            smartInvite = false
          end
        else
          imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg4, 0.90))
          imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnneg4h))
          if imgui.Button(u8"[OFF] Smart##smartinvite", imgui.ImVec2(imgui.GetWindowWidth() * 0.50 - 44, 24)) then
            smartInvite = true
          end
        end
        imgui.PopStyleColor(2)
        imgui.SameLine()
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.neutral, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.neutralh))
        if imgui.Button(u8"Ред.##smartinviteedit", imgui.ImVec2(36, 24)) then
          activeTab = 6
        end
        imgui.PopStyleColor(2)
      end

      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(0.50, 0.50, 0.50, 0.40))
      imgui.Separator()
      imgui.PopStyleColor()
      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.neutral, 0.85))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.neutralh))
      imgui.PushStyleColor(imgui.Col.Text,          imgui.ImVec4(0.70, 0.70, 0.70, 1.0))
      if imgui.Button(u8"Update >>>##openupdate", imgui.ImVec2(-1, 24)) then
        showUpdateWindow[0] = true
        beginUpdateCheck()
      end
      imgui.PopStyleColor(3)

      imgui.PopStyleColor() 
    end

    -- вкладка №6 Smart-invite
    if activeTab == 6 then drawSinviteTab() end

    -- вкладка №5 /time
    if activeTab == 5 then
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.tabinact, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.tabacth))
      imgui.PushStyleColor(imgui.Col.ButtonActive,  v4(T.tabact))
      imgui.PushStyleColor(imgui.Col.Text,          imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
      if imgui.Button("< ##timeback", imgui.ImVec2(22, 20)) then
        activeTab = 3
      end
      imgui.PopStyleColor(4)
      imgui.SameLine()
      local timeTitleW = imgui.CalcTextSize(u8"/time Settings").x
      imgui.SetCursorPosX((imgui.GetWindowWidth() - timeTitleW) * 0.5)
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.75, 0.75, 0.75, 1.0))
      imgui.Text(u8"/time Settings")
      imgui.PopStyleColor()
      imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(0.50, 0.50, 0.50, 0.80))
      imgui.Separator()
      imgui.PopStyleColor()
      imgui.Spacing()

      local winW = imgui.GetWindowWidth()
      local lblW = winW * 0.46

      local function timeLabel(txt)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
        imgui.Text(txt)
        imgui.PopStyleColor()
      end

      timeLabel(u8"/me текст:")
      imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.frame))
      imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.frameh))
      imgui.PushItemWidth(-1)
      if imgui.InputText("##timeme", timeRp.inMe, 256) then
        timeRp.meText = ffi.string(timeRp.inMe)
      end
      imgui.PopItemWidth()
      imgui.PopStyleColor(2)

      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(0.50, 0.50, 0.50, 0.40))
      imgui.Separator()
      imgui.PopStyleColor()
      imgui.Spacing()

      timeLabel(u8"/do текст:")
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.0))
      imgui.Text(u8"(?)")
      imgui.PopStyleColor()
      if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.85, 0.0, 1.0))
        imgui.Text(u8"Подстановка времени:")
        imgui.PopStyleColor()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.85, 0.85, 0.85, 1.0))
        imgui.Text(u8"Напишите {time} в тексте и оно")
        imgui.Text(u8"автоматически заменится на")
        imgui.Text(u8"текущее время в формате ЧЧ:ММ:СС")
        imgui.Text(u8"")
        imgui.Text(u8"Пример:")
        imgui.Text(u8"Часы на левой руке {time}.")
        imgui.Text(u8"-> Часы на левой руке 14:32:10.")
        imgui.PopStyleColor()
        imgui.EndTooltip()
      end
      imgui.SameLine(lblW)
      if timeRp.useDo then
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos2, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnpos2h))
        if imgui.Button(u8"[ON]##usedo", imgui.ImVec2(50, 22)) then
          timeRp.useDo = false
        end
      else
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg4, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnneg4h))
        if imgui.Button(u8"[OFF]##usedo", imgui.ImVec2(50, 22)) then
          timeRp.useDo = true
        end
      end
      imgui.PopStyleColor(2)
      if timeRp.useDo then
        imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.frame))
        imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.frameh))
        imgui.PushItemWidth(-1)
        if imgui.InputText("##timedo", timeRp.inDo, 256) then
          timeRp.doText = ffi.string(timeRp.inDo)
        end
        imgui.PopItemWidth()
        imgui.PopStyleColor(2)
      end

      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
      if imgui.Button(u8"СОХРАНИТЬ##timesave", imgui.ImVec2(-1, 26)) then
        timeRp.meText   = ffi.string(timeRp.inMe)
        timeRp.doText   = ffi.string(timeRp.inDo)
        if TIME_RP_FILE ~= "" then
          local tf = io.open(TIME_RP_FILE, "wb")
          if tf then
            tf:write(json.encode({
              meText   = timeRp.meText,
              doText   = timeRp.doText,
              useDo    = timeRp.useDo,
            }, {indent=true}))
            tf:close()
          end
        end
        sampAddChatMessage(toChat("{FFD700}[TSR-Binder]{FFFFFF} Настройки /time сохранены."), -1)
      end
      imgui.PopStyleColor(2)
    end

    imgui.End()
    imgui.PopStyleColor(7)
end

function onScriptTerminate(s, q)
  if s == script.this then
    if deliveryLogDirty then
      saveDeliveryLogNow()
      deliveryLogDirty = false
    end
    if radioLogDirty then
      saveRadioLogNow()
      radioLogDirty = false
    end
    exportReadableLogs()
    SCRIPT_ACTIVE = false
  end
end

imgui.OnFrame(
  function() return SCRIPT_ACTIVE and showMain[0] end,
  function(self) drawMainWindow(self) end
)

--  быстрый ответа /d
imgui.OnFrame(
  function() return showDWindow[0] and canUseDReply() end,
  function(self)
    self.HideCursor = not showMain[0] or isKeyDown(2)
    imgui.PushStyleColor(imgui.Col.WindowBg,      v4(T.winbg, 0.97))
    imgui.PushStyleColor(imgui.Col.TitleBgActive, v4(T.cneutral))
    imgui.PushStyleColor(imgui.Col.TitleBg,       v4(T.cneutral, 0.80))
    imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.frame))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.frameh))

    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(10, 500), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(480, 0), imgui.Cond.Always)
    imgui.Begin(u8"/d — Быстрый ответ", showDWindow,
      imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove)

    if #dHistory == 0 then
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.5,0.5,0.5,1.0))
      imgui.Text(u8"Нет входящих /d")
      imgui.PopStyleColor()
    else
      local histH = math.min(#dHistory * 22, 110)
      imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0,0,0,0.25))
      imgui.BeginChild("##dhistory", imgui.ImVec2(-1, histH), false)
      for i, msg in ipairs(dHistory) do
        local isSel = (i == dSelected)
        if isSel then
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.20, 1.0))
        else
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.65, 0.65, 0.65, 1.0))
        end
        local preview = msg.text:sub(1,32) .. (msg.text:len() > 32 and "..." or "")
        local line = (isSel and "> " or "  ") .. msg.sender .. " [" .. msg.from .. "]: " .. preview
        if imgui.Selectable(u8(line) .. "##dmsg"..i, isSel) then
          dSelected = i
          if inDReplyText then ffi.fill(inDReplyText, 256, 0) end
        end
        imgui.PopStyleColor()
      end
      imgui.EndChild()
      imgui.PopStyleColor()
    end

    imgui.Separator()

    if dSelected > 0 and dHistory[dSelected] then
      local msg = dHistory[dSelected]
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.80, 1.0, 1.0))
      imgui.Text(u8"От: " .. msg.sender .. "  [" .. msg.from .. "] → [" .. msg.to .. "]")
      imgui.PopStyleColor()
      if msg.text ~= "" then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.60, 0.60, 0.60, 1.0))
        imgui.TextWrapped(u8(msg.text))
        imgui.PopStyleColor()
      end
      imgui.Separator()
      local replyPrefix = "[" .. myFraction .. "] to [" .. msg.from .. "]: "
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.65, 0.0, 1.0))
      imgui.Text(replyPrefix)
      imgui.PopStyleColor()
      imgui.PushItemWidth(-1)
      if inDReplyText then
        imgui.InputText("##dreplywin", inDReplyText, 256)
      end
      imgui.PopItemWidth()
      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
      if imgui.Button(u8"Отправить##dsend", imgui.ImVec2(-1, 32)) then
        if inDReplyText then
          local txt = ffi.string(inDReplyText)
          if txt ~= "" then
            sampSendChat(toChat("/d " .. replyPrefix .. txt))
            ffi.fill(inDReplyText, 256, 0)
            showDWindow[0] = false
          end
        end
      end
      imgui.PopStyleColor(2)
    end

    imgui.End()
    imgui.PopStyleColor(5)
  end
)

--  редактор биндов
imgui.OnFrame(
  function() return showEditor[0] end,
  function(self)
    self.HideCursor = isKeyDown(2)
    imgui.PushStyleColor(imgui.Col.WindowBg,       v4(T.ed_winbg, 0.97))
    imgui.PushStyleColor(imgui.Col.TitleBgActive,  v4(T.ed_titlehi))
    imgui.PushStyleColor(imgui.Col.TitleBg,        v4(T.ed_titlebg))
    imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.frame))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.frameh))
    imgui.PushStyleColor(imgui.Col.Button,         v4(T.btnpos, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered,  v4(T.btnposh))
    imgui.PushStyleColor(imgui.Col.Separator,      v4(T.ed_sep, 0.40))

    local title = (ed.mode=="new") and u8"НОВЫЙ БИНД" or u8"РЕДАКТИРОТЬ БИНД"
    imgui.SetNextWindowPos(imgui.ImVec2(310, 100), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(480, 0), imgui.Cond.Always)
    imgui.Begin(title, showEditor, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Название кнопки:")
    imgui.PopStyleColor()
    imgui.PushItemWidth(-1)
    imgui.InputText("##lbl", ed.inLabel, BUF)
    imgui.PopItemWidth()
    imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Горячая клавиша (F1-F12, NUMPAD0-9, A-Z, или оставить пустой):")
    imgui.PopStyleColor()
    imgui.PushItemWidth(150)
    imgui.InputText("##key", ed.inKey, 32)
    imgui.PopItemWidth()
    imgui.SameLine()

    if ed.capturingKey then
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.au_stop))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.au_stoph))
      if imgui.Button(u8">> НАЖМИТЕ КЛАВИШУ <<", imgui.ImVec2(-1, 22)) then ed.capturingKey=false end
      imgui.PopStyleColor(2)
    else
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.au_edit, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.au_edith))
      if imgui.Button(u8"Перехватить клавишу", imgui.ImVec2(-1, 22)) then ed.capturingKey=true end
      imgui.PopStyleColor(2)
    end

    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.65, 0.90, 0.65, 1.0))
    imgui.Text(u8"Строки отыгровок:")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 1.0))
    imgui.Text(u8"  задержка — пауза ПОСЛЕ отправки (мс)")
    imgui.PopStyleColor()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.45, 0.45, 0.45, 1.0))
    imgui.Text(u8"  #    Текст строки (/me, /do, /b ...)                         задержка     del")
    imgui.PopStyleColor()
    imgui.Separator()

    local toDelete = nil
    local toSwapIdx = nil
    local toSwapDir = 0
    for i, row in ipairs(ed.rows) do
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
      imgui.Text(string.format("%2d", i))
      imgui.PopStyleColor()
      imgui.SameLine()
      imgui.PushItemWidth(230)
      imgui.InputText("##t"..i, row.textBuf, BUF)
      imgui.PopItemWidth()
      imgui.SameLine()
      imgui.PushItemWidth(60)
      imgui.InputText("##d"..i, row.delayBuf, 16)
      imgui.PopItemWidth()
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.aneutral, 0.85))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.aneutralh))
      if imgui.Button("^##ru"..i, imgui.ImVec2(18, 20)) and i > 1 then
        toSwapIdx = i; toSwapDir = -1
      end
      imgui.SameLine()
      if imgui.Button("v##rd"..i, imgui.ImVec2(18, 20)) and i < #ed.rows then
        toSwapIdx = i; toSwapDir = 1
      end
      imgui.PopStyleColor(2)
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.85))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
      if imgui.Button("X##r"..i, imgui.ImVec2(22, 20)) then toDelete=i end
      imgui.PopStyleColor(2)
    end

    if toDelete and #ed.rows > 1 then table.remove(ed.rows, toDelete) end
    if toSwapIdx then
      local j = toSwapIdx + toSwapDir
      if j >= 1 and j <= #ed.rows then
        ed.rows[toSwapIdx], ed.rows[j] = ed.rows[j], ed.rows[toSwapIdx]
      end
    end

    imgui.Spacing()
    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnlink, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnlinkh))
    if imgui.Button(u8"+ добавить строку", imgui.ImVec2(180, 22)) then
      table.insert(ed.rows, newRow("", DEFAULT_DELAY))
    end
    imgui.PopStyleColor(2)

    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    if ed.msg ~= "" and ed.msgTimer > 0 then
      imgui.PushStyleColor(imgui.Col.Text,
        ed.msg_ok and imgui.ImVec4(0.2,0.9,0.3,1.0) or imgui.ImVec4(0.9,0.3,0.2,1.0))
      imgui.TextWrapped(ed.msg)
      imgui.PopStyleColor(); imgui.Spacing()
    end

    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos3, 0.92))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnpos3h))
    if imgui.Button(u8"СОХРАНИТЬ'", imgui.ImVec2(190, 27)) then
      local lbl = ffi.string(ed.inLabel)
      local ks  = ffi.string(ed.inKey):upper()
      if lbl == "" then
        setMsg("Введи название кнопки!", false)
      else
        local kcode=nil; local keyInvalid=false
        if ks ~= "" then
          kcode = keyStrToCode(ks)
          if not kcode then setMsg("Клавиша '"..ks.."' не распознано!", false); keyInvalid=true end
        end
        if not keyInvalid then
          local entries = {}
          for _, row in ipairs(ed.rows) do
            local txt = ffi.string(row.textBuf)
            local d   = tonumber(ffi.string(row.delayBuf))
            if txt ~= "" then
              table.insert(entries, {text=txt, delay=(d and d>=0) and d or DEFAULT_DELAY})
            end
          end
          if #entries == 0 then
            setMsg("Доабвь хотя бы одну строку!", false)
          else
            local entry = {label=lbl, keyStr=ks, keyCode=kcode, entries=entries}
            if ed.mode=="new" then table.insert(binds, entry)
            else binds[ed.idx]=entry end
            saveBinds()
            setMsg("Сохранено!", true)
            showEditor[0]=false; ed.capturingKey=false
          end
        end
      end
    end
    imgui.PopStyleColor(2)
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg3, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnneg3h))
    if imgui.Button(u8"ОТМЕНА", imgui.ImVec2(-1, 27)) then showEditor[0]=false; ed.capturingKey=false end
    imgui.PopStyleColor(2)

    imgui.End()
    imgui.PopStyleColor(8)
  end
)

--  авто-msg и UI редактор
function drawAutoEditor(self)
    self.HideCursor = isKeyDown(2)
    imgui.PushStyleColor(imgui.Col.WindowBg,       v4(T.au_winbg, 0.97))
    imgui.PushStyleColor(imgui.Col.TitleBgActive,  v4(T.au_titlehi))
    imgui.PushStyleColor(imgui.Col.TitleBg,        v4(T.au_titlebg))
    imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.au_frame))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.au_frameh))
    imgui.PushStyleColor(imgui.Col.Button,         v4(T.au_btn, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered,  v4(T.au_btnh))
    imgui.PushStyleColor(imgui.Col.Separator,      v4(T.au_sep, 0.40))

    local title = (aed.mode=="new") and u8"НОВОЕ АВТО-MSG" or u8"РЕДАКТИРОВАТЬ АВТО-MSG"
    imgui.SetNextWindowPos(imgui.ImVec2(310, 100), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(480, 0), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(420, 100), imgui.ImVec2(600, 800))
    imgui.Begin(title, showAutoEditor, imgui.WindowFlags.NoScrollbar)

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Название таймера:")
    imgui.PopStyleColor()
    imgui.PushItemWidth(-1)
    imgui.InputText("##albl", aed.inLabel, BUF)
    imgui.PopItemWidth()

    imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Строки сообщений:")
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.0))
    imgui.Text(u8"текст")
    imgui.SameLine(imgui.GetWindowWidth() - 62)
    imgui.Text(u8"задержка")
    imgui.PopStyleColor(2)

    local aedToDelete = nil
    local aedSwapIdx, aedSwapDir = nil, 0
    for i, row in ipairs(aed.rows) do
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55,0.55,0.55,1.0))
      imgui.Text(string.format("%2d", i))
      imgui.PopStyleColor()
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.au_frame))
      imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.au_frameh))
      imgui.PushItemWidth(imgui.GetWindowWidth() - 140)
      imgui.InputText("##at"..i, row.textBuf, BUF)
      imgui.PopItemWidth()
      imgui.SameLine()
      imgui.PushItemWidth(46)
      imgui.InputText("##ad"..i, row.delayBuf, 16)
      imgui.PopItemWidth()
      imgui.PopStyleColor(2)
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.aneutral, 0.85))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.aneutralh))
      if imgui.Button("^##au"..i, imgui.ImVec2(18, 20)) and i > 1 then
        aedSwapIdx = i; aedSwapDir = -1
      end
      imgui.SameLine()
      if imgui.Button("v##ad2"..i, imgui.ImVec2(18, 20)) and i < #aed.rows then
        aedSwapIdx = i; aedSwapDir = 1
      end
      imgui.PopStyleColor(2)
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.85))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
      if imgui.Button("X##ax"..i, imgui.ImVec2(18, 20)) and #aed.rows > 1 then aedToDelete=i end
      imgui.PopStyleColor(2)
    end
    if aedToDelete then table.remove(aed.rows, aedToDelete) end
    if aedSwapIdx then
      local j = aedSwapIdx + aedSwapDir
      if j >= 1 and j <= #aed.rows then
        aed.rows[aedSwapIdx], aed.rows[j] = aed.rows[j], aed.rows[aedSwapIdx]
      end
    end

    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnlink, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnlinkh))
    if imgui.Button(u8"+ добавить строку##aadd", imgui.ImVec2(160, 20)) then
      table.insert(aed.rows, newAutoRow("", 800))
    end
    imgui.PopStyleColor(2)

    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Интервал (секунд):")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushItemWidth(80)
    imgui.InputText("##asec", aed.inSec, 16)
    imgui.PopItemWidth()

    imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Лимит повт. (0=бесконечно):")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushItemWidth(80)
    imgui.InputText("##alim", aed.inLimit, 16)
    imgui.PopItemWidth()

    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    if aed.msg ~= "" and aed.msgTimer > 0 then
      imgui.PushStyleColor(imgui.Col.Text,
        aed.msg_ok and imgui.ImVec4(0.2,0.9,0.3,1.0) or imgui.ImVec4(0.9,0.3,0.2,1.0))
      imgui.TextWrapped(aed.msg)
      imgui.PopStyleColor(); imgui.Spacing()
    end

    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos3, 0.92))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnpos3h))
    if imgui.Button(u8"СОХРАНИТЬ", imgui.ImVec2(190, 27)) then
      local lbl  = ffi.string(aed.inLabel)
      local secs = tonumber(ffi.string(aed.inSec))
      local lim  = tonumber(ffi.string(aed.inLimit)) or 0
      -- сбор строк
      local lines = {}
      for _, row in ipairs(aed.rows) do
        local txt = ffi.string(row.textBuf)
        local dly = tonumber(ffi.string(row.delayBuf)) or 800
        if txt ~= "" then table.insert(lines, {text=txt, delay=dly}) end
      end
      if #lines == 0 then
        setAutoMsg(u8"Добавь хотя бы одну строку!", false)
      elseif not secs or secs <= 0 then
        setAutoMsg(u8"Интервал должен быть > 0 секунд!", false)
      else
        if lbl == "" then lbl = lines[1].text:sub(1,24) end
        if lim < 0 then lim = 0 end
        local entry = {label=lbl, lines=lines, interval=secs, limit=lim,
                       active=false, lastSentAt=0, count=0}
        if aed.mode == "new" then
          table.insert(autoMsgs, entry)
        else
          entry.active     = autoMsgs[aed.idx].active
          entry.lastSentAt = autoMsgs[aed.idx].lastSentAt or 0
          entry.count      = autoMsgs[aed.idx].count
          autoMsgs[aed.idx] = entry
        end
        saveAuto()
        setAutoMsg(u8"Сохранено!", true)
        showAutoEditor[0] = false
      end
    end
    imgui.PopStyleColor(2)
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg3, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnneg3h))
    if imgui.Button(u8"ОТМЕНА", imgui.ImVec2(-1, 27)) then showAutoEditor[0]=false end
    imgui.PopStyleColor(2)

    imgui.End()
    imgui.PopStyleColor(8)
end

imgui.OnFrame(
  function() return showAutoEditor[0] end,
  function(self) drawAutoEditor(self) end
)

-- UI — шпаргалка и заметки                         
local function drawFormatTooltip()
  if imgui.IsItemHovered() then
    imgui.BeginTooltip()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.85, 0.20, 1.0))
    imgui.Text(u8"ФОРМАТИРОВАНИЕ ТЕКСТА:")
    imgui.PopStyleColor()
    imgui.Separator(); imgui.Spacing()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.75, 0.10, 1.0))
    imgui.Text(u8"# Заголовок")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
    imgui.Text(u8"  →  золотой заголовок + линия")
    imgui.PopStyleColor()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70, 0.90, 0.70, 1.0))
    imgui.Text(u8"- Пункт")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
    imgui.Text(u8"       →  зелёный пункт со значком •")
    imgui.PopStyleColor()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.35, 0.35, 1.0))
    imgui.Text(u8"! Важно")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
    imgui.Text(u8"       →  красное предупреждение ⚠")
    imgui.PopStyleColor()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.82, 0.82, 0.82, 1.0))
    imgui.Text(u8"Обычный текст")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
    imgui.Text(u8"  →  серый текст")
    imgui.PopStyleColor()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
    imgui.Text(u8"(пустая строка)")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
    imgui.Text(u8"  →  отступ между блоками")
    imgui.PopStyleColor()
    imgui.EndTooltip()
  end
end

imgui.OnFrame(
  function() return showCheatsheet[0] end,
  function(self)
    self.HideCursor = not showMain[0] or isKeyDown(2)
    imgui.PushStyleColor(imgui.Col.WindowBg,       v4(T.ch_winbg, 0.97))
    imgui.PushStyleColor(imgui.Col.TitleBgActive,  v4(T.ch_titlehi))
    imgui.PushStyleColor(imgui.Col.TitleBg,        v4(T.ch_titlebg))
    imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.ch_frame))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.ch_frameh))
    imgui.PushStyleColor(imgui.Col.Button,         v4(T.ch_btn, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered,  v4(T.ch_btnh))
    imgui.PushStyleColor(imgui.Col.ScrollbarBg,    v4(T.ch_scroll))
    imgui.PushStyleColor(imgui.Col.ScrollbarGrab,  v4(T.ch_grab))

    imgui.SetNextWindowPos(imgui.ImVec2(430, 100), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(420, 500), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(280, 200), imgui.ImVec2(700, 900))
    local cheatFlags = 0
    if cs.onlyMode then
      cheatFlags = imgui.WindowFlags.NoInputs + imgui.WindowFlags.NoMove
    end
    imgui.Begin(u8"ШПАРГАЛКА | TSR-Binder", showCheatsheet, cheatFlags)

    local function innerTab(label, idx)
      if cheatTab == idx then
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.ch_tabact))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.ch_tabacth))
      else
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.ch_tabinact, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.ch_tabhh))
      end
      local clicked = imgui.Button(label, imgui.ImVec2(140, 22))
      imgui.PopStyleColor(2)
      return clicked
    end

    if innerTab(u8"ШПАРГАЛКА", 1) then cheatTab = 1 end
    imgui.SameLine()
    if innerTab(u8"ЗАМЕТКИ", 2) then cheatTab = 2 end
    imgui.Separator()

    -- шпаргалка
    if cheatTab == 1 then

    if cs.editMode then
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.ch_sav, 0.92))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.ch_savh))
      if imgui.Button(u8"СОХРАНИТЬ", imgui.ImVec2(130, 24)) then
        saveCheatsheet()
        cs.editMode = false
      end
      imgui.PopStyleColor(2)
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.ch_cancel, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.ch_cancelh))
      if imgui.Button(u8"ОТМЕНА", imgui.ImVec2(100, 24)) then
        loadCheatsheet()
        cs.editMode = false
      end
      imgui.PopStyleColor(2)
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.ch_hint, 0.85))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.ch_hinth))
      imgui.Button(u8"?", imgui.ImVec2(24, 24))
      drawFormatTooltip()
      imgui.PopStyleColor(2)
    else
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.ch_edit, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.ch_edith))
      if imgui.Button(u8"РЕДАКТИРОВАТЬ", imgui.ImVec2(150, 24)) then
        cs.editMode = true
      end
      imgui.PopStyleColor(2)
      imgui.SameLine()
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.ch_hint, 0.85))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.ch_hinth))
      imgui.Button(u8"?", imgui.ImVec2(24, 24))
      drawFormatTooltip()
      imgui.PopStyleColor(2)
    end

    imgui.Separator()

    if cs.editMode then
      imgui.PushStyleColor(imgui.Col.FrameBg, v4(T.ch_framebg))
      imgui.InputTextMultiline("##cheat", cs.buf, CHEAT_BUF, imgui.ImVec2(-1, -1))
      imgui.PopStyleColor()
    else
      if #cs.lines == 0 or (cs.lines[1] == "" and #cs.lines == 1) then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.35, 0.30, 0.50, 1.0))
        imgui.TextWrapped(u8"Шпаргалка пуста. Нажмите РЕДАКТИРОВАТЬ чтобы добавить текст.")
        imgui.PopStyleColor()
      else
        for _, line in ipairs(cs.lines) do
          if line == "" then
            imgui.Spacing()
          elseif line:sub(1,2) == "# " then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.75, 0.10, 1.0))
            imgui.Text(line:sub(3))
            imgui.PopStyleColor()
            imgui.Separator()
          elseif line:sub(1,2) == "- " then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70, 0.90, 0.70, 1.0))
            imgui.Text(u8"  •  "..line:sub(3))
            imgui.PopStyleColor()
          elseif line:sub(1,2) == "! " then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.35, 0.35, 1.0))
            imgui.Text(u8"  ⚠  "..line:sub(3))
            imgui.PopStyleColor()
          else
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.82, 0.82, 0.82, 1.0))
            imgui.TextWrapped(line)
            imgui.PopStyleColor()
          end
        end
      end
    end

    end 

    -- заметки
    if cheatTab == 2 then
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.45, 0.40, 0.60, 1.0))
      imgui.Text(u8"Кликни в поле чтобы редактировать. Ctrl+S — сохранить.")
      imgui.PopStyleColor()
      imgui.Spacing()

      local prevDirty = nt.dirty
      imgui.PushStyleColor(imgui.Col.FrameBg,        v4(T.ch_framebg2))
      imgui.PushStyleColor(imgui.Col.FrameBgHovered, v4(T.ch_framebgh))
      imgui.PushStyleColor(imgui.Col.FrameBgActive,  v4(T.ch_framebga))
      if imgui.InputTextMultiline("##notes", nt.buf, NOTE_BUF, imgui.ImVec2(-1, -36)) then
        nt.dirty = true
      end
      imgui.PopStyleColor(3)

      imgui.PushStyleColor(imgui.Col.Button,        v4(T.ch_sav, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.ch_savh))
      if imgui.Button(u8"СОХРАНИТЬ##notes", imgui.ImVec2(-1, 26)) then
        saveNotes()
      end
      imgui.PopStyleColor(2)

      if nt.dirty and imgui.IsWindowFocused() and isKeyDown(vkeys.VK_CONTROL) and isKeyDown(vkeys.VK_S) then
        saveNotes()
      end
    end

    imgui.End()
    imgui.PopStyleColor(9)
  end
)

-- окно логов
imgui.OnFrame(
  function() return showLogs[0] and canUseLogs() end,
  function(self)
    self.HideCursor = isKeyDown(2)
    imgui.PushStyleColor(imgui.Col.WindowBg,      imgui.ImVec4(0.04, 0.04, 0.04, 0.97))
    imgui.PushStyleColor(imgui.Col.TitleBgActive, v4(T.titlehi))
    imgui.PushStyleColor(imgui.Col.TitleBg,       v4(T.titlebg))
    imgui.PushStyleColor(imgui.Col.Border,        v4(T.btn, 0.60))
    imgui.PushStyleColor(imgui.Col.ScrollbarBg,   imgui.ImVec4(0,0,0,0.30))
    imgui.PushStyleColor(imgui.Col.ScrollbarGrab, v4(T.btn, 0.50))
    imgui.PushStyleColor(imgui.Col.ScrollbarGrabHovered, v4(T.btnh, 0.70))
    imgui.PushStyleColor(imgui.Col.Separator,     imgui.ImVec4(1,1,1,0.08))

    imgui.SetNextWindowSize(imgui.ImVec2(560, 550), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(100, 100), imgui.Cond.FirstUseEver)
    imgui.Begin(u8"Логи", showLogs, imgui.WindowFlags.NoScrollbar)

    local winH = imgui.GetContentRegionAvail().y
    local topH = radio.visible and (math.floor(winH * 0.50) - 6) or (winH - 42)
    local botH = winH - topH - 22

    -- действия орг
    local totalAll = deliveries.TSR.count + deliveries.LS.count + deliveries.SF.count
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Действия — поставки: " .. totalAll)
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.45, 0.45, 0.45, 1.0))
    imgui.Text(u8"  ТСР: " .. deliveries.TSR.count ..
               u8"  |  ЛС: " .. deliveries.LS.count ..
               u8"  |  СФ: " .. deliveries.SF.count)
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.85, 0.0, 1.0))
    imgui.Text(u8"  Актив. (р/п): " .. wantedCount)
    imgui.PopStyleColor()

    imgui.PushStyleColor(imgui.Col.ChildBg,   imgui.ImVec4(0,0,0,0.15))
    imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1,1,1,0.05))
    imgui.BeginChild("##delivscroll", imgui.ImVec2(-1, topH), false)
    if #deliveryLog == 0 then
      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.35,0.35,0.35,1.0))
      imgui.Text(u8"  Поставок ещё не было.")
      imgui.PopStyleColor()
    else
      local deliveryRenderCount = math.min(#deliveryLog, LOG_RENDER_LIMIT)
      for i = 1, deliveryRenderCount do
        local entry = deliveryLog[i]
        -- дата и время
        if entry.date then
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.30, 0.80, 0.40, 1.0))
          imgui.Text("[" .. entry.date .. "]")
          imgui.PopStyleColor()
          imgui.SameLine()
        end
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40,0.40,0.40,1.0))
        imgui.Text("[" .. entry.time .. "]")
        imgui.PopStyleColor()
        imgui.SameLine()

        if entry.type == "wanted" then
          -- розыск
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.30, 0.30, 1.0))
          imgui.Text(u8"[Розыск]")
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0,1.0,1.0,1.0))
          imgui.Text(entry.player)
          imgui.PopStyleColor()
          imgui.SameLine()
          if entry.reason and entry.reason ~= "" then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.75,0.55,0.85,1.0))
            imgui.Text(u8"(" .. entry.reason .. ")")
            imgui.PopStyleColor()
          else
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.45,0.45,0.45,1.0))
            imgui.Text(u8"(причина не получена)")
            imgui.PopStyleColor()
          end
          if entry.accuser and entry.accuser ~= "" then
            imgui.SameLine()
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.60,0.60,0.60,1.0))
            imgui.Text(u8"| " .. entry.accuser)
            imgui.PopStyleColor()
          end
        elseif entry.type == "theft" then
          -- угон
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.70, 0.10, 1.0))
          imgui.Text(u8"[Угон]")
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70, 0.70, 0.70, 1.0))
          imgui.Text(u8"Новый угон транспортного средства")
          imgui.PopStyleColor()
        elseif entry.type == "clearwanted" then
          -- очист.Розыск
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.30, 0.85, 0.50, 1.0))
          imgui.Text(u8"[Снят розыск]")
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70, 0.70, 0.70, 1.0))
          imgui.Text(entry.rank .. " " .. entry.cop)
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.45, 0.45, 0.45, 1.0))
          imgui.Text(u8"→")
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
          imgui.Text(entry.target)
          imgui.PopStyleColor()
        elseif entry.type == "police" then
          -- вызовы пд
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.30, 0.60, 1.0, 1.0))
          imgui.Text(u8"[Полиция]")
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0,1.0,1.0,1.0))
          imgui.Text(entry.player)
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.60,0.60,0.60,1.0))
          imgui.Text(u8"| " .. (entry.city or "") .. u8" | " .. (entry.location or ""))
          imgui.PopStyleColor()
          if entry.reason and entry.reason ~= "" then
            imgui.SameLine()
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.75,0.55,0.85,1.0))
            imgui.Text(u8"(" .. entry.reason .. ")")
            imgui.PopStyleColor()
          end
        else
          -- поставки
          local factLow = (entry.factory or ""):lower()
          local clr
          if factLow:find("тср") or factLow:find("tsr") then
            clr = imgui.ImVec4(0.55, 0.85, 0.55, 1.0)
          elseif factLow:find("лс") or factLow:find("армии л") then
            clr = imgui.ImVec4(0.55, 0.75, 1.00, 1.0)
          else
            clr = imgui.ImVec4(1.00, 0.75, 0.35, 1.0)
          end
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50,0.80,0.50,1.0))
          imgui.Text(u8"[Поставка]")
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0,1.0,1.0,1.0))
          imgui.Text(entry.player)
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70,0.70,0.70,1.0))
          imgui.Text(u8"→ " .. (entry.amount or "") .. " " .. (entry.goods or ""))
          imgui.PopStyleColor()
          imgui.SameLine()
          imgui.PushStyleColor(imgui.Col.Text, clr)
          imgui.Text(u8"[" .. (entry.factory or "") .. "]")
          imgui.PopStyleColor()
        end

        if i < deliveryRenderCount then imgui.Separator() end
      end
    end
    imgui.EndChild()
    imgui.PopStyleColor(2)

    imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1,1,1,0.25))
    imgui.Separator()
    imgui.PopStyleColor()

    imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(0,0,0,0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0.10))
    imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(1,1,1,0.18))
    if imgui.Button(radio.visible and "v##rtoggle" or "^##rtoggle", imgui.ImVec2(18, 18)) then
      radio.visible = not radio.visible
    end
    imgui.PopStyleColor(3)
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Рация /r  —  " .. #radio.log .. u8" сообщений")
    imgui.PopStyleColor()

    if radio.visible then
    imgui.PushStyleColor(imgui.Col.ChildBg,   imgui.ImVec4(0,0,0,0.15))
    imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(1,1,1,0.05))
    imgui.BeginChild("##radioscroll", imgui.ImVec2(-1, -1), false)
    if #radio.log == 0 then
      imgui.Spacing()
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.35,0.35,0.35,1.0))
      imgui.Text(u8"  Сообщений в рации ещё не было.")
      imgui.PopStyleColor()
    else
      local radioRenderCount = math.min(#radio.log, RADIO_RENDER_LIMIT)
      for i = 1, radioRenderCount do
        local entry = radio.log[i]
        if entry.date then
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.30, 0.80, 0.40, 1.0))
          imgui.Text("[" .. entry.date .. "]")
          imgui.PopStyleColor()
          imgui.SameLine()
        end
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40,0.40,0.40,1.0))
        imgui.Text("[" .. entry.time .. "]")
        imgui.PopStyleColor()
        imgui.SameLine()
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.75,0.85,1.0,1.0))
        imgui.Text(entry.player .. ":")
        imgui.PopStyleColor()
        imgui.SameLine()
        if entry.isNrp then
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0,0.85,0.0,1.0))
        else
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.90,0.90,0.90,1.0))
        end
        imgui.TextWrapped(u8(entry.text))
        imgui.PopStyleColor()
        if i < radioRenderCount then imgui.Separator() end
      end
    end
    imgui.EndChild()
    imgui.PopStyleColor(2)
    end 

    imgui.End()
    imgui.PopStyleColor(8)
  end
)

-- окно SMART-INVITE
imgui.OnFrame(
  function() return showSinvWindow[0] end,
  function(self)
    self.HideCursor = false
    imgui.PushStyleColor(imgui.Col.WindowBg,      imgui.ImVec4(0.05, 0.05, 0.07, 0.97))
    imgui.PushStyleColor(imgui.Col.TitleBgActive, v4(T.titlehi))
    imgui.PushStyleColor(imgui.Col.TitleBg,       v4(T.titlebg))
    imgui.PushStyleColor(imgui.Col.Border,        v4(T.btn, 0.60))
    imgui.PushStyleColor(imgui.Col.Separator,     v4(T.sep, 0.35))

    imgui.SetNextWindowSize(imgui.ImVec2(340, 160), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver)
    imgui.Begin(u8"Smart-invite", showSinvWindow, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize)

    if not sinvSession.active then
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.5,0.5,0.5,1.0))
      imgui.Text(u8"Нет активного собеседования.")
      imgui.PopStyleColor()
    else
      local totalStages = #sinviteStages

      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
      imgui.Text(u8"Кандидат: " .. sinvSession.targetName .. " [" .. sinvSession.targetId .. "]")
      imgui.PopStyleColor()

      imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.55, 0.55, 0.55, 1.0))
      imgui.Text(u8"Этап: " .. sinvSession.stage .. " / " .. totalStages)
      imgui.PopStyleColor()

      -- предпросмотр следуюшего этапа
      if sinvSession.stage < totalStages then
        local nst = sinviteStages[sinvSession.stage + 1]
        if nst and nst.lines and nst.lines[1] then
          local previewText = sinvGetText(nst.lines[1])
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.38, 0.38, 0.38, 1.0))
          imgui.TextWrapped(u8"Далее: " .. previewText:sub(1, 45))
          imgui.PopStyleColor()
        end
      end

      imgui.Separator()
      imgui.Spacing()

      local btnW = (imgui.GetWindowWidth() - 24) / 3

      -- next/accept
      if sinvSession.stage < totalStages then
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
        if imgui.Button(u8"Next >>>##sinvnext", imgui.ImVec2(btnW, 28)) then
          sinvSession.stage = sinvSession.stage + 1
          local st = sinviteStages[sinvSession.stage]
          local isLast = sinvSession.stage >= totalStages
          local id = sinvSession.targetId
          if st then
            lua_thread.create(function()
              for _, ln in ipairs(st.lines) do
                local txt = sinvGetText(ln)
                if txt ~= "" then sampSendChat(toChat(txt)) end
                wait(sinvGetDelay(ln))
              end

              if isLast then
                wait(800)
                sinvitePendingCmd = "/invite " .. id
                sinvSession.active = false
                showSinvWindow[0]  = false
              end
            end)
          end
        end
        imgui.PopStyleColor(2)
      else
        imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
        if imgui.Button(u8"Accept >>>##sinvaccept", imgui.ImVec2(btnW, 28)) then
          local id = sinvSession.targetId
          sinvitePendingCmd = "/invite " .. id
          sinvSession.active = false; showSinvWindow[0] = false
        end
        imgui.PopStyleColor(2)
      end

      imgui.SameLine()

      -- discard 
      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
      if imgui.Button(u8"Discard >>>##sinvdiscard", imgui.ImVec2(btnW, 28)) then
        lua_thread.create(function()
          for _, ln in ipairs(sinviteDecline.lines) do
            sampSendChat(toChat(ln.text)); wait(ln.delay or 800)
          end
        end)
        sinvSession.active = false; showSinvWindow[0] = false
      end
      imgui.PopStyleColor(2)

      imgui.SameLine()

      imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnstop, 0.90))
      imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnsoph))
      if imgui.Button(u8"Exit >>>##sinvexit", imgui.ImVec2(btnW, 28)) then
        sinvSession.active = false; showSinvWindow[0] = false
      end
      imgui.PopStyleColor(2)
    end

    imgui.End()
    imgui.PopStyleColor(5)
  end
)
-- ═══ ОКНО ОБНОВЛЕНИЯ ═══
imgui.OnFrame(
  function() return showUpdateWindow[0] end,
  function(self)
    self.HideCursor = false
    imgui.PushStyleColor(imgui.Col.WindowBg,      imgui.ImVec4(0.05, 0.05, 0.07, 0.97))
    imgui.PushStyleColor(imgui.Col.TitleBgActive, v4(T.titlehi))
    imgui.PushStyleColor(imgui.Col.TitleBg,       v4(T.titlebg))
    imgui.PushStyleColor(imgui.Col.Border,        v4(T.btn, 0.60))
    imgui.PushStyleColor(imgui.Col.Separator,     v4(T.sep, 0.35))

    imgui.SetNextWindowSize(imgui.ImVec2(400, 550), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(200, 50), imgui.Cond.FirstUseEver)
    imgui.Begin(u8"TSR-Binder — Обновление", showUpdateWindow,
      imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize)

    -- Заголовок
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Текущая версия: " .. SCRIPT_VERSION)
    imgui.PopStyleColor()
    imgui.Spacing()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.80, 0.0, 1.0))
    imgui.Text(u8"Список изменений:")
    imgui.PopStyleColor()

    imgui.Spacing()
    imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(0.50, 0.50, 0.50, 0.60))
    imgui.Separator()
    imgui.PopStyleColor()
    imgui.Spacing()

    -- Область контента (динамический текст ченджлога)
    local contentH = imgui.GetWindowHeight() - 160
    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0, 0, 0, 0.20))
    imgui.BeginChild("##updatecontent", imgui.ImVec2(-1, contentH), false)
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70, 0.85, 1.0, 1.0))
    imgui.Text(u8"New version: " .. tostring(updateState.remoteVersion or "-"))
    imgui.PopStyleColor()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70, 0.70, 0.70, 1.0))
    imgui.TextWrapped(updateState.statusText or u8"Waiting for update check.")
    imgui.PopStyleColor()
    imgui.Spacing()
    imgui.TextWrapped(updateState.changelogText or u8"Loading update information...")
    if false then
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.75, 0.75, 0.75, 1.0))
    -- Placeholder — сюда будет подтягиваться текст с GitHub
    imgui.TextWrapped(u8"Загрузка информации об обновлении...")
    imgui.PopStyleColor()
    end
    imgui.EndChild()
    imgui.PopStyleColor()

    imgui.Spacing()
    imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(0.50, 0.50, 0.50, 0.60))
    imgui.Separator()
    imgui.PopStyleColor()
    imgui.Spacing()

    -- Кнопки
    local btnW = (imgui.GetWindowWidth() - 24) / 2

    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnpos, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnposh))
    if imgui.Button(u8"Update##doupdate", imgui.ImVec2(btnW, 28)) then
      -- TODO: логика обновления с GitHub
    end
    imgui.PopStyleColor(2)
    if imgui.IsItemClicked() and not updateState.checking and not updateState.downloading then
      if updateState.hasUpdate then
        beginUpdateInstall()
      else
        beginUpdateCheck()
      end
    end

    imgui.SameLine()

    imgui.PushStyleColor(imgui.Col.Button,        v4(T.btnneg, 0.90))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, v4(T.btnnegh))
    if imgui.Button(u8"Cancel##cancelupdate", imgui.ImVec2(btnW, 28)) then
      showUpdateWindow[0] = false
    end
    imgui.PopStyleColor(2)

    imgui.End()
    imgui.PopStyleColor(5)
  end
)
