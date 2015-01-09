#coding: utf-8

module WS
  ### 並び替え可能番号つきリストボックスのクラス ###
  class WSSortableList < WSContainer
    
    # 初期化
    def initialize(sx, sy, width, height, items = [], caption = "")
      super(sx, sy, width, height)
      @caption = caption
      @items = items ? items : []
      @numbers = []
      @count = 0
      create_controls
    end
    
    # コントロールの作成
    def create_controls
      w = self.width
      h = self.height
      # タイトルの作成
      label = add_control(WSLabel.new(0, 0, w, 20, @caption), :c_label)
      # リストの作成
      add_control(WSListBox.new(0, 24, w, h - 52), :c_list)
      c_list.add_handler(:select, method(:select_list))
      c_list.add_key_handler(K_CTRL + K_UP   ) do move_up_data    end
      c_list.add_key_handler(K_CTRL + K_DOWN ) do move_down_data  end
      # ボタンの作成
      add_control(WSButton.new(0, h - 20, w / 2 - 8, 20, "新規作成"), :c_btn_create)
      add_control(WSButton.new(w / 2 + 4, h - 20, w / 2 - 4, 20, "削除"), :c_btn_delete)
      c_btn_create.add_handler(:click){ create_data}
      c_btn_delete.add_handler(:click){ delete_data}
      # オートレイアウト
      layout(:vbox) do
        self.space = 2
        add label, true, false
        add obj.c_list, true, true
        layout(:hbox) do
          self.space = 4
          add obj.c_btn_create, true, false
          add obj.c_btn_delete, true, false
          self.resizable_height = false
          self.height = 22
        end
      end  
      # 通し番号の作成
      make_number
      # リスト項目のリフレッシュ
      refresh_list
      # カーソル位置の調整
      c_list.set_cursor(c_list.cursor)
    end

    ### 参照 ###
    #インデックス
    def index
      c_list.cursor
    end
    
    # カレントデータ
    def current_item
      item(index)
    end
    
    # データの読み出し
    def item(index)
      @items[@numbers[index].to_i]
    end
    
    # リストのセット
    def set_items(items)
      @items = items
      # 通し番号の作成
      make_number
      # リスト項目のリフレッシュ
      refresh_list
      # カーソル位置の調整
      c_list.set_cursor(0)
    end
      
    ### リスト操作 ###
    # リストテキストの取得
    def list_text
      @numbers.collect { |i|
        value = @items[i]
        next if !value or value.header?
        value.to_s}
    end
    
    # リストの作成
    def make_number
      @items.size.times{|i| @items[i].id = i if @items[i]}
      list = @items.compact.sort{|a, b| (a ? a.no : 0) <=> (b ? b.no : 0)}
      list.size.times{|i| list[i].no = i if list[i]}
      @numbers.clear
      list.each do |value|
        next unless value
        @numbers[value.no] = value.id if (value.header? != true)
      end
      @numbers.compact!
    end
    
    # ナンバーリストのナンバーをリスト内の項目に反映
    #def adjust_number
    #  @numbers.size.times do |i|
    #    @items[@numbers[i]].no = i
    #  end
    #end
    
    # リストの選択
    def select_list(obj, cursor)
      signal(:select, cursor)
    end
    
    # リスト変更操作
    def change_list
      # 通し番号の調整
      make_number
      # リスト項目のリフレッシュ
      refresh_list        
    end
    
    # リストのリフレッシュ
    def refresh_list
      c_list.set_items(list_text)
    end
    
    # 名前をリフレッシュ
    def refresh_name
      c_list.items[c_list.cursor] = current_item.to_s if current_item
    end
    
    ### データの操作 ###  
    # データの作成
    def create_data
      data = signal(:create_data)
      data.no = @items.size
      data.id = @items.size
      @items << data
      change_list
      c_list.set_cursor(c_list.cursor)
    end
     
    # データの削除
    def delete_data
      if !current_item.protect# && Key.down_shift?
        @items.delete_at(@numbers[index])
        change_list
        c_list.set_cursor(c_list.cursor)
      end
    end
     
    # データの移動
    def move_data(new_index, old_index)
      target  = item(new_index)
      current = item(old_index)
      target_no = target.no
      current_no = current.no
      target.no  = current_no
      current.no = target_no
      c_list.set_cursor(new_index)
      change_list
    end

    # データを一つ上に移動
    def move_up_data
      move_data(index - 1, index)
    end
    
    # データを一つ下に移動
    def move_down_data
      move_data(index + 1, index)
    end
    
    # 更新
    def update
      super      
      refresh_name
    end
    
  end
end