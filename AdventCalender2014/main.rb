# coding: utf-8

require 'dxruby'

# スクリプトの読み込み
require_relative 'Scripts/ntmodule'
require_relative 'Scripts/posteffect'
require_relative 'Scripts/dataclass'
require_relative 'Scripts/gamemodule'
require_relative 'Scripts/gameobj'

exit if defined?(Ocra) 

# ウィンドウの初期設定
Window.resize(640, 480)
Window.scale = 2.0
Window.caption = "DXRubyAdventClender2014"
Window.load_icon("Images/icon.ico")

# エフェクトデータの読み込み
DataManager.load_effect

### トレイル用エフェクトの定義 ###
class Trail
  
  def initialize
    @effect = []
    # トレイルエフェクト
    @effect << Game_Emitter.new($data_emitter[5])
    @effect << Game_Emitter.new($data_emitter[6])
    @effect << Game_Parts.new($data_parts[6])
    @effect << Game_Parts.new($data_parts[4])
    # 爆発エフェクト
    @effect << Game_Emitter.new($data_emitter[1])
    @effect.last.finish # 自動でスタートするので一旦終了
  end
  
  # 爆発を表示
  def display_bomb
    # 爆発エフェクトが終了中なら爆発表示開始
    @effect.last.set_up if @effect.last.finish?
  end
  
  def update
    # 左クリックで爆発表示
    display_bomb  if Input.mouse_push?(M_LBUTTON)
    Sprite.update(@effect)
    @effect.each{|e| e.set_pos(Input.mouse_pos_x / Window.scale, Input.mouse_pos_y / Window.scale)}
  end  
    
  def draw
    Sprite.draw(@effect)
  end
  
end

### 背景用画像の作成 ###
plane_o = 0
plane = [Image.new(16,16,[32,32,64]),Image.new(16,16,[32,32,128])]
 
effect = Trail.new

Window.loop do 
  
  # 背景スクロール描画
  plane_o += 2
  Window.draw_tile(nil, nil, [[0,1],[1,0]], [plane], plane_o/5, plane_o/10, nil, nil)
  
  # エフェクトの更新と描画
  effect.update
  effect.draw
  
end