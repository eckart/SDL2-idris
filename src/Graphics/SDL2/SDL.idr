module Graphics.SDL2.SDL

import Data.Fin
import Graphics.Color
import Graphics.SDL2.Config

%access public export
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

data SDLWindow   = MkWindow Ptr

data SDLRenderer = MkRenderer Ptr

data SDLTexture = MkTexture Ptr

data SDLSurface = MkSurface Ptr

record SDLColor where
  constructor MkColor
  ptr : Ptr

record SDLRect where
  constructor MkRect
  ptr : Ptr

initSDL : IO Int
initSDL = foreign FFI_C "initSDL" (IO Int)


createWindow : String -> Int -> Int -> IO SDLWindow
createWindow title x y = 
  do ptr <- foreign FFI_C "createWindow" (String -> Int -> Int -> IO Ptr) title x y
     return (MkWindow ptr)

createRenderer : SDLWindow -> IO SDLRenderer
createRenderer (MkWindow win) = 
  do ptr <- foreign FFI_C "createRenderer" (Ptr -> IO Ptr) win
     return (MkRenderer ptr)

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
     
     
startSDL : String -> Int -> Int -> IO (SDLWindow, SDLRenderer)
startSDL title width height = do win <- createWindow title width height
                                 ren <- createRenderer win
                                 initTTF
                                 return (win, ren)

renderPresent : SDLRenderer -> IO ()
renderPresent (MkRenderer r) = foreign FFI_C "renderPresent" (Ptr -> IO()) r

renderCopy : SDLRenderer -> SDLTexture -> (src:SDLRect) -> (target:SDLRect) -> IO Int
renderCopy (MkRenderer r) (MkTexture t) (MkRect src) (MkRect target)
  = foreign FFI_C "SDL_RenderCopy" (Ptr -> Ptr -> Ptr -> Ptr -> IO Int) r t src target

quit : IO ()
quit = foreign FFI_C "SDL_Quit" (IO ())

endSDL : SDLWindow -> SDLRenderer -> IO ()
endSDL (MkWindow win) (MkRenderer ren) = do ttfQuit
                                            foreign FFI_C "quit" (Ptr -> Ptr -> IO ()) win ren

-- textures

sdlCreateTextureFromSurface : SDLRenderer -> SDLSurface -> IO SDLTexture
sdlCreateTextureFromSurface (MkRenderer r) (MkSurface s)
  = do ptr <- foreign FFI_C "SDL_CreateTextureFromSurface" (Ptr -> Ptr -> IO Ptr) r s
       return (MkTexture ptr)

sdlFreeSurface : SDLSurface -> IO ()
sdlFreeSurface (MkSurface srf) = foreign FFI_C "SDL_FreeSurface" (Ptr -> IO ()) srf

-- structs

color : Color -> IO SDLColor
color (RGBA r g b a) = do ptr <- foreign FFI_C "color" (Int -> Int -> Int -> Int -> IO Ptr) r g b a
                          return $ MkColor ptr

rect : (x:Int) -> (y:Int) -> (w:Int) -> (h:Int) -> IO SDLRect
rect x y w h = do ptr <- foreign FFI_C "rect" (Int -> Int -> Int -> Int -> IO Ptr) x y w h
                  return $ MkRect ptr
                  
-- array helper

newArray : Int -> IO (Ptr)
newArray len = foreign FFI_C "newArray" (Int -> IO (Ptr)) len

setValue : Ptr -> Int -> Int -> IO ()
setValue arr idx val = foreign FFI_C "setValue" (Ptr -> Int -> Int -> IO ()) arr idx val

packValues : Ptr -> Int -> List Int -> IO ()
packValues arr i [] = return ()
packValues arr i (x :: xs) = 
  do setValue arr i x
     packValues arr (i + 1) xs

packList : List Int -> IO (Ptr)
packList xs = do 
  let len = toIntNat $ length xs
  arr <- newArray $ len
  packValues arr 0 xs
  return arr

free : Ptr -> IO ()
free ptr = foreign FFI_C "free" (Ptr -> IO ()) ptr

-- Some drawing primitives

filledRect : SDLRenderer -> Int -> Int -> Int -> Int ->
                           Int -> Int -> Int -> Int -> IO ()
filledRect (MkRenderer ptr) x y w h r g b a 
      = foreign FFI_C "boxRGBA"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y w h r g b a

filledEllipse : SDLRenderer -> Int -> Int -> Int -> Int ->
                              Int -> Int -> Int -> Int -> IO ()
filledEllipse (MkRenderer ptr) x y rx ry r g b a 
      = foreign FFI_C "filledEllipse"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y rx ry r g b a

drawLine : SDLRenderer -> Int -> Int -> Int -> Int ->
                         Int -> Int -> Int -> Int -> IO ()
drawLine (MkRenderer ptr) x y ex ey r g b a 
      = foreign FFI_C "drawLine"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y ex ey r g b a

filledTrigon : SDLRenderer -> Int -> Int -> Int -> Int -> Int -> Int ->
                         Int -> Int -> Int -> Int -> IO ()
filledTrigon (MkRenderer ptr) x1 y1 x2 y2 x3 y3 r g b a 
      = foreign FFI_C "filledTrigon"
           (Ptr -> Int -> Int -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x1 y1 x2 y2 x3 y3 r g b a


filledPolygon : SDLRenderer -> List Int -> List Int -> 
                              Int -> Int -> Int -> Int -> IO ()
filledPolygon (MkRenderer ptr) xs ys r g b a = 
  do 
    xarr <- packList xs
    yarr <- packList ys
    let len = toIntNat $ length xs
    foreign FFI_C "filledPolygon" (Ptr -> Ptr -> Ptr -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr xarr yarr len r g b a

polygonAA : SDLRenderer -> List Int -> List Int -> 
                              Int -> Int -> Int -> Int -> IO ()
polygonAA (MkRenderer ptr) xs ys r g b a = 
  do 
    xarr <- packList xs
    yarr <- packList ys
    let len = toIntNat $ length xs
    foreign FFI_C "polygonAA" (Ptr -> Ptr -> Ptr -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr xarr yarr len r g b a

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

sdlPixel : SDLRenderer -> Int -> Int ->
                       Int -> Int -> Int -> Int -> IO ()
sdlPixel (MkRenderer ptr) x y r g b a 
  = foreign FFI_C "pixelRGBA" (Ptr -> Int -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr x y r g b a


sdlSetRenderDrawColor : SDLRenderer -> Int -> Int -> Int -> Int -> IO ()
sdlSetRenderDrawColor (MkRenderer ptr) r g b a = foreign FFI_C "SDL_SetRenderDrawColor" 
           (Ptr -> Int -> Int -> Int -> Int -> IO ()) ptr r g b a

sdlRenderClear : SDLRenderer -> IO ()
sdlRenderClear (MkRenderer ptr) = foreign FFI_C "SDL_RenderClear" (Ptr -> IO()) ptr


-- TODO: More keys still to add... careful to do the right mappings in
-- KEY in sdlrun.c

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
	 
implementation Show Key where
  show (KeyAny c) = (show c)
  show _          = "special"

implementation Eq Key where
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

data Button = Left | Middle | Right 

implementation Eq Button where
  Left   == Left   = True
  Middle == Middle = True
  Right  == Right  = True
  _      == _      = False

data Event = KeyDown Key                        -- 0
           | KeyUp Key                          -- 1
           | MouseMotion Int Int Int Int        -- 2
           | MouseButtonDown Button Int Int     -- 3
           | MouseButtonUp Button Int Int       -- 4
	   | MouseWheel Int                     -- 5
	   | Resize Int Int                     -- 6
	   | AppQuit                            -- 7
	   | WindowEvent                        -- 8


implementation Show Event where
  show (KeyDown k)               = "KeyDown " ++ (show k)
  show (KeyUp k)                 = "KeyUp " ++ (show k)
  show (MouseMotion x y dx dy)   = "MouseMotion"
  show (MouseButtonDown but x y) = "MouseButtonDown"
  show (MouseButtonUp but x y)   = "MouseButtonUp"
  show (MouseWheel y)            = "MouseWheel " ++ (show y)
  show (Resize x y)              = "Resize " ++ (show x) ++ (show y)
  show AppQuit                   = "AppQuit"
  show WindowEvent               = "WindowEvent"

implementation Eq Event where
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

pollEvent : IO (Maybe Event)
pollEvent 
    = do MkRaw e <- 
            foreign FFI_C "pollEvent" (Ptr -> IO (Raw (Maybe Event))) prim__vm
         return e

waitEvent : IO (Maybe Event)
waitEvent 
    = do MkRaw e <- 
            foreign FFI_C "waitEvent" (Ptr -> IO (Raw (Maybe Event))) prim__vm
         return e


-- ---------------------------------------------------------------------------
-- GL 

data SDLGLContext = MkGLContext Ptr

createGLContext : SDLWindow -> IO SDLGLContext
createGLContext (MkWindow ptr) = do p <- foreign FFI_C "createGLContext" (Ptr -> IO Ptr) ptr
                                    pure $ MkGLContext p
  
deleteGLContext : SDLGLContext -> IO ()
deleteGLContext (MkGLContext ptr) = foreign FFI_C "deleteGLContext" (Ptr -> IO ()) ptr                                                                  

glSetSwapInterval : Int -> IO ()
glSetSwapInterval interval = foreign FFI_C "SDL_GL_SetSwapInterval" (Int -> IO ()) interval

glSwapWindow : SDLWindow -> IO ()
glSwapWindow (MkWindow ptr) = foreign FFI_C "SDL_GL_SwapWindow" (Ptr -> IO ()) ptr

glMakeCurrent : SDLWindow -> SDLGLContext -> IO ()
glMakeCurrent (MkWindow win) (MkGLContext ctx) = foreign FFI_C "glMakeCurrent" (Ptr -> Ptr -> IO ()) win ctx


interface SDLEnum a where
  toSDLInt : a -> Int

data SDLGlAttr =
    SDL_GL_RED_SIZE
  | SDL_GL_GREEN_SIZE
  | SDL_GL_BLUE_SIZE
  | SDL_GL_ALPHA_SIZE
  | SDL_GL_BUFFER_SIZE
  | SDL_GL_DOUBLEBUFFER
  | SDL_GL_DEPTH_SIZE
  | SDL_GL_STENCIL_SIZE
  | SDL_GL_ACCUM_RED_SIZE
  | SDL_GL_ACCUM_GREEN_SIZE
  | SDL_GL_ACCUM_BLUE_SIZE
  | SDL_GL_ACCUM_ALPHA_SIZE
  | SDL_GL_STEREO
  | SDL_GL_MULTISAMPLEBUFFERS
  | SDL_GL_MULTISAMPLESAMPLES
  | SDL_GL_ACCELERATED_VISUAL
  | SDL_GL_RETAINED_BACKING
  | SDL_GL_CONTEXT_MAJOR_VERSION
  | SDL_GL_CONTEXT_MINOR_VERSION
  | SDL_GL_CONTEXT_EGL
  | SDL_GL_CONTEXT_FLAGS
  | SDL_GL_CONTEXT_PROFILE_MASK
  | SDL_GL_SHARE_WITH_CURRENT_CONTEXT
  | SDL_GL_FRAMEBUFFER_SRGB_CAPABLE

implementation SDLEnum SDLGlAttr where
   toSDLInt SDL_GL_RED_SIZE                    = 0x00000
   toSDLInt SDL_GL_GREEN_SIZE                  = 0x00001
   toSDLInt SDL_GL_BLUE_SIZE                   = 0x00002
   toSDLInt SDL_GL_ALPHA_SIZE                  = 0x00003
   toSDLInt SDL_GL_BUFFER_SIZE                 = 0x00004
   toSDLInt SDL_GL_DOUBLEBUFFER                = 0x00005
   toSDLInt SDL_GL_DEPTH_SIZE                  = 0x00006
   toSDLInt SDL_GL_STENCIL_SIZE                = 0x00007
   toSDLInt SDL_GL_ACCUM_RED_SIZE              = 0x00008
   toSDLInt SDL_GL_ACCUM_GREEN_SIZE            = 0x00009
   toSDLInt SDL_GL_ACCUM_BLUE_SIZE             = 0x00010
   toSDLInt SDL_GL_ACCUM_ALPHA_SIZE            = 0x00011
   toSDLInt SDL_GL_STEREO                      = 0x00012
   toSDLInt SDL_GL_MULTISAMPLEBUFFERS          = 0x00013
   toSDLInt SDL_GL_MULTISAMPLESAMPLES          = 0x00014
   toSDLInt SDL_GL_ACCELERATED_VISUAL          = 0x00015
   toSDLInt SDL_GL_RETAINED_BACKING            = 0x00016
   toSDLInt SDL_GL_CONTEXT_MAJOR_VERSION       = 0x00017
   toSDLInt SDL_GL_CONTEXT_MINOR_VERSION       = 0x00018
   toSDLInt SDL_GL_CONTEXT_EGL                 = 0x00019
   toSDLInt SDL_GL_CONTEXT_FLAGS               = 0x00020
   toSDLInt SDL_GL_CONTEXT_PROFILE_MASK        = 0x00021
   toSDLInt SDL_GL_SHARE_WITH_CURRENT_CONTEXT  = 0x00022
   toSDLInt SDL_GL_FRAMEBUFFER_SRGB_CAPABLE    = 0x00023
 
data SDLGlProfile =
  SDL_GL_CONTEXT_PROFILE_CORE
  | SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
  | SDL_GL_CONTEXT_PROFILE_ES

implementation SDLEnum SDLGlProfile where
  toSDLInt   SDL_GL_CONTEXT_PROFILE_CORE           = 0x0001
  toSDLInt   SDL_GL_CONTEXT_PROFILE_COMPATIBILITY  = 0x0002
  toSDLInt   SDL_GL_CONTEXT_PROFILE_ES             = 0x0004

data SDLGlContextFlag =
  SDL_GL_CONTEXT_DEBUG_FLAG
  | SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG
  | SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG
  | SDL_GL_CONTEXT_RESET_ISOLATION_FLAG

implementation SDLEnum SDLGlContextFlag where
  toSDLInt  SDL_GL_CONTEXT_DEBUG_FLAG              = 0x0001
  toSDLInt  SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = 0x0002
  toSDLInt  SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG      = 0x0004
  toSDLInt  SDL_GL_CONTEXT_RESET_ISOLATION_FLAG    = 0x0008

glSetAttribute : SDLGlAttr -> Int -> IO ()
glSetAttribute attr val = foreign FFI_C "SDL_GL_SetAttribute" (Int -> Int -> IO ()) (toSDLInt attr) val

