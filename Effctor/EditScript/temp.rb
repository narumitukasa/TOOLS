add_control(WS::WSLabel.new(cx, cy * row, cw, ch, "名前"))
add_control(WS::WSTextBox.new(cx, cy * (row+1), cw, ch), :c_name)
c_name.add_handler(:change){ edit_data.name = c_name.value }

row += 2
add_control(WS::WSLabel.new(cx, cy * row, cw, ch, "パーツセット"))
add_control(WSItemSelector.new(cx, cy * (row+1), cw, ch, $data_parts, "パーツを選択", true), :c_parts_list)
c_parts_list.add_handler(:change){ edit_data.parts_list = c_parts_list.value; signal(:change) }

row += 2
add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "乱数種"))
add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_rand_seed)
c_rand_seed.add_handler(:change){ edit_data.rand_seed = c_rand_seed.value; signal(:change) }
c_rand_seed.limt(-1, 10230)
         
row += 2
add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "持続時間"))
add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_span)
c_span.add_handler(:change){ edit_data.span = c_span.value; signal(:change) }

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

row += 1
add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "最大値"))
add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_max_parts)
c_max_parts.add_handler(:change){ edit_data.max_parts = c_max_parts.value }

  
row += 2
add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "半径X"))
add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :radius_x)
radius_x.add_handler(:change){ edit_data.radius_x = c_radius_x.value }

row += 1
add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "半径Y"))
add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_radius_y)
c_radius_y.add_handler(:change){ edit_data.radius_y = c_radius_y.value }

      
row += 2
add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出速度"))
add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_velocity)
c_velocity.add_handler(:change){ edit_data.velocity = c_velocity.value; signal(:change) }
c_velocity.limit(0, 1024)
      
row += 1
add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "射出速度分散度"))
add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_velocity_variance)
c_velocity_variance.add_handler(:change){ edit_data.velocity_variance = c_velocity_variance.value; signal(:change) }
c_velocity_variance.limit(0, 200)
  
row += 1
add_control(WS::WSLabel.new(cx, cy * row, cw2, ch, "加速度"))
add_control(WS::WSNumberInputExt.new(cx2, cy * row, cw2, ch), :c_acceleration)
c_acceleration.add_handler(:change){ edit_data.acceleration = c_acceleration.value; signal(:change) }
  
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