##########################################################################################
# ■イージング処理のモジュール by mirich 2014,12,6
##########################################################################################
module Easing
  EasingParameter = Struct.new(:setter, :from, :to, :count, :duration, :easing_func, :loop)
   
  def initialize(*args)
    super
    @easing_param = {}
  end
   
  # アニメの開始
  def animate(to, duration, easing_func = :liner, loop: false)
    if easing_func.kind_of?(Symbol)
      easing_func = EasingProcHash[easing_func]
    end

    to.each do |k, v|
      setter = (k.to_s + "=").to_sym
      @easing_param[k] = EasingParameter.new(setter, self.__send__(k), v, 0, duration, easing_func, loop)
    end
  end
  
  # アニメの停止 
  def stop_animate
    @easing_param.clear
  end
   
  # 更新
  def update
    proccess_easing
    super
  end
   
  # イージング処理
  def proccess_easing
    @easing_param.delete_if do |key, param|
      param.count += 1
      x = param.count.fdiv(param.duration)
      if param.count >= param.duration
          self.__send__(param.setter, param.to)
        if param.loop
          param.count = 0
          false
        else
          true
        end
      else
        self.__send__(param.setter, param.easing_func.call(x) * (param.to - param.from) + param.from)
        false
      end
    end
  end
  
  EasingProcHash = {
  :liner => ->x{x},
  :in_quad => ->x{x**2},
  :in_cubic => ->x{x**3},
  :in_quart => ->x{x**4},
  :in_quint => ->x{x**5},
  :in_expo => ->x{x == 0 ? 0 : 2 ** (10 * (x - 1))},
  :in_sine => ->x{-Math.cos(x * Math::PI / 2) + 1},
  :in_circ => ->x{x == 0 ? 0 : -(Math.sqrt(1 - (x * x)) - 1)},
  :in_back => ->x{s = 1.70158; x * x * ((s + 1) * x - s)},
  :in_bounce => ->x{1-EasingProcHash[:out_bounce][1-x]},
  :in_elastic => ->x{1-EasingProcHash[:out_elastic][1-x]},
  :out_quad => ->x{1-EasingProcHash[:in_quad][1-x]},
  :out_cubic => ->x{1-EasingProcHash[:in_cubic][1-x]},
  :out_quart => ->x{1-EasingProcHash[:in_quart][1-x]},
  :out_quint => ->x{1-EasingProcHash[:in_quint][1-x]},
  :out_expo => ->x{1-EasingProcHash[:in_expo][1-x]},
  :out_sine => ->x{1-EasingProcHash[:in_sine][1-x]},
  :out_circ => ->x{1-EasingProcHash[:in_circ][1-x]},
  :out_back => ->x{1-EasingProcHash[:in_back][1-x]},
  :out_bounce => ->x{
    if x < (1 / 2.75)
      7.5625 * x * x
    elsif x < (2 / 2.75)
      x -= 1.5 / 2.75
      7.5625 * x * x + 0.75
    elsif x < 2.5 / 2.75
      x -= 2.25 / 2.75
      7.5625 * x * x + 0.9375
    else
      x -= 2.625 / 2.75
      7.5625 * x * x + 0.984375
    end
  },
  :out_elastic => ->x{
    case x
    when 0, 1
      x
    else
      (2 ** (-10 * x)) * Math.sin((x / 0.15 - 0.5) * Math::PI) + 1
    end
  },
  :swing => ->x{0.5 - Math.cos( x * Math::PI ) / 2},
  :inout_quad => ->x{
    if x < 0.5
      x *= 2
      0.5 * x * x
    else
      x = (x * 2) - 1
      -0.5 * (x * (x - 2) - 1)
    end
  },
  :inout_cubic => ->x{
    if x < 0.5
      x *= 2
      0.5 * x * x * x
    else
      x = (x * 2) - 2
      0.5 * (x * x * x + 2)
    end
  },
  :inout_quart => ->x{
    if x < 0.5
      x *= 2
      0.5 * x * x * x * x
    else
      x = (x * 2) - 2
      -0.5 * (x * x * x * x - 2)
    end
  },
  :inout_quint => ->x{
    if x < 0.5
      x *= 2
      0.5 * x * x * x * x * x
    else
      x = (x * 2) - 2
      0.5 * (x * x * x * x * x + 2)
    end
  },
  :inout_sine => ->x{
    -0.5 * (Math.cos(Math::PI * x) - 1);
  },
  :inout_expo => ->x{
    case x
    when 0, 1
      x
    else
      if x < 0.5
        x *= 2
        0.5 * (2 ** (10 * (x - 1)))
      else
        x = x * 2 - 1
        0.5 * (-2 ** (-10 * x) + 2)
      end
    end
  },
  :inout_circ => ->x{
    if x < 0.5
      x *= 2
      -0.5 * (Math.sqrt(1 - x * x) - 1);
    else
      x = x * 2 - 2
      0.5 * (Math.sqrt(1 - x * x) + 1);
    end
  },
  :inout_back => ->x{
    case x
    when 0, 1
      x
    else
      if x < 0.5
        EasingProcHash[:in_back][x*2] * 0.5
      else
        EasingProcHash[:out_back][x*2-1] * 0.5 + 0.5
      end
    end
  },
  :inout_bounce => ->x{
    case x
    when 0, 1
      x
    else
      if x < 0.5
        EasingProcHash[:in_bounce][x*2] * 0.5
      else
        EasingProcHash[:out_bounce][x*2-1] * 0.5 + 0.5
      end
    end
  },
  :inout_elastic => ->x{
  case x
  when 0, 1
    x
  else
    if x < 0.5
      EasingProcHash[:in_elastic][x*2] * 0.5
    else
      EasingProcHash[:out_elastic][x*2-1] * 0.5 + 0.5
    end
  end
  },
  }
end