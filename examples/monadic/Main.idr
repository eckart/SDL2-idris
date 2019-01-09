module Main

import Data.Fin
import Data.Vect
import Graphics.Color
import Graphics.SDL2.SDL
import Graphics.SDL2.SDLGFX
import Graphics.SDL2.SDLTTF

draw : SDLRenderer -> IO ()
draw r = do sdlSetRenderDrawColor r 255 255 255 255 -- background
            sdlRenderClear r
            sdlPixel r 10 10 0 0 0 255
            strokeHLine r 10 20 20 0 0 0 255
            strokeVLine r 20 10 20 0 0 0 255
            strokeRectangle r 10 30 20 40 0 0 0 255
            filledRectangle r 10 50 20 60 0 0 0 255
            strokeRoundedRectangle r 10 70 30 90 6 0 0 0 255
            filledRoundedRectangle r 10 100 30 120 6 0 0 0 255
            strokeLine   r 30 10 40 60 0 0 0 255
            strokeAALine r 33 10 43 60 0 0 0 255
            strokeCircle   r 60 20 10 0 0 0 255
            filledCircle   r 90 20 10 0 0 0 255
            strokeAACircle r 120 20 10 0 0 0 255
            strokeEllipse   r 60 50 10 15 255 0 0 255
            filledEllipse   r 90 50 10 15 0 255 0 255
            strokeAAEllipse r 120 50 10 15 0 0 255 255
            filledPie r 130 20 20 (-45) 45 0 0 0 255
            strokeArc r 140 20 20 (-45) 45 0 0 0 255
            strokePie r 140 50 20 (-45) 45 0 0 0 255
            strokeTrigon   r 40 70 60 70 50 90 0 0 0 255
            filledTrigon   r 70 70 90 70 80 90 0 0 0 255
            strokeAATrigon r 100 70 120 70 110 90 0 0 0 255
            strokePolygon   r [10,20,40,30] [130,150,160,140] 0 0 0 255
            filledPolygon   r [35,45,65,55] [130,150,160,140] 0 0 0 255
            strokeAAPolygon r [60,70,90,80] [130,150,160,140] 0 0 0 255
            strokeBezier r [40, 50, 60, 70] [100, 160, 70, 130] 6 0 0 0 255
            strokeThickLine r 80 100 180 130 5 0 0 0 255
            font <- ttfOpenFont "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf" 20
            renderTextSolid r font "Example text" black 10 165

            renderPresent r
            ttfCloseFont font

            pure ()

-- -------------------------------------------------------------------------------------------------
-- Main loop
-- -------------------------------------------------------------------------------------------------

handle : SDLRenderer -> Event -> IO ()
handle r e = draw r

main : IO ()
main = do (win,renderer) <- startSDL "test" 200 200
          draw renderer
          eventLoop renderer
          endSDL win renderer
        where 
          eventLoop : SDLRenderer -> IO ()
          eventLoop r = do 
                           e <- pollEvent
                           case e of 
                             Just AppQuit => pure ()
                             Just event => do handle r event
                                              --putStrLn $ "event" ++ (show event)
                                              eventLoop r
                             _ => eventLoop r

 
