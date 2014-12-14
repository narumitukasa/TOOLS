# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'
 
WS.set_theme("guibasic")
 
Window.width, Window.height = 1280, 720 # ワイド画面化
 
class Sprite
def set_easing(ease, to, duration)
@easing_count = 0
@easing_duration = duration
 
@easing_from = self.param_hash
@easing_from[:x] = self.x
@easing_from[:y] = self.y
@easing_to = to
@easing_proc = @@easing_proc_hash[ease]
end
 
def update
if @easing_proc
@easing_count += 1
@easing_to.each do |key, to|
from = @easing_from[key]
 
x = @easing_count.fdiv @easing_duration
self.__send__ @@setter_symbol[key], from + @easing_proc[x, @easing_count, @easing_duration] * (to - from)
end
@easing_proc = nil if @easing_count >= @easing_duration
end
end
 
@@setter_symbol = {
:x => :x=,
:y => :y=,
:angle => :angle=,
:alpha => :alpha=,
:z => :z=,
:scalex => :scale_x=,
:scaley => :scale_y=,
:centerx => :center_x=,
:centery => :center_y=,
}
 
@@easing_proc_hash = {
:liner => ->x,t,d{x},
:swing => ->x,t,d{0.5 - Math.cos( x * Math::PI ) / 2},
:out_bounce => ->x,t,d{
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
:out_elastic => ->x,t,d{
return 0 if x == 0
return 1 if x == 1
p = d * 0.3
s = p / (2 * Math::PI) * Math.asin(1)
(2 ** (-10 * x)) * Math.sin((t - s)*(2 * Math::PI) / p) + 1
}
}
end
 
module WS
module EasingControl
def move(x, y)
self.set_easing(:out_elastic, {:x=>x, :y=>y}, 60)
#super
end
end
class WSButtonBase
include EasingControl
end
class WSImage
include EasingControl
end
end
 
 
# LayoutTestWindow
class Test < WS::WSWindow
def initialize
super(100, 340, 300, 200, "LayoutTest")
 
b1 = WS::WSButton.new(nil, nil, 100, nil, "btn1") # オートレイアウトで自動設定させる座標やサイズはnilでよい
b2 = WS::WSImageButton.new(nil, nil, Image.load('./image/enemyshot2.png'), nil, nil, "btn2")
self.client.add_control(b1)
self.client.add_control(b2)
 
img = WS::WSImage.new(nil, nil, 100, nil)
self.client.add_control(img)
 
img.add_handler(:resize) do
img.image.dispose if img.image
img.image = Image.new(img.width, img.height, C_WHITE).circle_fill(img.width/2, img.height/2, img.width>img.height ? img.height/2 : img.width/2, C_GREEN)
end
 
client.layout(:vbox) do
self.margin_top = 10
self.margin_bottom = 10
layout(:hbox) do
add b1
add img
end
layout(:hbox) do
self.margin_left = 10
self.margin_right = 10
self.margin_top = 10
add b2
end
layout
end
end
end
 
t = Test.new
WS.desktop.add_control(t)
 
WS.desktop.add_key_handler(K_ESCAPE) do break end
 
Window.loop do
WS.update
Window.caption = Window.get_load.to_s
end 