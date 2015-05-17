module Graphics.Color

import Data.Fin

||| Type synonym for natural number up to 255
Code8 : Type
Code8 = Fin 256

data Color : Type where 
  ||| RGB encoded color with alpha channel
  ||| @ red   value of the red component
  ||| @ green value of the green component
  ||| @ blue  value of the blue component
  ||| @ alpha value of the alpha channel
  RGBA : (red : Code8) -> (green : Code8) -> (blue:Code8) -> (alpha: Code8) -> Color

white : Color
white = RGBA 255 255 255 255

black : Color
black = RGBA 0 0 0 255
