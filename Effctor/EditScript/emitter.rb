module WS
  ### アニメーションウィンドウ ### 
  class AnimationWindow
    ### エミッタータブパネルの定義 ###  
    class WSTabPanel_Emitter < WSTabPanel
      
      # 初期化
      def initialize(cx, cy, cw, ch)
        super
        @list = $data_emitter
        create_controls
      end
      
      # データベースの作成
      def create_database
        tmp = [Game::Emitter.new.header, Game::Emitter.new]
        DataManager.save_data(tmp,"./Data/Emitter.dat")
      end
      
      # コントロールの作成
      def create_controls
        add_control(WSPanel_Emitter.new(220, 8, 240, @height - 16), :c_panel_effector)
        c_panel_effector.add_handler(:change){ start_preview }
        # リストの作成
        add_control(WSSortableList.new(12, 8, 200, @height - 16, @list, "エミッターリスト"), :c_list)
        c_list.add_handler(:select, method(:select_list))
        # エミッタープレビュー領域の作成
        add_control(WS::WSPreviewArea.new(468, 42, @width - 476 , @height - 48) ,:c_preview)
        add_control(WS::WSButton.new(468, 16, 128, 20, "プレビュー再生"), :c_btn_preview)
        c_btn_preview.add_handler(:click){ start_preview }
        # コメント領域の作成
        add_control(WS::WSComment.new(@width - 204, 12, 196, 24, "", true), :c_emitter_info)
        # プレビュー用スプライトの作成
        @emitter = Game_Emitter.new(Game::Emitter.new)
        @emitter.set_pos(c_preview.client.width / 2, c_preview.client.height / 2)
        c_preview.set_sprite(@emitter)
        # 初期項目の選択
        select_list(c_list, 0)
      end 

      ### リスト操作 ###
      # リスト項目の選択
      def select_list(obj, cursor)
        c_panel_effector.set_edit_data(obj.current_item)
        @emitter.set_new_emitter(obj.current_item)
      end

      ### プレビュー ###
      def start_preview
        @emitter.set_up
      end      
      
      ### 更新 ###
      def update
        @emitter.update if visible
        c_emitter_info.caption = @emitter.emiter_info
        super
      end
      
      ### 描画 ###
      def render
        #render_preview
        super
      end
      
      # プレビュー領域のグリッドの描画
      def render_preview
        #em = c_list.current_item
        
        #pi = c_preview.client.image
        #w  = c_preview.client.width / 2
        #h  = c_preview.client.height / 2
        #ew = em.width
        #eh = em.height  
        
        #pi.draw_line(w - 4, h ,w + 4, h, C_MAGENTA, self.z + 1)
        #pi.draw_line(w, h - 4 , w, h + 4, C_MAGENTA, self.z + 1)
        #pi.draw_line(w - ew / 2, h - eh / 2, w - ew / 2, h + eh / 2,C_RED, self.z + 1)
        #pi.draw_line(w + ew / 2, h - eh / 2, w + ew / 2, h + eh / 2,C_RED, self.z + 1)
        #pi.draw_line(w - ew / 2, h - eh / 2, w + ew / 2, h - eh / 2,C_RED, self.z + 1)
        #pi.draw_line(w - ew / 2, h + eh / 2, w + ew / 2, h + eh / 2,C_RED, self.z + 1)
      end      
        
      ### ■エミッターパネルの定義■ ###
      class WSPanel_Emitter < WSPanel
        
        # 公開インスタンス
        attr_reader   :edit_data       
       
        # 初期化    
        def initialize(cx, cy, cw, ch)
          super(cx, cy, cw, ch, "エミッター設定")
          @edit_data = Game::PartsFrame.new
          create_controls
        end
  
        # コントロールの作成
        def create_controls
          cx = 4
          cy = 22
          cw = @width - 8
          ch = 20
          cw2 = cw / 2 - 4
          cx2 = cw2 + 8 + cx
          row = 0
          
          add_control(WS::WSLabel.new(cx, cy * row, cw, ch, "名前"))
          add_control(WS::WSTextBox.new(cx, cy * (row+1), cw, ch), :c_name)
          c_name.add_handler(:change){ edit_data.name = c_name.value }
          
          row += 2
          add_control(WS::WSLabel.new(cx, cy * row, cw, ch, "エミッターセット"))
          add_control(WSItemSelector.new(cx, cy * (row+1), cw, ch, $data_parts, "エミッターを選択", true), :c_parts_list)
          c_parts_list.add_handler(:change){ edit_data.parts_list = c_parts_list.value; signal(:change) }

          row += 3
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "乱数種"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_rand_seed)
          c_rand_seed.add_handler(:change){|obj, v| edit_data.rand_seed = v; signal(:change) }
          c_rand_seed.limit(-1, 10230)
            
          row += 2
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "持続時間"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_span)
          c_span.add_handler(:change){ edit_data.span = c_span.value; signal(:change) }
          c_span.limit(1, 10000)
            
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "持続時間分散度"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_span_variance)
          c_span_variance.add_handler(:change){ edit_data.span_variance = c_span_variance.value; signal(:change) }
          c_span_variance.limit(0, 100)
        
          row += 2
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出数"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_injection_number)
          c_injection_number.add_handler(:change){ edit_data.injection_number = c_injection_number.value; signal(:change) }
          c_injection_number.limit(1, 128)
            
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出数分散度"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_injection_number_variance)
          c_injection_number_variance.add_handler(:change){ edit_data.injection_number_variance = c_injection_number_variance.value; signal(:change) }
          c_injection_number_variance.limit(0, 200)
              
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出間隔"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_interval)
          c_interval.add_handler(:change){ edit_data.interval = c_interval.value }
          c_interval.limit(1, 10000)
      
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "最大値"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_max_parts)
          c_max_parts.add_handler(:change){ edit_data.max_parts = c_max_parts.value }
      
            
          row += 2
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "半径X"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_radius_x)
          c_radius_x.add_handler(:change){ edit_data.radius_x = c_radius_x.value }
      
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "半径Y"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_radius_y)
          c_radius_y.add_handler(:change){ edit_data.radius_y = c_radius_y.value }
      
                
          row += 2
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出速度"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_velocity)
          c_velocity.add_handler(:change){ edit_data.velocity = c_velocity.value; signal(:change) }
          c_velocity.limit(0, 10000)
                
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出速度分散度"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_velocity_variance)
          c_velocity_variance.add_handler(:change){ edit_data.velocity_variance = c_velocity_variance.value; signal(:change) }
          c_velocity_variance.limit(0, 200)
            
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "加速度"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_acceleration)
          c_acceleration.add_handler(:change){ edit_data.acceleration = c_acceleration.value; signal(:change) }
          c_acceleration.limit(-1023, 1024)
            
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "加速度分散度"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_acceleration_variance)
          c_acceleration_variance.add_handler(:change){ edit_data.acceleration_variance = c_acceleration_variance.value; signal(:change) }
          c_acceleration_variance.limit(0, 200)
            
          row += 2
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出方向"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_emit_angle)
          c_emit_angle.add_handler(:change){ edit_data.emit_angle = c_emit_angle.value; signal(:change) }
          c_emit_angle.limit(0, 36000)  
            
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "目標射出方向"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_target_emit_angle)
          c_target_emit_angle.add_handler(:change){ edit_data.emit_angle = c_target_emit_angle.value; signal(:change) }
          c_target_emit_angle.limit(0, 36000)  
                
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出範囲"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_emit_range)
          c_emit_range.add_handler(:change){ edit_data.emit_range = c_emit_range.value; signal(:change) }
          c_emit_range.limit(0, 360)
            
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "目標射出範囲"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_target_emit_range)
          c_target_emit_range.add_handler(:change){ edit_data.target_emit_range = c_target_emit_range.value; signal(:change) }
          c_target_emit_range.limit(0, 360)
     
               
          row += 2
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "エミッター幅"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_width)
          c_width.add_handler(:change){ edit_data.width = c_width.value; signal(:change) }
          c_width.limit(1, 1920)
            
          row += 1
          add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "エミッター高さ"))
          add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_height)
          c_height.add_handler(:change){ edit_data.height = c_height.value; signal(:change) }
          c_height.limit(1, 1080)
     
          #row += 2
          #add_control(WS::WSLabel.new(cx, cy * row, cw, ch, "シェーダー設定"))
          #add_control(WS::WSShaderSelector.new(cx, cy * (row+1), cw, ch), :c_shader)
          #c_shader.add_handler(:change){ edit_data.shader = c_shader.value; signal(:change) }
          
        end
       
        # 編集データのセット
        def set_edit_data(data)
          @edit_data  = data
          set_parameters
        end
                 
        # エミッター数値をコントロールに設定
        def set_parameters
          return unless @edit_data
          c_name.value = edit_data.name
          c_parts_list.value = edit_data.parts_list
          c_rand_seed.value = edit_data.rand_seed
          c_span.value = edit_data.span
          c_span_variance.value = edit_data.span_variance
          c_injection_number.value = edit_data.injection_number
          c_injection_number_variance.value = edit_data.injection_number_variance
          c_max_parts.value = edit_data.max_parts
          c_interval.value = edit_data.interval
          c_radius_x.value = edit_data.radius_x
          c_radius_y.value = edit_data.radius_y
          c_velocity.value = edit_data.velocity
          c_velocity_variance.value = edit_data.velocity_variance
          c_acceleration.value = edit_data.acceleration
          c_acceleration_variance.value = edit_data.acceleration_variance
          c_emit_angle.value = edit_data.emit_angle
          c_target_emit_angle.value = edit_data.target_emit_angle
          c_emit_range.value = edit_data.emit_range
          c_target_emit_range.value = edit_data.target_emit_range
          c_width.value = edit_data.width
          c_height.value = edit_data.height
        end
      end
    end
  end
  
end
