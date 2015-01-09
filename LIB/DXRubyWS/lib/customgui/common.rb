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
  
  IMG_CACHE[:icon_save] = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAMFBMVEXZz9wAAABQXXVxgJJ3h5l+j6CEl6eLn66Rp7WYr7y0srulv8rFw8vX1dzp5+0AAADS5QnIAAAAAXRSTlMAQObYZgAAAGxJREFUeJxVzEsNgDAQRdEXFFAHzJRv+iGhC8IeC1jAQi0grhZqAQsw6QrO6q4uKtYhMANmfoRpYPwtDH3CZfELm4TEtLDYCONVEIa4sF4joT/l2J+E7rA2dQeh3Z3L7U7QwftbB0LFhQJUUb+KOSwdjGi0DwAAAABJRU5ErkJggg==".unpack('m')[0])
  IMG_CACHE[:icon_open] = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAMFBMVEXZz9wAAABQXXVXZHtebIJlc4lse5Bzgpd6ip6BkaWImayPoLOWqLqdr8Gkt8jEytXj9nBsAAAAAXRSTlMAQObYZgAAAHVJREFUeJxjYIABJSUlCEP//y8FCOPduyawoO5dIGgSYGDQORMEVKakwKC9W+3///+/FRm0luq9e/fumSKD5qRcoKJLggzqQbuBIEmAQV1t1apVKxUFGFQ1Z86cOU0RaEVGR0dHkiDYLiAAGsgoCAICcEcwAAC4SSfdc/3LSAAAAABJRU5ErkJggg==".unpack('m')[0])
  IMG_CACHE[:icon_new] = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAABAAAAAPBAMAAAAfXVIcAAAAMFBMVEXEv+1fX2KBhYOWmZirrazAwsHV1tXq6ur///+AAACfCgC/FQDfIAD/KwD29fX+/v46ncQUAAAAAXRSTlMAQObYZgAAAGlJREFUeJxjYGBgYBRgAAHOmUxJYBbnTbEOR7DAzZkdTSDG3bs3+1sUoCIaRWA17SUa7UCG5MyOciclBQZG9Y6OjvISAQYhdyCjoxForAqIAdTFIOTR0dECNhoo6Qi2jEHIRQHCYBAEYgBgGh2O5objcgAAAABJRU5ErkJggg==".unpack('m')[0])
  IMG_CACHE[:icon_copy] = Image.load_from_file_in_memory("iVBORw0KGgoAAAANSUhEUgAAABAAAAAPBAMAAAAfXVIcAAAAMFBMVEW3z+QDAwMMDAwUERMhISIzMDJAREtJVXhTb9aUfo1ti+7FqL291PXX09bu7fP8/f78eLPDAAAAAXRSTlMAQObYZgAAAHFJREFUeJxjYAAC1lADEMXAlP1/C5hW3f//bwADA6NIes///1tBdNf7s3+3MgDp8/9OzJ7KIAmi2zOnMkjP+3+qPVUTyNh5qz1V0TOJQXz3jFQjJRMFBsbqnYZKSkpA88R3GoFpBsZKIzDNwCAIpaEAAKp7Ja/thJEJAAAAAElFTkSuQmCC".unpack('m')[0])
  
  
end