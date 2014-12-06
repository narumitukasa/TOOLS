#coding: utf-8
require_relative 'selectorbase'

module WS
  ### 画像選択コントロールのクラス ###
  class WSImageSelector < WSSelectorBase
    
    # 初期化
    def initialize(sx, sy, width, height, dir = "")
      @filename = ""
      @dir = dir
      super(sx, sy, width, height)
    end

    # 値の参照
    def value
      @filename
    end
    
    # 値の設定
    def value=(v)
      @filename = v
      super
    end   

    # 選択
    def select(obj)
      @filename = obj.path
      super
    end    
    
    # サブウィンドウの作成
    def create_sub_window(obj, tx, ty)
      isw = WSImageSelectWindow.new(@dir)
      isw.add_handler(:decide, method(:select))
      WS.desktop.add_control(isw)
    end
    
    # 描画文字列
    def text
      @filename
    end
    
    
  end
  
  
  

  # 画像選択ウィンドウ
  class WSImageSelectWindow < WSWindow
    
    def initialize(dir="./")
      cw = 1280
      ch = 720
      cx = WS.desktop.width / 2 - cw / 2
      cy = WS.desktop.height / 2 - ch / 2
      super(cx, cy, cw, ch, "画像選択ウィンドウ" + dir)
      @dir = dir
      
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
      btn_can = WS::WSButton.new(client.width - 128, client.height - 32, 100, 20, "キャンセル")
      client.add_control(btn_can, :button_can)
      btn_can.add_handler(:click){self.close}
            
      # リストの作成
      client.add_control(WS::WSListBox.new(8, 8, 240, client.height - 56) ,:c_list)
      client.c_list.add_handler(:select, method(:select_list))
      client.c_list.set_items(list_text)
      
      # プレビュー領域の作成
      client.add_control(WS::WSPreviewArea.new(260, 8, client.width - 280 , client.height - 56) ,:c_preview)
    end
    
    # リストの作成
    def list_text
      tmp_list = Dir::entries(@dir).select{ |filename| image?(File.extname(filename)) }
      tmp_list.unshift("") 
    end
    
    # 画像ファイルかを調べる
    def image?(extname)
      extname == ".png" || extname == ".bitmap"
    end
      
    # リストの選択
    def select_list(sx, sy)
      client.c_preview.filename = path
    end
    
    # パスを取得
    def path
      @dir + client.c_list.item
    end
    
    # ドラッグ移動の処理      
    def on_drag_move(obj, dx, dy)
      move(self.x + dx, self.y + dy)
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

    # 描画
    def draw
      draw_border(true)
      super
    end
    
  end
  
  
  
  
end