# coding: utf-8
module PostEffect  
 
  ### ■ポストエフェクト：グローエフェクター■ ###
  class Tone < DXRuby::Shader
    # シェーダコアのHLSL記述
    hlsl = <<EOS
    // (1) グローバル変数
        float4  tone;
        float   alpha; 
        texture tex0;

    // (2) サンプラ
        sampler Samp0 = sampler_state
        {
            AddressU  = Border;
            AddressV  = Border;
            Texture =<tex0>;
        };

    // (3) 入出力の構造体
        struct PixelIn
        {
            float2 UV : TEXCOORD0;
        };
        struct PixelOut
        {
            float4 Color : COLOR0;
        };

    // (4) ピクセルシェーダのプログラム
        PixelOut PS_P0_Main(PixelIn input)
        {
            PixelOut output;
            output.Color =  tex2D(Samp0, input.UV);
            output.Color += tone;
            output.Color.a *= alpha;
            
            return output;
        }

    // (5) technique定義
        technique Glow
        {
            pass P0
            {
                PixelShader = compile ps_2_0 PS_P0_Main();
            }
        }
EOS
    # シェーダコアの作成
    @@core = DXRuby::Shader::Core.new(
        hlsl,{
               :tone  => :float,
               :alpha => :float,
               }
    )

    # 初期化
    def initialize( tone = [0, 0, 0, 0], alpha=1.0 )
      super(@@core, "Tone")
      @tone = tone
      @alpha = alpha
    end

    # シェーダーのリフレッシュ
    def refresh
      self.tone = @tone
      self.alpha = @alpha
    end

    # パラメータの設定
    def set_parameter(red, green, blue, gray)
      @tone[0..3] = red / 255.0, green / 255.0, blue / 255.0, 0
    end

    # パラメータの設定
    def set_alpha(alpha)
      @alpha = alpha / 255.0
    end
       
    # 識別用シンボル
    def symbol
      :tone
    end

  end
  
end