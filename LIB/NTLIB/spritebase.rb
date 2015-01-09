# coding: utf-8
require 'dxruby'

### ■スプライトのベースクラス■ ###
class Sprite_Base < Sprite
  
  # 初期化
  def initialize(target = nil)
    super(0, 0)
    self.offset_sync = true
    self.image  = RenderTarget.new(32, 32)
    self.target = target || Window
    @mirror = false
    @tone_shader = PostEffect::Tone.new
    @tone_change = false
  end
  
  # スプライトの無効化
  def vanish
    # 転送矩形用レンダーターゲットを開放
    self.image.dispose
    super
  end
  
  # 転送原点の設定
  def src_rect(x, y, w, h)
    self.image.resize(w, h)
    self.image.ox = x
    self.image.oy = y
  end
    
  # 色調の設定
  def tone(red, green, blue, gray)
    if red == 0 && green == 0 && blue == 0 && gray == 0
      @tone_change = false
    else
      @tone_shader.set_parameter(red, green, blue, gray)
      @tone_change = true
    end
  end
  
  # 描画
  def draw
    if self.visible && @bitmap
      if @tone_change
        @tone_shader.refresh
        self.image.draw_shader(0, 0, @bitmap, @tone_shader)
      else
        self.image.draw(0, 0, @bitmap)
      end
    end
    # 反転処理
    self.scale_x *= -1.0 if @mirror
    super
    self.scale_x *= -1.0 if @mirror
  end
  
end