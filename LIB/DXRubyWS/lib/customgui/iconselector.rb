#coding: utf-8

module WS
  ### 画像選択コントロールのクラス ###
  class WSIconSelector < WSControl
    
    # Mix-In
    include DoubleClickable
    include Focusable
        
    # 初期化
    def initialize(sx, sy, width, height, icon_width, icon_height, column, path = "")      
      super(sx, sy, width, height)
      self.value = 0
      @path   = path
      @column = column
      @icon_width  = icon_width
      @icon_height = icon_height
      @preview_image = Cache.load_image(@path)
      self.image = Image.new(width, height)
      self.add_handler(:doubleclick, method(:create_sub_window))      
    end

    # 背景イメージ
    def bg_image
      IMG_CACHE[:preview_area_bg] || create_check_image
    end
    
    # 値の参照
    def value
      @index
    end
    
    # 値の設定
    def value=(v)
      temp = @index
      @index = v
      refresh if temp != @index
    end   

    # 選択
    def select(obj)
      @index = obj.index
      signal(:change, @index)
      refresh
    end    
    
    # サブウィンドウの作成
    def create_sub_window(obj, tx, ty)
      cw = [@preview_image.width, 1280].min + 43
      ch = [@preview_image.height, 720].min + 75
      isw = WSIconSelectWindow.new(cw, ch, @icon_width, @icon_height, @column, @path)
      isw.index = @index
      isw.add_handler(:decide, method(:select))
      WS.desktop.add_control(isw)
    end
    
    # 画像の作成
    def render
      if refresh?
        render_bg
        render_image
        render_border
        refreshed
      end   
      super
      
    end
    
    # 背景の描画
    def render_bg
      self.image.fill(COLOR[:darkshadow])
    end
    
    # 画像の描画
    def render_image
      sx = @index % @column * @icon_width
      sy = @index / @column * @icon_height
      self.image.draw(2, 2, @preview_image, sx, sy)
    end
    
    def render_border
      self.image.draw_border(false)
    end
    
  end  
  
  

  # アイコン選択ウィンドウ
  class WSIconSelectWindow < WSWindow
    
    # 公開インスタンス
    attr_reader :index
    
    # 初期化
    def initialize(width, height, icon_width, icon_height, column, path="./")
      cx = WS.desktop.width / 2 - width / 2
      cy = WS.desktop.height / 2 - height / 2
      super(cx, cy, width, height, "アイコン選択ウィンドウ")
      @index = 0
      @icon_width = icon_width
      @icon_height = icon_height
      @column = column
      @path = path
      
      create_controls
      
      # マウスキャプチャする
      WS.capture(self, true)
    end

    # コントロールの作成
    def create_controls

      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      layout(:vbox) do
        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add obj.window_title, true
        add obj.client, true, true
      end
      
      # Escで閉じる
      add_key_handler(K_ESCAPE){self.close}
      add_key_handler(K_RETURN){self.decide}
      
      # ボタンの作成
      btn_ok = WS::WSButton.new(self.client.width - 240, self.client.height - 30, 100, 20, "OK")
      client.add_control(btn_ok, :button_ok)
      btn_ok.add_handler(:click){self.decide}
      btn_can = WS::WSButton.new(self.client.width - 128, self.client.height - 30, 100, 20, "キャンセル")
      client.add_control(btn_can, :button_can)
      btn_can.add_handler(:click){self.close}
            
      # プレビュー領域の作成
      client.add_control(WS::WSPreviewArea.new(8, 8, self.client.width - 16 , self.client.height - 48) ,:c_preview)
      client.c_preview.filename = @path
      client.c_preview.client.add_handler(:click, method(:select_icon))
        
      # コメント表示領域の作成
      client.add_control(WS::WSComment.new(8, client.height - 32, 120, 24),:c_status)
    end
    
    def index=(v)
      @index = v
      client.c_status.caption = sprintf("%s% 4d", "index:", @index)
    end
    
    # アイコン選択の処理      
    def select_icon(obj, sx, sy)
      ix = client.c_preview.hsb.pos + sx
      iy = client.c_preview.vsb.pos + sy
      if ix < client.c_preview.image_width && iy < client.c_preview.image_height
        @index = ix / @icon_width + iy / @icon_height * @column
        client.c_status.caption = sprintf("%s% 4d", "index:", @index)
      end
    end
    
    # ドラッグ移動の処理      
    def on_drag_move(obj, dx, dy)
      move(self.x + dx, self.y + dy)
    end
      
    # ウィンドウを閉じたら次の優先ウィンドウにフォーカスを移す
    def close
      WS.capture(nil)
      super
    end
    
    # 決定ボタン押下処理
    def decide
      signal(:decide)
      close
    end

    # 画像の作成
    def render
      sx = @index % @column * @icon_width
      sy = @index / @column * @icon_height
      ex = sx + @icon_width  - 1
      ey = sy + @icon_height - 1
      pi = client.c_preview.client.image
      pi.draw_line(sx-1, sy-1, sx-1, ey+1, C_BLACK, 1)
      pi.draw_line(ex+1, sy-1, ex+1, ey+1, C_BLACK, 1)
      pi.draw_line(sx-1, sy-1, ex+1, sy-1, C_BLACK, 1)
      pi.draw_line(sx-1, ey+1, ex+1, ey+1, C_BLACK, 1)
      pi.draw_line(sx, sy, sx ,ey, C_WHITE, 1)
      pi.draw_line(ex, sy, ex ,ey, C_WHITE, 1)
      pi.draw_line(sx, sy, ex ,sy, C_WHITE, 1)
      pi.draw_line(sx, ey, ex ,ey, C_WHITE, 1)
      pi.draw_line(sx+1, sy+1, sx+1,ey-1, C_WHITE, 1)
      pi.draw_line(ex-1, sy+1, ex-1,ey-1, C_WHITE, 1)
      pi.draw_line(sx+1, sy+1, ex-1,sy+1, C_WHITE, 1)
      pi.draw_line(sx+1, ey-1, ex-1,ey-1, C_WHITE, 1)
      pi.draw_line(sx+2, sy+2, sx+2,ey-2, C_BLACK, 1)
      pi.draw_line(ex-2, sy+2, ex-2,ey-2, C_BLACK, 1)
      pi.draw_line(sx+2, sy+2, ex-2,sy+2, C_BLACK, 1)
      pi.draw_line(sx+2, ey-2, ex-2,ey-2, C_BLACK, 1)
      super
    end
    
    # 描画
    def draw
      super
      draw_border(true)
    end
    
  end
  
  
  
  
end