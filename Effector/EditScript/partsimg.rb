#coding: utf-8

module WS
  ### アニメーションウィンドウ ### 
  class AnimationWindow # < WSWindowBase
        
    ### パーツタブパネルの定義 ###  
    class WSTabPanel_PartsImg < WSTabPanel
      
      # Mix-In
      #include EditBase
      
      # 初期化
      def initialize(cx, cy, cw, ch)
        super
        @list = []
        create_controls
      end
      
      # コントロールの作成
      def create_controls
        add_control(WSPanel_PartsImg.new(0, 0, 240, @height - 16), :c_img_panel)
        # プレビュー領域の作成
        create_preview_area(0, 0, @width - 520 , @height - 23)  
        # リストの作成
        add_control(WS::WSSortableList.new(0, 0, 240, @height - 16, @list, "画像リスト"), :c_list)
        c_list.add_handler(:select){ self.select_list}
        select_list
        # オートレイアウト
        layout(:hbox) do
          self.space = 8
          set_margin(8,8,8,8)
          add obj.c_list, false, true
          add obj.c_img_panel, false, true
          add obj.c_preview, true, true
        end
        
      end 
      
      # プレビュー領域の作成
      def create_preview_area(cx, cy, cw, ch)
        add_control(WS::WSPreviewArea.new(cx, cy, cw, ch) ,:c_preview)
        @preview_grid = Sprite.new
      end
        
      ### リスト操作 ###
      # ライブラリの変更
      def change_library
        @list = NFX.current_library.partsimg
      end
      
      # リスト項目の選択
      def select_list
        if c_list.current_item
          # コントロールの有効化
          c_img_panel.enabled = true
          # 項目のセット
          c_img_panel.set_data(c_list.current_item)
        else
          c_img_panel.enabled = false
        end
      end
      
      ### 描画 ###
      # 描画
      def draw 
        draw_preview
        super
      end
      
      # プレビュー領域のグリッドの描画
      def draw_preview
        preview  = c_preview
        partsimg = c_list.current_item
        return unless partsimg
        # 画像の更新
        preview.filename = partsimg.filename
        # グリットの描画
        iw  = partsimg.width
        ih  = partsimg.height
        iox = partsimg.ox
        ioy = partsimg.oy
        isx = partsimg.start_pos_x
        isy = partsimg.start_pos_y
        col = [partsimg.column, (preview.image_width - isx) / iw].min
        # 画像幅が指定された幅より小さい場合終了
        if preview.image_width >= iw && col > 0
  
          partsimg.number_of_pattern.times do |i| 
          
            # 二行目以降の描画
            bx = iw * (i % col) + isx
            by = ih * (i / col) + isy
            # 枠の描画
            c_preview.client.image.draw_line(bx, by, bx, by + ih - 1, C_CYAN, self.z + 1)
            c_preview.client.image.draw_line(bx, by, bx + iw - 1, by, C_CYAN, self.z + 1)
            c_preview.client.image.draw_line(bx, by + ih - 1, bx + iw - 1, by + ih - 1, C_CYAN, self.z + 1)
            c_preview.client.image.draw_line(bx + iw - 1, by, bx + iw - 1, by + ih - 1, C_CYAN, self.z + 1)
            # 原点の描画
            c_preview.client.image.draw_line(bx - 4 + iox, by + ioy, bx + 4 + iox, by + ioy, C_MAGENTA, self.z + 1)
            c_preview.client.image.draw_line(bx + iox, by - 4 + ioy, bx + iox, by + 4 + ioy, C_MAGENTA, self.z + 1)
                    
          end
          
        end
      
      end
      
      ### ■パーツイメージパネルの定義■ ###
      class WSPanel_PartsImg < WSPanel
        attr_reader :edit_data       
        
        def initialize(cx, cy, cw, ch)
          super(cx, cy, cw, ch, "イメージ設定")
          @edit_data = NFX::PartsImg.new(:none)
          create_controls
        end
        
        def create_controls

          lw = 128
          ch = 20
      
          label_name = add_control(WS::WSLabel.new(0, 0, 128, ch, "名前"))
          add_control(WS::WSTextBox.new(0, 0, 128, ch), :c_name)
          c_name.add_handler(:change){ edit_data.name = c_name.value }

          label_filename = add_control(WS::WSLabel.new(0, 0, 128, ch, "ファイル名"))
          add_control(WS::WSImageSelector.new(0, 0, 128, ch, "./Images/Effect/"), :c_filename)
          c_filename.add_handler(:change){ edit_data.filename = c_filename.value }

          label_number_of_pattern = add_control(WS::WSLabel.new(0, 0, lw, ch, "パターン数"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_number_of_pattern)
          c_number_of_pattern.add_handler(:change){ edit_data.number_of_pattern = c_number_of_pattern.value }
          c_number_of_pattern.limit(1, 512)

          label_column = add_control(WS::WSLabel.new(0, 0, lw, ch, "カラム数"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_column)
          c_column.add_handler(:change){ edit_data.column = c_column.value }
          c_column.limit(1, 512)
          
          label_width = add_control(WS::WSLabel.new(0, 0, lw, ch, "幅"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_width)
          c_width.add_handler(:change){ edit_data.width = c_width.value }
          c_width.limit(1, 1280)
          
          label_height = add_control(WS::WSLabel.new(0, 0, lw, ch, "高さ"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_height)
          c_height.add_handler(:change){ edit_data.height = c_height.value }
          c_height.limit(1, 1280)

          label_start_pos_x = add_control(WS::WSLabel.new(0, 0, lw, ch, "始点X"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_start_pos_x)
          c_start_pos_x.add_handler(:change){ edit_data.start_pos_x = c_start_pos_x.value }

          label_start_pos_y = add_control(WS::WSLabel.new(0, 0, lw, ch, "始点Y"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_start_pos_y)
          c_start_pos_y.add_handler(:change){ edit_data.start_pos_y = c_start_pos_y.value }
          
          label_ox = add_control(WS::WSLabel.new(0, 0, lw, ch, "原点X"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_ox)
          c_ox.add_handler(:change){ edit_data.ox = c_ox.value }

          label_oy = add_control(WS::WSLabel.new(0, 0, lw, ch, "原点Y"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_oy)
          c_oy.add_handler(:change){ edit_data.oy = c_oy.value }

          label_cap1 = add_control(WS::WSLabel.new(0, 0, lw, ch, "分割数から幅と高さを自動設定"))
          
          label_auto_column = add_control(WS::WSLabel.new(0, 0, lw, ch, "列"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_auto_column)
          c_auto_column.limit(1, 512)
          
          label_auto_row = add_control(WS::WSLabel.new(0, 0, lw, ch, "行"))
          add_control(WS::WSNumberInputExt.new(0, 0, 128, ch), :c_auto_row)
          c_auto_row.limit(1, 512)
          
          add_control(WS::WSButton.new(0, 0, 128, ch, "自動設定"), :c_btn_auto)
          c_btn_auto.add_handler(:click){ auto_setting }
            
          # オートレイアウト
          client.layout(:vbox) do
            self.space = 2
            add label_name, true, false 
            add obj.c_name, true,  false
            add label_filename, true, false
            add obj.c_filename, true, false
            
            layout do 
              self.resizable_height = false 
              self.height = 22
            end 
            
            layout(:hbox) do
              add label_number_of_pattern, false, false
              add obj.c_number_of_pattern, true, false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_column, false, false
              add obj.c_column, true, false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_width, false, false
              add obj.c_width, true, false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_height, false, false
              add obj.c_height, true, false
              self.resizable_height = false
              self.height = 22
            end
            
            layout do 
              self.resizable_height = false 
              self.height = 22
            end 
            
            layout(:hbox) do
              add label_start_pos_x, false, false
              add obj.c_start_pos_x, true, false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_start_pos_y, false, false
              add obj.c_start_pos_y, true, false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_ox, false, false
              add obj.c_ox, true, false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_oy, false, false
              add obj.c_oy, true, false
              self.resizable_height = false
              self.height = 22
            end
            
            layout do 
              self.resizable_height = false 
              self.height = 22
            end
             
            add label_cap1, true, false
            layout(:hbox) do
              add label_auto_column, false, false
              add obj.c_auto_column, true, false
              self.resizable_height = false
              self.height = 22
            end
            layout(:hbox) do
              add label_auto_row, false, false
              add obj.c_auto_row, true, false
              self.resizable_height = false
              self.height = 22
            end
            add obj.c_btn_auto, true, false
            layout
          end

        end
        
        # 自動設定
        def auto_setting
          if @edit_data && !@edit_data.header?
            img = Cache.load_image(@edit_data.filename)
            @edit_data.width   = [img.width / c_auto_column.value, 1].max
            @edit_data.height  = [img.height / c_auto_row.value, 1].max
            @edit_data.column  = c_auto_column.value
            set_parameters
          end
        end
        
        # 編集データの設定
        def set_data(edit_data)
          @edit_data = edit_data
          set_parameters
        end
        
        # 数値をコントロールに設定
        def set_parameters
          return unless @edit_data
          c_name.value = @edit_data.name
          c_filename.value = @edit_data.filename
          c_width.value = @edit_data.width
          c_height.value = @edit_data.height
          c_ox.value = @edit_data.ox
          c_oy.value = @edit_data.oy
          c_start_pos_x.value = @edit_data.start_pos_x
          c_start_pos_y.value = @edit_data.start_pos_y
          c_number_of_pattern.value = @edit_data.number_of_pattern
          c_column.value = @edit_data.column
        end

      end
      
    end
    
  end
  
end
