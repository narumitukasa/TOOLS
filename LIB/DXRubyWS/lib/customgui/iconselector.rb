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
      cw = [[@preview_image.width, 360].max, 1280].min + 43
      ch = [[@preview_image.height, 240].max, 720].min + 75
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
  class WSIconSelectWindow < WSDialogBase
    
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
      WS.capture(self, true, true)
    end

    # コントロールの作成
    def create_controls

      add_key_handler(K_RETURN){self.decide}
      
      # ボタンの作成
      add_control(WS::WSButton.new(0, 0, 100, 20, "OK"), :c_btn_ok)
      c_btn_ok.add_handler(:click){self.decide}
      add_control(WS::WSButton.new(0, 0, 100, 20, "キャンセル"), :c_btn_cancel)
      c_btn_cancel.add_handler(:click){self.close}
            
      # プレビュー領域の作成
      add_control(WS::WSPreviewArea.new(0, 0, 32, 32) ,:c_preview)
      c_preview.filename = @path
      c_preview.client.add_handler(:click, method(:select_icon))
        
      # コメント表示領域の作成
      add_control(WS::WSComment.new(0, 0, 120, 24),:c_status)
      
      # オートレイアウト
      client.layout(:vbox) do
      	self.set_margin(8, 8, 8, 8)
      	self.space = 4
      	add obj.c_preview, true, true
      	layout(:hbox) do
      		self.space = 4
      		self.resizable_height = false
      		self.height = 24
      	  add obj.c_status, false, false
      	  layout
      	  add obj.c_btn_ok, false, false
      	  add obj.c_btn_cancel, false, false
      	end
      end
      
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
    
    # ウィンドウを閉じたら次の優先ウィンドウにフォーカスを移す
    def close
      WS.release_capture
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
      pi = c_preview.client.image
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
    
  end
  
  
  
  
end