module Graphics.SDL2.SDL

import Data.Fin
import Graphics.Color
import Graphics.SDL2.Config

%include C "sdlrun2.h"
%include C "SDL2/SDL.h"
%include C "SDL2/SDL2_gfxPrimitives.h"
%include C "SDL2/SDL_ttf.h"
%link C "sdlrun2.o"
%lib C "SDL2_gfx"
%lib C "SDL2_ttf"

implicit finToInt : Fin n -> Int
finToInt fn = fromInteger $ finToInteger fn


-- Set up a window

abstract 
data SDLWindow   = MkWindow Ptr

public
data SDLRenderer = MkRenderer Ptr

public
data SDLTexture = MkTexture Ptr

public
data SDLSurface = MkSurface Ptr

public
record SDLColor where
  constructor MkColor
  ptr : Ptr

abstract 
record SDLRect where
  constructor MkRect
  ptr : Ptr

public
createWindow : String -> Int -> Int -> IO SDLWindow
createWindow title x y = 
  do ptr <- foreign FFI_C "createWindow" (String -> Int -> Int -> IO Ptr) title x y
     return (MkWindow ptr)

public
createRenderer : SDLWindow -> IO SDLRenderer
createRenderer (MkWindow win) = 
  do ptr <- foreign FFI_C "createRenderer" (Ptr -> IO Ptr) win
     return (MkRenderer ptr)

public
ttfGetError : IO String
ttfGetError = foreign FFI_C "TTF_GetError" (IO String)

initTTF : IO ()
initTTF = do ret <- foreign FFI_C "TTF_Init" (IO (Int))
             if ret < 0 
             then do msg <- ttfGetError
                     putStrLn msg
             else return () 

ttfQuit : IO ()
ttfQuit = foreign FFI_C "TTF_Quit" (IO ())  
     
     
public 
startSDL : String -> Int -> Int -> IO (SDLWindow, SDLRenderer)
startSDL title width height = do win <- createWindow title width height
                                 ren <- createRenderer win
                                 initTTF
                                 return (win, ren)

public
renderPresent : SDLRenderer -> IO ()
renderPresent (MkRenderer r) = foreign FFI_C "renderPresent" (Ptr -> IO()) r

public
renderCopy : SDLRenderer -> SDLTexture -> (src:SDLRect) -> (target:SDLRect) -> IO Int
renderCopy (MkRenderer r) (MkTexture t) (MkRect src) (MkRect target)
  = foreign FFI_C "SDL_RenderCopy" (Ptr -> Ptr -> Ptr -> Ptr -> IO Int) r t src target

public
quit : IO ()
quit = foreign FFI_C "SDL_Quit" (IO ())

public
endSDL : SDLWindow -> SDLRenderer -> IO ()
endSDL (MkWindow win) (MkRenderer ren) = do ttfQuit
                                            foreign FFI_C "quit" (Ptr -> Ptr -> IO ()) win ren

-- textures

public
sdlCreateTextureFromSurface : SDLRenderer -> SDLSurface -> IO SDLTexture
sdlCreateTextureFromSurface (MkRenderer r) (MkSurface s)
  = do ptr <- foreign FFI_C "SDL_CreateTextureFromSurface" (Ptr -> Ptr -> IO Ptr) r s
       return (MkTexture ptr)

public
sdlFreeSurface : SDLSurface -> IO ()
sdlFreeSurface (MkSurface srf) = foreign FFI_C "SDL_FreeSurface" (Ptr -> IO ()) srf

-- structs

public
color : Color -> IO SDLColor
color (RGBA r g b a) = do ptr <- foreign FFI_C "color" (Int -> Int -> Int -> Int -> IO Ptr) r g b a
                          return $ MkColor ptr

public 
rect : (x:Int) -> (y:Int) -> (w:Int) -> (h:Int) -> IO SDLRect
rect x y w h = do ptr <- foreign FFI_C "rect" (Int -> Int -> Int -> Int -> IO Ptr) x y w h
                  return $ MkRect ptr
                  
-- array helper

private 
newArray : Int -> IO (Ptr)
newArray len = foreign FFI_C "newArray" (Int -> IO (Ptr)) len

private 
setValue : Ptr -> Int -> Int -> IO ()
setValue arr idx val = foreign FFI_C "setValue" (Ptr -> Int -> Int -> IO ()) arr idx val

private 
packValues : Ptr -> Int -> List Int -> IO ()
packValues arr i [] = return ()
packValues arr i (x :: xs) = 
  do setValue arr i x
     packValues arr (i + 1) xs

private 
packList : List Int -> IO (Ptr)
packList xs = do 
  let len = toIntNat $ length xs
  arr <- newArray $ len
  packValues arr 0 xs
  return arr

public 
free : Ptr -> IO ()
free ptr = foreign FFI_C "free" (Ptr -> IO ()) ptr

-- Some drawing primitives

public
filledRect : SDLRenderer -> Int -> Int -> Int -> Int ->
                           Int -> Int -> Int -> Int -> IO ()
filledRect (MkRenderer ptr) x y w h r g b a 
      = foreign FFI_C "boxRGBA"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y w h r g b a

public
filledEllipse : SDLRenderer -> Int -> Int -> Int -> Int ->
                              Int -> Int -> Int -> Int -> IO ()
filledEllipse (MkRenderer ptr) x y rx ry r g b a 
      = foreign FFI_C "filledEllipse"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y rx ry r g b a

public
drawLine : SDLRenderer -> Int -> Int -> Int -> Int ->
                         Int -> Int -> Int -> Int -> IO ()
drawLine (MkRenderer ptr) x y ex ey r g b a 
      = foreign FFI_C "drawLine"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y ex ey r g b a

public
filledTrigon : SDLRenderer -> Int -> Int -> Int -> Int -> Int -> Int ->
                         Int -> Int -> Int -> Int -> IO ()
filledTrigon (MkRenderer ptr) x1 y1 x2 y2 x3 y3 r g b a 
      = foreign FFI_C "filledTrigon"
           (Ptr -> Int -> Int -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x1 y1 x2 y2 x3 y3 r g b a


public
filledPolygon : SDLRenderer -> List Int -> List Int -> 
                              Int -> Int -> Int -> Int -> IO ()
filledPolygon (MkRenderer ptr) xs ys r g b a = 
  do 
    xarr <- packList xs
    yarr <- packList ys
    let len = toIntNat $ length xs
    foreign FFI_C "filledPolygon" (Ptr -> Ptr -> Ptr -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr xarr yarr len r g b a

public
polygonAA : SDLRenderer -> List Int -> List Int -> 
                              Int -> Int -> Int -> Int -> IO ()
polygonAA (MkRenderer ptr) xs ys r g b a = 
  do 
    xarr <- packList xs
    yarr <- packList ys
    let len = toIntNat $ length xs
    foreign FFI_C "polygonAA" (Ptr -> Ptr -> Ptr -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr xarr yarr len r g b a

public
sdlBezier : SDLRenderer -> List Int -> List Int -> 
                              Int -> 
                              Int -> Int -> Int -> Int -> IO ()
sdlBezier (MkRenderer ptr) xs ys steps r g b a = 
  do 
    xarr <- packList xs
    yarr <- packList ys
    let len = toIntNat $ length xs
    foreign FFI_C "bezier" (Ptr -> Ptr -> Ptr -> Int -> Int -> Int -> Int -> Int -> Int -> IO ()) 
                                   ptr xarr yarr len steps r g b a

public 
sdlPixel : SDLRenderer -> Int -> Int ->
                       Int -> Int -> Int -> Int -> IO ()
sdlPixel (MkRenderer ptr) x y r g b a 
  = foreign FFI_C "pixelRGBA" (Ptr -> Int -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr x y r g b a


public
sdlSetRenderDrawColor : SDLRenderer -> Int -> Int -> Int -> Int -> IO ()
sdlSetRenderDrawColor (MkRenderer ptr) r g b a = foreign FFI_C "SDL_SetRenderDrawColor" 
           (Ptr -> Int -> Int -> Int -> Int -> IO ()) ptr r g b a

public
sdlRenderClear : SDLRenderer -> IO ()
sdlRenderClear (MkRenderer ptr) = foreign FFI_C "SDL_RenderClear" (Ptr -> IO()) ptr


-- TODO: More keys still to add... careful to do the right mappings in
-- KEY in sdlrun.c

public
data Key = KeyUpArrow
         | KeyDownArrow
	 | KeyLeftArrow
	 | KeyRightArrow
         | KeyEsc
         | KeySpace
         | KeyTab
         | KeyF1
         | KeyF2
         | KeyF3
         | KeyF4
         | KeyF5
         | KeyF6
         | KeyF7
         | KeyF8
         | KeyF9
         | KeyF10
         | KeyF11
         | KeyF12
         | KeyF13
         | KeyF14
         | KeyF15
         | KeyLShift
         | KeyRShift
         | KeyLCtrl
         | KeyRCtrl
	 | KeyAny Char
	 
instance Show Key where
  show (KeyAny c) = (show c)
  show _          = "special"

instance Eq Key where
  KeyUpArrow    == KeyUpArrow     = True
  KeyDownArrow  == KeyDownArrow   = True
  KeyLeftArrow  == KeyLeftArrow   = True
  KeyRightArrow == KeyRightArrow  = True

  KeyEsc   == KeyEsc   = True
  KeyTab   == KeyTab   = True
  KeySpace == KeySpace = True

  KeyF1    == KeyF1    = True
  KeyF2    == KeyF2    = True
  KeyF3    == KeyF3    = True
  KeyF4    == KeyF4    = True
  KeyF5    == KeyF5    = True
  KeyF6    == KeyF6    = True
  KeyF7    == KeyF7    = True
  KeyF8    == KeyF8    = True
  KeyF9    == KeyF9    = True
  KeyF10   == KeyF10   = True
  KeyF11   == KeyF11   = True
  KeyF12   == KeyF12   = True
  KeyF13   == KeyF13   = True
  KeyF14   == KeyF14   = True
  KeyF15   == KeyF15   = True

  KeyLShift == KeyLShift = True
  KeyRShift == KeyRShift = True
  KeyLCtrl  == KeyLCtrl  = True
  KeyRCtrl  == KeyRCtrl  = True

  (KeyAny x)    == (KeyAny y)     = x == y
  _             == _              = False

public
data Button = Left | Middle | Right 

instance Eq Button where
  Left   == Left   = True
  Middle == Middle = True
  Right  == Right  = True
  _      == _      = False

public
data Event = KeyDown Key                        -- 0
           | KeyUp Key                          -- 1
           | MouseMotion Int Int Int Int        -- 2
           | MouseButtonDown Button Int Int     -- 3
           | MouseButtonUp Button Int Int       -- 4
	   | MouseWheel Int                     -- 5
	   | Resize Int Int                     -- 6
	   | AppQuit                            -- 7
	   | WindowEvent                        -- 8


instance Show Event where
  show (KeyDown k)               = "KeyDown " ++ (show k)
  show (KeyUp k)                 = "KeyUp " ++ (show k)
  show (MouseMotion x y dx dy)   = "MouseMotion"
  show (MouseButtonDown but x y) = "MouseButtonDown"
  show (MouseButtonUp but x y)   = "MouseButtonUp"
  show (MouseWheel y)            = "MouseWheel " ++ (show y)
  show (Resize x y)              = "Resize " ++ (show x) ++ (show y)
  show AppQuit                   = "AppQuit"
  show WindowEvent               = "WindowEvent"

instance Eq Event where
  (KeyDown x) == (KeyDown y) = x == y
  (KeyUp x)   == (KeyUp y)   = x == y
  (MouseMotion x y rx ry) == (MouseMotion x' y' rx' ry')
      = x == x' && y == y' && rx == rx' && ry == ry'
  (MouseButtonDown b x y) == (MouseButtonDown b' x' y')
      = b == b' && x == x' && y == y'
  (MouseButtonUp b x y) == (MouseButtonUp b' x' y')
      = b == b' && x == x' && y == y'
  (MouseWheel y) == (MouseWheel y') = y == y'
  (Resize x y)   == (Resize x' y')  = x == x' && y == y'
  AppQuit        == AppQuit         = True
  WindowEvent    == WindowEvent     = True
  _              == _               = False

public
pollEvent : IO (Maybe Event)
pollEvent 
    = do MkRaw e <- 
            foreign FFI_C "pollEvent" (Ptr -> IO (Raw (Maybe Event))) prim__vm
         return e

public
waitEvent : IO (Maybe Event)
waitEvent 
    = do MkRaw e <- 
            foreign FFI_C "waitEvent" (Ptr -> IO (Raw (Maybe Event))) prim__vm
         return e


-- ---------------------------------------------------------------------------
-- GL 

abstract
data SDLGLContext = MkGLContext Ptr

createGLContext : SDLWindow -> IO SDLGLContext
createGLContext (MkWindow ptr) = do p <- foreign FFI_C "createGLContext" (Ptr -> IO Ptr) ptr
                                    pure $ MkGLContext p
  
deleteGLContext : SDLGLContext -> IO ()
deleteGLContext (MkGLContext ptr) = foreign FFI_C "deleteGLContext" (Ptr -> IO ()) ptr                                                                  
glSwapWindow : SDLWindow -> IO ()
glSwapWindow (MkWindow ptr) = foreign FFI_C "SDL_GL_SwapWindow" (Ptr -> IO ()) ptr

glMakeCurrent : SDLWindow -> SDLGLContext -> IO ()
glMakeCurrent (MkWindow win) (MkGLContext ctx) = foreign FFI_C "glMakeCurrent" (Ptr -> Ptr -> IO ()) win ctx

                                  
