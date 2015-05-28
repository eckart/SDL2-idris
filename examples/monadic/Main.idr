module Main

import Data.Fin
import Graphics.Color
import Graphics.SDL2.SDL
import Graphics.SDL2.SDLTTF

draw : SDLRenderer -> IO ()
draw r = do sdlSetRenderDrawColor r 255 255 255 255 -- background
            sdlRenderClear r
            filledRect r 100 100 400 400 252 141 89 255
            filledTrigon r 600 100 500 400 700 400 252 141 89 255
            font <- ttfOpenFont "/Library/Fonts/Zapfino.ttf" 70
            renderTextSolid r font "Draco dormiens nunquam titillandus" black 50 500

            renderPresent r
            ttfCloseFont font

            return ()

-- -------------------------------------------------------------------------------------------------
-- Main loop
-- -------------------------------------------------------------------------------------------------

handle : SDLRenderer -> Event -> IO ()
handle r e = draw r

main : IO ()
main = do (win,renderer) <- startSDL "test" 800 600
          draw renderer
          eventLoop renderer
          endSDL win renderer
        where 
          eventLoop : SDLRenderer -> IO ()
          eventLoop r = do 
                           e <- pollEvent
                           case e of 
                             Just AppQuit => return ()
                             Just event => do handle r event
                                              --putStrLn $ "event" ++ (show event)
                                              eventLoop r
                             _ => eventLoop r

 
