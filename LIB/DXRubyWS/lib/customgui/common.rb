# coding: utf-8
module WS
  class WSControl
    @@default_font = Font.new(14)
    
    # 背景イメージの作成
    def create_check_image
      image = Image.new(32, 32)
      image.box_fill( 0,  0, 15, 15, [32, 32, 64])
      image.box_fill(16,  0, 31, 15, [32, 32, 128])
      image.box_fill( 0, 16, 15, 31, [32, 32, 128])
      image.box_fill(16, 16, 31, 31, [32, 32, 64])
      IMG_CACHE[:preview_area_bg] = image
      IMG_CACHE[:preview_area_bg]
    end
    
  end
  
end