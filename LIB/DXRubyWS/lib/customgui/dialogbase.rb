# coding: utf-8

module WS
  
  class WSDialogBase < WSLightContainer

    # Mix-In
    include WindowFocus
        
    attr_accessor :border_width # ウィンドウボーダーの幅
    attr_reader :window_focus # ウィンドウ上のフォーカスを持つコントロール
    
    def initialize(tx, ty, sx, sy, caption = "WindowTitle", style = {})
      super(tx, ty, sx, sy)
      
      @border_width = default_border_width
      
      # ウィンドウタイトルはそれでひとつのコントロールを作る
      # メニューやツールバー、ステータスバーもたぶんそうなる
      window_title = WSWindow::WSWindowTitle.new(nil, nil, nil, window_title_height, caption)
      add_control(window_title, :window_title)
      window_title.add_handler(:close) {self.close}
      window_title.add_handler(:drag_move, self.method(:on_drag_move))
      window_title.close_button = (style[:close_button] == true)
      
      # クライアント領域は単純なコンテナである
      client = WSWindow::WSWindowClient.new
      add_control(client, :client)
      
      # オートレイアウトでコントロールの位置を決める
      # Layout#objで元のコンテナを参照できる
      init_layout
      
      # Escで閉じる
      add_key_handler(K_ESCAPE){self.close}
      
    end
    
    # オートレイアウト
    def init_layout
      layout(:vbox) do
        self.margin_top = self.margin_left = self.margin_right = self.margin_bottom = self.obj.border_width
        add obj.window_title
        add obj.client
      end
    end
    
    # ウィンドウタイトルの高さ
    def window_title_height
      return 16
    end
    
    # ボーダー幅のデフォルト値
    def default_border_width
      return 3
    end
    
    # コントロール画像の描画
    def render
      super
    end
    
    def draw
      draw_border(true)
      (@border_width-2).times do |i|
        self.target.draw_box(self.x + i + 2, self.y + i + 2, self.x + self.width - i - 2 - 1, self.y + self.height - i - 2 - 1, self.client.image.bgcolor)
      end
      super
    end
    
    
    def on_drag_move(obj, dx, dy)
      move(self.x + dx, self.y + dy)
    end
  end
end
