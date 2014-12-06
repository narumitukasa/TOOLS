#coding: utf-8

require_relative 'selectorbase'

module WS
  ### 画像選択コントロールのクラス ###
  class WSShaderSelector < WSSelectorBase
    
    # 初期化
    def initialize(sx, sy, width, height, dir = "")
      @shader = Game::Shader.new
      super(sx, sy, width, height)
    end

    # 値の参照
    def value
      @shader
    end
    
    # 値の設定
    def value=(v)
      @shader = v
      super
    end   

    # 選択
    def select(obj)
      super
    end    
    
    # サブウィンドウの作成
    def create_sub_window(obj, tx, ty)
      isw = WSImageSelectWindow.new
      isw.add_handler(:decide, method(:select))
      WS.desktop.add_control(isw)
    end
    
    # 描画文字列
    def text
      ""
    end
    
    
  end
  
  
  

  # 画像選択ウィンドウ
  class WSShaderSelectWindow < WSWindow
    
    def initialize
      cw = 1280
      ch = 720
      cx = WS.desktop.width / 2 - cw / 2
      cy = WS.desktop.height / 2 - ch / 2
      super(cx, cy, cw, ch, "シェーダー選択ウィンドウ")
      self.image.bgcolor = COLOR[:base]
      
      create_controls
      
      # マウスキャプチャする
      WS.capture(self, true, true)
    end

    def create_controls

      # Escで閉じる
      add_key_handler(K_ESCAPE){self.close}
      
      # ボタンの作成
      btn_ok = WS::WSButton.new(client.width - 240, client.height - 32, 100, 20, "OK")
      client.add_control(btn_ok, :button_ok)
      btn_ok.add_handler(:click){self.decide}
      btn_can = WS::WSButton.new(width - 128, client.height - 32, 100, 20, "キャンセル")
      client.add_control(btn_can, :button_can)
      btn_can.add_handler(:click){self.close}
            
      # リストの作成
      client.add_control(WS::WSListBox.new(8, 8, 240, client.height - 56) ,:c_list)
      client.c_list.add_handler(:select, method(:select_list))
      client.c_list.set_items(list_text)
      
      # プレビュー領域の作成
      client.add_control(WS::WSPreviewArea.new(260, 8, client.width - 280 ,client. height - 56) ,:c_preview)
    end
    
    # リストの作成
    def list_text
      [:none]
    end
    
    # リストの選択
    def select_list(sx, sy)

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

    # 描画
    def draw
      draw_border(true)
      super
    end
    
  end
  
  
  
  
end