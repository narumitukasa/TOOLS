# coding: utf-8

module WS
  class WSComment < WSControl
    
    # 公開インスタンス
    attr_accessor :caption, :fore_color, :bgcolor 
    
    # 初期化
    def initialize(tx, ty, width, height, caption = "" , bordar = true, bg_color = [0,0,0,0,])
      super(tx, ty, width, height)
      self.collision_enable = false
      self.image = Image.new(@width, @height)
      @caption    = caption
      @bg_color   = bg_color
      @fore_color = COLOR[:font]
      @border     = bordar
      @refresh    = true
    end
    
    # 背景色の変更
    def bg_color=(color)
      @bg_color = color
      @refresh  = true
    end
  
    # 境界線の有無の変更
    def border=(v)
      @border = v
      @refresh  = true
    end
  
    def resize(width, height)
      self.image.dispose
      self.image = Image.new(width, height)
      @refresh = true
      super
    end
          
    # イメージの作成
    def set_image
      self.image.clear
      self.image.fill(@bg_color)
      self.image.draw_border(false)
      @refresh = false
    end
    
    # 描画
    def draw
      set_image if @refresh
      super
      width = @font.get_width(@caption)
      self.target.draw_font(self.x + 4,
                            self.height / 2 - @font.size / 2 + self.y - 1,
                            @caption, @font, :color=>@fore_color)
    end
    
  end
end