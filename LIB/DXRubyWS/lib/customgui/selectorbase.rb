#coding: utf-8

module WS
  ### 選択コントロールのスーパークラス ###
  class WSSelectorBase < WSContainer
    
    # Mix-In
    include DoubleClickable
    include Focusable
    
    # 公開インスタンス
    attr_accessor :fore_color
    
    # 初期化
    def initialize(sx, sy, width, height)
      super(sx, sy, [width, 48].max, [height, 20].max)
      @fore_color = COLOR[:font]
      @image = @image || {}
      create_image
      create_controls
      self.add_handler(:doubleclick, method(:create_sub_window))      
    end
  
    # コントロールの作成
    def create_controls
      # ボタンの作成
      font_s = Font.new(8)
      c_button = WSButton.new(0, 0, 16, height - 4)
      c_button.font = font_s
      c_button.caption = "…"
      c_button.add_handler(:click, method(:create_sub_window))
      # コントロールの登録
      add_control(WSLabel.new(0, 0, width, height), :c_label)
      add_control(c_button, :c_button)
      # ハンドラの登録
      add_handler(:enter){|obj| obj.c_label.fore_color = COLOR[:font_reverse]}
      add_handler(:leave){|obj| obj.c_label.fore_color = @fore_color}
              
      layout(:hbox) do
        self.margin_top = self.margin_bottom = 2
        self.margin_left = self.margin_right = 2
        add obj.c_label, true, true
        add obj.c_button, false, false 
      end
      
    end
  
    # コントロール画像の作成
    def create_image
      # コントロール画像の解放
      @image.values{|img| img.dispose if img}  
      # 通常背景の作成
      @image[:nomal] = Image.new(width, height, COLOR[:background]).draw_border(false)
      # アクティブ時の背景作成
      @image[:active] = Image.new(width, height, COLOR[:select]).draw_border(false)
    end
          
    # 値の参照
    def value
      
    end
    
    # 値の設定
    def value=(v)
      set_text
    end   
  
    # 選択
    def select(obj)
      signal(:change)
      set_text
    end    
    
    # 画像選択ウィンドウの作成
    def create_sub_window(obj, tx, ty)
      
    end

    # リサイズ    
    def resize(w, h)
      super
      create_image
    end
   
    # 文字列の書き換え
    def set_text
      c_label.caption = text
    end
    
    # 描画文字列の取得
    def text 
      ""
    end
    
    # 画像の作成
    def render
      # 背景描画
      self.image.draw(0, 0, @image[activated? ? :active : :nomal])
      # 文字列表示
      #font_color = self.activated? ? COLOR[:font_reverse] : @fore_color
      super
    end
    
  end      

end