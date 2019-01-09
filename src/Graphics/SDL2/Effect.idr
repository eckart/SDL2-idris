module Graphics.SDL2.Effect

import Data.Fin
import Data.Vect
import Effects
import Graphics.Color
import public Graphics.SDL2.SDL
import public Graphics.SDL2.SDLGFX
import public Graphics.SDL2.SDLTTF

public export
SDLCtx : Type
SDLCtx = (SDLWindow, SDLRenderer)

public export
TTFCtx : Type
TTFCtx = SDLFont

public export
data Sdl : Effect where
     ||| creates the window + renderer. the effect has no result value, consumes no resource and
     ||| the output resource will have type SDLRenderer
     Initialise : String -> Int -> Int -> Sdl () () (\r => SDLCtx)
     ||| quit and close. No result, consumes an SDLCtx and returns no output resource 
     Quit : Sdl () SDLCtx (\v => ())
     ||| Apply the operations. No result consumes an SDLCtx and returns the SDLCtx as an output resource
     Render : Sdl () SDLCtx (\v => SDLCtx)
     ||| Event Polling. Produces a maybe event, consumes a resource and returns the same resource type
     Poll : Sdl (Maybe Event) a (\v => a)
     ||| Convert something that produces an IO Action for the Renderer to an Effect
     |||
     WithContext : (SDLCtx -> IO a) -> Sdl a SDLCtx (\v => SDLCtx)
     
public export
data Ttf : Effect where
  OpenFont   : (fontPath : String) -> (fontsize: Int) -> Ttf () () (\r => TTFCtx)
  CloseFont  : Ttf () TTFCtx (\v => ())
  WithFont   : (TTFCtx -> IO a) -> Ttf a TTFCtx (\v => TTFCtx)

public export
implementation Handler Sdl IO where
  handle ()        (Initialise title width height) k = do ctx <- startSDL title width height
                                                          k () ctx
  handle (win, ren) Quit                           k = do endSDL win ren ; k () ()
  handle (win, ren) Render                         k = do renderPresent ren; k () (win, ren)
  handle s          Poll                           k = do x <- pollEvent; k x s
  handle s          (WithContext f)                k = do r <- f s; k r s 
     
public export
SDL : Type -> EFFECT
SDL res = MkEff res Sdl

public export
TTF : Type -> EFFECT
TTF res = MkEff res Ttf

public export
SDL_ON : EFFECT
SDL_ON = SDL SDLCtx

public export
TTF_ON : EFFECT
TTF_ON = TTF TTFCtx


-- instance (Handler StdIO m, Handler System m) => Handler Logging ({
--[STDIO, SYSTEM]} Eff () m) where
--  handle ...

public export
implementation Handler Ttf IO where
  handle ()    (OpenFont font fontsize) k    = do ctx <- ttfOpenFont font fontsize
                                                  k () ctx
  handle font  CloseFont                k    = do ttfCloseFont font; k () ()
  handle font  (WithFont f)             k    = do r <- f font; k r font 

-- helper

toInt : Fin n -> Int
toInt fn = fromInteger $ finToInteger fn

-- SDL general

public export
initialise : String -> Int -> Int -> { [SDL ()] ==> [SDL_ON] } Eff () 
initialise title width height = call $ Initialise title width height

public export
quit : { [SDL_ON] ==> [SDL ()] } Eff () 
quit = call Quit

public export
render : { [SDL_ON] } Eff ()
render = call Render

public export
renderClear : Color -> { [SDL_ON] } Eff ()
renderClear (RGBA r g b a) = call $ WithContext (\(_,ren) => 
  do  sdlSetRenderDrawColor ren (toInt r) (toInt g) (toInt b) (toInt a)
      sdlRenderClear ren)

public export
poll : { [SDL_ON] } Eff (Maybe Event) 
poll = call Poll

public export
getSdlCtx : { [SDL_ON] } Eff SDLCtx
getSdlCtx = call $ WithContext pure

public export
getRenderer : { [SDL_ON] } Eff SDLRenderer
getRenderer = call $ WithContext (\(win,ren) => pure ren)

public export
pixel : Color -> (Int, Int) -> { [SDL_ON] } Eff () 
pixel (RGBA r g b a) (x,y) 
    = call $ WithContext (\(_,s) => sdlPixel s x y (toInt r) (toInt g) (toInt b) (toInt a))

public export
rectangle : Color -> Int -> Int -> Int -> Int -> { [SDL_ON] } Eff () 
rectangle (RGBA r g b a) x y w h 
    = call $ WithContext (\(_,s) => filledRectangle s x y w h (toInt r) (toInt g) (toInt b) (toInt a))

public export
ellipse : Color -> Int -> Int -> Int -> Int -> { [SDL_ON] } Eff () 
ellipse (RGBA r g b a) x y rx ry 
    = call $ WithContext (\(_,s) => filledEllipse s x y rx ry (toInt r) (toInt g) (toInt b) (toInt a))

public export
line : Color -> Int -> Int -> Int -> Int -> { [SDL_ON] } Eff () 
line (RGBA r g b a) x y ex ey 
    = call $ WithContext (\(_,s) => strokeLine s x y ex ey (toInt r) (toInt g) (toInt b) (toInt a))

public export
polygon : Color -> List (Int, Int) -> { [SDL_ON] } Eff () 
polygon (RGBA r g b a) points 
    = do 
         let xs = map fst $ fromList points
         let ys = map snd $ fromList points
         call $ WithContext (\(_,s) => filledPolygon s xs ys (toInt r) (toInt g) (toInt b) (toInt a))

public export
bezier : Color -> List (Int, Int) -> Int -> { [SDL_ON] } Eff () 
bezier (RGBA r g b a) points steps
    = do 
         let xs = map fst $ fromList points
         let ys = map snd $ fromList points
         call $ WithContext (\(_,s) => strokeBezier s xs ys steps (toInt r) (toInt g) (toInt b) (toInt a))

public export
triangle : Color -> (Int, Int) -> (Int, Int) -> (Int, Int) -> { [SDL_ON] } Eff () 
triangle (RGBA r g b a) (x1, y1) (x2, y2) (x3, y3)
    = call $ WithContext (\(_,s) => filledTrigon s x1 y1 x2 y2 x3 y3 (toInt r) (toInt g) (toInt b) (toInt a))

public export
setRenderDrawColor : Color -> { [SDL_ON] } Eff ()
setRenderDrawColor (RGBA r g b a) = call $ WithContext (\(_,ren) => sdlSetRenderDrawColor ren (toInt r) (toInt g) (toInt b) (toInt a))

-- TTF
public export
openFont : String -> Int -> { [TTF ()] ==> [TTF_ON] } Eff () 
openFont font fontsize = call $ OpenFont font fontsize

public export
closeFont : { [TTF_ON] ==> [TTF ()] } Eff () 
closeFont = call $ CloseFont 

public export
getFont : { [TTF_ON] } Eff SDLFont
getFont = call $ WithFont (\font => pure font)

public export
renderText : String -> Color -> (Int, Int) -> { [SDL_ON, TTF_ON] ==> [SDL_ON, TTF_ON] } Eff ()
renderText text col (x,y) = do r <- getRenderer
                               renderText' r text col (x,y)
                               pure ()
                            where 
                              renderText' : SDLRenderer -> String -> Color -> (Int,Int) -> { [TTF_ON] } Eff ()
                              renderText' r txt col (x,y) = call (WithFont (\font => renderTextSolid r font txt col x y))
                            
