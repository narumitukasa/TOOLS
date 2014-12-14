# coding: utf-8

require 'inifile'
require 'dxruby'

$ini = IniFile.load("./Config.ini")

# ウィンドウの初期設定
Window.x = 0
Window.y = 0
Window.resize($ini['size']['WindowWidth'].to_i, $ini['size']['WindowHeight'].to_i)                 # ウィンドウサイズの設定
Window.min_filter = TEXF_POINT           # フィルター
Window.mag_filter = TEXF_POINT           # フィルター
Window.scale      = 1             
Window.fps        = 60                    # FPS
Window.frameskip  = false                 # フレームスキップ

require_relative '../LIB/DXRubyWS/lib/dxrubyws'
require_relative '../LIB/DXRubyWS/lib/standardgui'
require_relative '../LIB/DXRubyWS/lib/customgui/customgui'
require_relative '../LIB/DXRubyWS/lib/fontcache'
WS.set_theme("guibasic")


require_relative '../LIB/NTLIB/gamemodule'
require_relative '../LIB/NTLIB/posteffect'

require_relative 'GameScript/dataclass'
require_relative 'GameScript/gamemodule'
require_relative 'GameScript/gameobj'
require_relative 'EditScript/window'

exit if defined?(Ocra) 
=begin
# ウィンドウカラーの変更
WS::COLOR[:base] = [48, 60, 85]         # ウィンドウやボタン等の基本色
WS::COLOR[:shadow] = [36, 42, 58]         # 影
WS::COLOR[:darkshadow] = [19, 22, 30]        # 濃い影
WS::COLOR[:light] = [85,108,139]          # 明るい
WS::COLOR[:highlight] = [138,154,157]      # ハイライト
WS::COLOR[:background] = [32,50,70]     # テキストボックス、リストボックスなどの背景色
WS::COLOR[:marker] = [239,129,15]               # チェックボックス、ラジオボタン等のマークの色
WS::COLOR[:select] = [51,51,204]            # リストボックスなどの選択色
WS::COLOR[:font] = [255,255,253]                 # デフォルトの文字色
WS::COLOR[:font_reverse] = [255, 255, 253] # 反転文字色
=end
window = WS::AnimationWindow.new
WS.desktop.add_control(window)
 
@load_value = 0
@load_count = 0


Window.load_icon("icon2.ico")
Window.loop do 
  
  WS.update
  #Window.caption = Window.get_load.to_s
  @load_value += Window.get_load
  @load_count = (@load_count + 1) % 60
  if @load_count == 0  
    Window.caption = (@load_value / 60).to_s
    @load_value = 0
  end
  
end