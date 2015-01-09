# coding: utf-8

require 'inifile'
require 'dxruby'

require_relative '../../DXRubyWS/lib/dxrubyws'
require_relative '../../DXRubyWS/lib/standardgui'
require_relative '../../DXRubyWS/lib/fontcache'
require_relative '../LIB/DXRubyWS/lib/customgui/customgui'

WS.set_theme("guibasic")

require_relative '../LIB/NTLIB/gamemodule'
require_relative '../LIB/NTLIB/posteffect'
require_relative '../LIB/NTLIB/easing'
require_relative '../LIB/NTLIB/spritebase'

require_relative 'GameScript/dataclass'
require_relative 'GameScript/gamemodule'
require_relative 'GameScript/gameobj'
require_relative 'EditScript/window'

exit if defined?(Ocra) 

$ini = IniFile.load("./Config.ini")

window_width = [$ini['size']['WindowWidth'].to_i, Window.get_current_mode[0]-16].min
window_height = [$ini['size']['WindowWidth'].to_i, Window.get_current_mode[1]-72].min
# ウィンドウの初期設定
Window.x = 0
Window.y = 0
Window.resize(window_width, window_height)                 # ウィンドウサイズの設定
Window.min_filter = TEXF_POINT           # フィルター
Window.mag_filter = TEXF_POINT           # フィルター
Window.scale      = 1             
Window.fps        = 60                    # FPS
Window.frameskip  = false                 # フレームスキップ

window = WS::AnimationWindow.new
WS.desktop.add_control(window)
 
@load_value = 0
@load_count = 0

Window.loop do 
  
  WS.update
  
  @load_value += Window.get_load
  @load_count = (@load_count + 1) % 60
  if @load_count == 0  
    Window.caption = "CPU:#{@load_value.to_i / 60}%"
    @load_value = 0
  end
  
end