#coding: utf-8
require_relative 'selectorbase'

module WS
  ### リスト項目選択コントロールのクラス ###
  class WSItemSelector < WSSelectorBase
    
    attr_accessor :duplication
    
    # 初期化
    def initialize(sx, sy, width, height, list = [], caption="", duplication = false)
      @list = list
      @chosen_list = []  
      @duplication = duplication
      super(sx, sy, width, height)
      @caption = caption
    end

    # 選択元リストの作成
    def set_items(list)
      @list = list
    end
    
    # 値の参照
    def value
      @chosen_list.clone
    end
    
    # 値の設定
    def value=(chosen_list)
      @chosen_list.replace(chosen_list)
      super
    end   

    # 選択
    def select(obj)
      @chosen_list = obj.chosen_list
      super
    end    
    
    # サブウィンドウの作成
    def create_sub_window(obj, tx, ty)
      isw = WSItemSelectWindow.new(@list, @chosen_list, @caption, @duplication)
      isw.add_handler(:decide, method(:select))
      WS.desktop.add_control(isw)
    end
    
    # 描画文字列
    def text
      if @chosen_list.empty? or @list.empty?
        return ""
      elsif @list[@chosen_list.first].nil?
      	return "nil"
      else
        return @list[@chosen_list.first].name
      end 
    end
    
    
  end
  
  
  
  
  # リスト項目選択ウィンドウ
  class WSItemSelectWindow < WSWindow
    
    include FloatingWindow
    
    attr_reader :chosen_list
        
    # 初期化
    def initialize(list, chosen_list, caption, duplication)
      @font = @@default_font
      cw = 360 * 2 + 96 + 16 * 2 + 12 * 2
      ch = 720
      cx = WS.desktop.width / 2 - cw / 2
      cy = WS.desktop.height / 2 - ch / 2
      super(cx, cy, cw, ch)
      @border_width = 3
      @caption = caption
      @duplication = duplication
      @list = list = list
      @chosen_list = chosen_list.clone
  
      create_controls
      # リフレッシュ
      refresh
    end
    
    # コントロールの作成
    def create_controls
 
      # Escで閉じる
      add_key_handler(K_ESCAPE){self.close}
  
      # OKボタン
      btn_ok = WS::WSButton.new(client.width - 240, client.height - 32, 100, 20, "OK")
      client.add_control(btn_ok, :button_ok)
      btn_ok.add_handler(:click){self.decide}
      # キャンセルボタン
      btn_can = WS::WSButton.new(client.width - 128, client.height - 32, 100, 20, "キャンセル")
      client.add_control(btn_can, :button_can)
      btn_can.add_handler(:click){self.close}
      # 追加ボタン
      btn_add = WS::WSButton.new(client.width / 2 - 50, client.height / 2 - 120, 100, 20, "≪追加")
      client.add_control(btn_add, :button_add)
      btn_add.add_handler(:click){self.add}
      # 削除ボタン
      btn_remove = WS::WSButton.new(client.width / 2 - 50, client.height / 2 - 96, 100, 20, "削除≫")
      client.add_control(btn_remove, :button_remove)
      btn_remove.add_handler(:click){self.remove}
      # 一つ上へボタン
      btn_move_up = WS::WSButton.new(client.width / 2 - 50, client.height / 2 - 72, 100, 20, "一つ上へ")
      client.add_control(btn_move_up)
      btn_move_up.add_handler(:click){self.move_up}
      # 一つ下へボタン
      btn_move_down = WS::WSButton.new(client.width / 2 - 50, client.height / 2 - 48, 100, 20, "一つ下へ")
      client.add_control(btn_move_down)
      btn_move_down.add_handler(:click){self.move_down}
      # 整頓
      btn_arrange = WS::WSButton.new(client.width / 2 - 50, client.height / 2 - 24, 100, 20, "整列")
      client.add_control(btn_arrange)
      btn_arrange.add_handler(:click){self.arrange}
      # 全て削除
      btn_all_remove = WS::WSButton.new(client.width / 2 - 50, client.height / 2, 100, 20, "全て取り除く")
      client.add_control(btn_all_remove)
      btn_all_remove.add_handler(:click){self.all_remove}
    
            
      # リストの作成
      client.add_control(WS::WSListBox.new(12, 8, 360, client.height - 56) ,:c_chosen_list)
      client.c_chosen_list.add_handler(:doubleclick){self.remove}
      client.add_control(WS::WSListBox.new(client.width - 372, 8, 360, client.height - 56) ,:c_list)
      client.c_list.add_handler(:doubleclick){self.add}

      
    end
    
    ### リスト ###
    # リストテキストの作成
    def list_text
      @list.collect{|item| item.name}
    end
    
    # 選択リストテキストの作成
    def chosen_list_text
      @chosen_list.collect{|i| @list[i].name if @list[i]}
    end
    
    ### 選択項目が有効か ### 
    def valid?
      return false if @list.empty?
      return true
    end
    
    ### シグナル・ハンドラ・処理 ###
    # リストの選択
    def select_list(sx, sy)

    end
    
    # ドラッグ移動の処理      
    def on_drag_move(obj, dx, dy)
      move(self.x + dx, self.y + dy)
    end  

    # 最大化・最小化(無効化)
    def on_maximize(obj, dx, dy)

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
    
    # 追加ボタン押下処理
    def add
      if valid?
        @chosen_list << client.c_list.cursor
        @chosen_list.uniq! unless @duplication
        refresh
      end
    end
    
    # 削除ボタン押下処理
    def remove
      @chosen_list.delete_at(client.c_chosen_list.cursor)
      refresh
      client.c_chosen_list.set_cursor(client.c_chosen_list.cursor)
    end
        
    # 一つ上に移動
    def move_up
      if client.c_chosen_list.cursor > 0
        index = client.c_chosen_list.cursor
        @chosen_list[index], @chosen_list[index-1] = @chosen_list[index-1], @chosen_list[index]
        refresh
        client.c_chosen_list.set_cursor(client.c_chosen_list.cursor - 1)
      end
    end
    
    # 一つ下に移動
    def move_down
      if client.c_chosen_list.cursor < @chosen_list.size - 1
        index = client.c_chosen_list.cursor
        @chosen_list[index], @chosen_list[index+1] = @chosen_list[index+1], @chosen_list[index]
        refresh
        client.c_chosen_list.set_cursor(client.c_chosen_list.cursor + 1)
      end
    end
    
    # 整頓
    def arrange
      @chosen_list.sort!{|a,b| a<=>b }
      refresh
    end
    
    # 全て取り除く
    def all_remove
      @chosen_list.clear
      refresh
    end
    
    # リフレッシュ
    def refresh
      client.c_list.set_items(list_text)
      client.c_chosen_list.set_items(chosen_list_text)
    end
    
    ### 描画関連 ###
    def draw
      draw_border(true)
      super
    end
    
  end
  
  
  
  
end