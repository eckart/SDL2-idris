module Graphics.SDL2.Effect

import Data.Fin
import Effects
import Graphics.Color
import public Graphics.SDL2.SDL

SDLCtx : Type
SDLCtx = (SDLWindow, SDLRenderer)

{--
Effect : Type
Effect = (result : Type) ->
         (input_resource : Type) ->
         (output_resource : result -> Type) -> Type
--}
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

{--
handle : resource -> 
         (eff : e t resource resource') ->
         ((x : t) ->        -- return value
           resource' x ->   -- return resource
           m a) 
         -> m 
--}
instance Handler Sdl IO where
     handle ()        (Initialise title width height) k = do ctx <- startSDL title width height
                                                             k () ctx
     handle (win, ren) Quit                           k = do endSDL win ren ; k () ()
     handle (win, ren) Render                         k = do renderPresent ren; k () (win, ren)
     handle s          Poll                           k = do x <- pollEvent; k x s
     handle s          (WithContext f)                k = do r <- f s; k r s 

SDL : Type -> EFFECT
SDL res = MkEff res Sdl

SDL_ON : EFFECT
SDL_ON = SDL SDLCtx

toInt : Fin n -> Int
toInt fn = fromInteger $ finToInteger fn

initialise : String -> Int -> Int -> { [SDL ()] ==> [SDL_ON] } Eff () 
initialise title width height = call $ Initialise title width height

quit : { [SDL_ON] ==> [SDL ()] } Eff () 
quit = call Quit

render : { [SDL_ON] } Eff ()
render = call Render

renderClear : Color -> { [SDL_ON] } Eff ()
renderClear (RGBA r g b a) = call $ WithContext (\(_,ren) => 
  do  sdlSetRenderDrawColor ren (toInt r) (toInt g) (toInt b) (toInt a)
      sdlRenderClear ren)

poll : { [SDL_ON] } Eff (Maybe Event) 
poll = call Poll

getRenderer : { [SDL_ON] } Eff SDLRenderer
getRenderer = call $ WithContext (\(win,ren) => return ren)

pixel : Color -> (Int, Int) -> { [SDL_ON] } Eff () 
pixel (RGBA r g b a) (x,y) 
    = call $ WithContext (\(_,s) => sdlPixel s x y (toInt r) (toInt g) (toInt b) (toInt a))

rectangle : Color -> Int -> Int -> Int -> Int -> { [SDL_ON] } Eff () 
rectangle (RGBA r g b a) x y w h 
    = call $ WithContext (\(_,s) => filledRect s x y w h (toInt r) (toInt g) (toInt b) (toInt a))

ellipse : Color -> Int -> Int -> Int -> Int -> { [SDL_ON] } Eff () 
ellipse (RGBA r g b a) x y rx ry 
    = call $ WithContext (\(_,s) => filledEllipse s x y rx ry (toInt r) (toInt g) (toInt b) (toInt a))

line : Color -> Int -> Int -> Int -> Int -> { [SDL_ON] } Eff () 
line (RGBA r g b a) x y ex ey 
    = call $ WithContext (\(_,s) => drawLine s x y ex ey (toInt r) (toInt g) (toInt b) (toInt a))

polygon : Color -> List (Int, Int) -> { [SDL_ON] } Eff () 
polygon (RGBA r g b a) points 
    = do 
         let xs = map fst points
         let ys = map snd points
         call $ WithContext (\(_,s) => filledPolygon s xs ys (toInt r) (toInt g) (toInt b) (toInt a))

bezier : Color -> List (Int, Int) -> Int -> { [SDL_ON] } Eff () 
bezier (RGBA r g b a) points steps
    = do 
         let xs = map fst points
         let ys = map snd points
         call $ WithContext (\(_,s) => sdlBezier s xs ys steps (toInt r) (toInt g) (toInt b) (toInt a))

triangle : Color -> (Int, Int) -> (Int, Int) -> (Int, Int) -> { [SDL_ON] } Eff () 
triangle (RGBA r g b a) (x1, y1) (x2, y2) (x3, y3)
    = call $ WithContext (\(_,s) => filledTrigon s x1 y1 x2 y2 x3 y3 (toInt r) (toInt g) (toInt b) (toInt a))


setRenderDrawColor : Color -> { [SDL_ON] } Eff ()
setRenderDrawColor (RGBA r g b a) = call $ WithContext (\(_,ren) => sdlSetRenderDrawColor ren (toInt r) (toInt g) (toInt b) (toInt a))
