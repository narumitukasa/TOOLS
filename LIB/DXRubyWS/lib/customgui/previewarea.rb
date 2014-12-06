#coding: utf-8

module WS
  ### プレビュー領域のクラス ###
  class WSPreviewArea < WSScrollableContainer
    
    class WSPrebiewAreaClient < WSContainer
      include ButtonClickable
      
      # 背景イメージ
      def bg_image
        IMG_CACHE[:preview_area_bg] || create_check_image
      end
      
      # 画像の作成
      def render
        image.ox = @parent.hsb.pos
        image.oy = @parent.vsb.pos
        render_bg
        render_image
        render_sprite  
        super    
      end
      
      # 背景の描画
      def render_bg
        image.draw_tile(nil, nil, [[0]], [bg_image], nil, nil, nil, nil)
      end
      
      # 画像の描画
      def render_image
        image.draw(0, 0, @parent.preview_image)
        #画像のボーダーラインの描画
        unless @parent.filename.empty?
          ex = @parent.preview_image.width - 1
          ey = @parent.preview_image.height - 1
          image.draw_line(0,ey,ex,ey,C_WHITE)
          image.draw_line(ex,0,ex,ey,C_WHITE)
        end
      end
      
      # スプライトの描画
      def render_sprite
        @parent.sprite_list.each do |sprite|
          sprite.draw
        end
      end
      
    end
    
    # 公開インスタンス
    attr_reader :layer ,:preview_image, :sprite_list, :filename
    
    # 初期化
    def initialize(sx, sy, width, height)
  
      # クライアントの作成
      client = WSPrebiewAreaClient.new(2, 2, width - 4, height - 4)
      
      # コントロールの初期化
      super(sx, sy, width, height, client)
      @filename = ""
      @preview_image = Cache.load_image(@filename)
      @layer         = RenderTarget.new(@width, @height)
      @sprite_list   = []
      
      # サイズの変更
      resize(@width, @height)
 
      # 横スクロールバ
      hsb.total_size = 64 # リストボックス内データのサイズ(ピクセル単位)
      hsb.view_size = client.width # 画面に見えているデータのサイズ(ピクセル単位)
      hsb.shift_qty = 24 # 上下ボタンで動く量(ピクセル単位)     
      # 縦スクロールバーを使うための設定。
      vsb.total_size = 64 # リストボックス内データのサイズ(ピクセル単位)
      vsb.view_size = client.height # 画面に見えているデータのサイズ(ピクセル単位)
      vsb.shift_qty = 24 # 上下ボタンで動く量(ピクセル単位)     
  
            
    end
    
    # ファイルネーム(パス)を設定
    def filename=(filename)
      @filename = filename
      @preview_image = Cache.load_image(@filename)
      resize(@width, @height)
    end
    
    # スプライトをセット   
    def set_sprite(sprite)
      sprite.target = client.image
      @sprite_list << sprite
    end
    
    # イメージの幅を取得
    def image_width
      @preview_image.width
    end
    
    # イメージの高さを取得
    def image_height
      @preview_image.height
    end
    
    # クライアント領域のリサイズ
    def resize(width, height)
      hsb.total_size = @preview_image.width
      vsb.total_size = @preview_image.height
      super
      hsb.view_size = client.width
      vsb.view_size = client.height
      @layer.resize(width, height)
    end

  end
  
end