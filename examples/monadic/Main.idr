module Main

import Graphics.SDL2.SDL

draw : SDLRenderer -> IO ()
draw r = do filledRect r 0 0 800 600 255 255 255 255 -- background
            filledRect r 100 100 400 400 252 141 89 255
            renderPresent r
            return ()

-- -------------------------------------------------------------------------------------------------
-- Main loop
-- -------------------------------------------------------------------------------------------------

handle : SDLRenderer -> Event -> IO ()
handle r e = draw r

main : IO ()
main = do win <- createWindow "test" 800 600
          renderer <- createRenderer win
          draw renderer
          eventLoop renderer
          quit
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

 
