module Graphics.SDL2.SDL

import Data.Fin
import Graphics.Color
import Graphics.SDL2.Config

%include C "sdlrun2.h"
%include C "SDL.h"
%include C "SDL2_gfxPrimitives.h"
%include C "SDL_ttf.h"
%link C "sdlrun2.o"
%lib C "SDL2_gfx"
%lib C "SDL2_ttf"

implicit finToInt : Fin n -> Int
finToInt fn = fromInteger $ finToInteger fn

public export
interface SDLEnum a where
  toSDLInt : a -> Int

public export
data SDLTextureAccess = 
  ||| Changes rarely, not lockable
  SDL_TEXTUREACCESS_STATIC |
  ||| Changes frequently, lockable
  SDL_TEXTUREACCESS_STREAMING |
  SDL_TEXTUREACCESS_TARGET

public export
implementation SDLEnum SDLTextureAccess where
  toSDLInt SDL_TEXTUREACCESS_STATIC    = 0
  toSDLInt SDL_TEXTUREACCESS_STREAMING = 1
  toSDLInt SDL_TEXTUREACCESS_TARGET    = 2

public export
data SDLPixelFormat = 
    SDL_PIXELFORMAT_UNKNOWN
    | SDL_PIXELFORMAT_INDEX1LSB 
    | SDL_PIXELFORMAT_INDEX1MSB
    | SDL_PIXELFORMAT_INDEX4LSB
    | SDL_PIXELFORMAT_INDEX4MSB
    | SDL_PIXELFORMAT_INDEX8
    | SDL_PIXELFORMAT_RGB332
    | SDL_PIXELFORMAT_RGB444
    | SDL_PIXELFORMAT_RGB555
    | SDL_PIXELFORMAT_BGR555
    | SDL_PIXELFORMAT_ARGB4444
    | SDL_PIXELFORMAT_RGBA4444
    | SDL_PIXELFORMAT_ABGR4444
    | SDL_PIXELFORMAT_BGRA4444
    | SDL_PIXELFORMAT_ARGB1555
    | SDL_PIXELFORMAT_RGBA5551
    | SDL_PIXELFORMAT_ABGR1555
    | SDL_PIXELFORMAT_BGRA5551
    | SDL_PIXELFORMAT_RGB565
    | SDL_PIXELFORMAT_BGR565
    | SDL_PIXELFORMAT_RGB24
    | SDL_PIXELFORMAT_BGR24
    | SDL_PIXELFORMAT_RGB888
    | SDL_PIXELFORMAT_RGBX8888
    | SDL_PIXELFORMAT_BGR888
    | SDL_PIXELFORMAT_BGRX8888
    | SDL_PIXELFORMAT_ARGB8888
    | SDL_PIXELFORMAT_RGBA8888
    | SDL_PIXELFORMAT_ABGR8888
    | SDL_PIXELFORMAT_BGRA8888

public export
implementation SDLEnum SDLPixelFormat where
  toSDLInt SDL_PIXELFORMAT_UNKNOWN   = 0
  toSDLInt SDL_PIXELFORMAT_INDEX1LSB = 1 
  toSDLInt SDL_PIXELFORMAT_INDEX1MSB = 2
  toSDLInt SDL_PIXELFORMAT_INDEX4LSB = 3
  toSDLInt SDL_PIXELFORMAT_INDEX4MSB = 4
  toSDLInt SDL_PIXELFORMAT_INDEX8    = 5
  toSDLInt SDL_PIXELFORMAT_RGB332    = 6
  toSDLInt SDL_PIXELFORMAT_RGB444    = 7
  toSDLInt SDL_PIXELFORMAT_RGB555    = 8
  toSDLInt SDL_PIXELFORMAT_BGR555    = 9
  toSDLInt SDL_PIXELFORMAT_ARGB4444  = 10
  toSDLInt SDL_PIXELFORMAT_RGBA4444  = 11
  toSDLInt SDL_PIXELFORMAT_ABGR4444  = 12
  toSDLInt SDL_PIXELFORMAT_BGRA4444  = 13
  toSDLInt SDL_PIXELFORMAT_ARGB1555  = 14
  toSDLInt SDL_PIXELFORMAT_RGBA5551  = 15
  toSDLInt SDL_PIXELFORMAT_ABGR1555  = 16
  toSDLInt SDL_PIXELFORMAT_BGRA5551  = 17
  toSDLInt SDL_PIXELFORMAT_RGB565    = 18
  toSDLInt SDL_PIXELFORMAT_BGR565    = 19
  toSDLInt SDL_PIXELFORMAT_RGB24     = 20
  toSDLInt SDL_PIXELFORMAT_BGR24     = 21
  toSDLInt SDL_PIXELFORMAT_RGB888    = 22
  toSDLInt SDL_PIXELFORMAT_RGBX8888  = 23
  toSDLInt SDL_PIXELFORMAT_BGR888    = 24
  toSDLInt SDL_PIXELFORMAT_BGRX8888  = 25
  toSDLInt SDL_PIXELFORMAT_ARGB8888  = 26
  toSDLInt SDL_PIXELFORMAT_RGBA8888  = 27
  toSDLInt SDL_PIXELFORMAT_ABGR8888  = 28
  toSDLInt SDL_PIXELFORMAT_BGRA8888  = 29

-- Set up a window

export
data SDLWindow   = MkWindow Ptr

public export
data SDLRenderer = MkRenderer Ptr

public export
data SDLTexture = MkTexture Ptr

public export
data SDLSurface = MkSurface Ptr

public export
record SDLColor where
  constructor MkColor
  ptr : Ptr

export
record SDLRect where
  constructor MkRect
  ptr : Ptr

export 
initSDL : IO Int
initSDL = foreign FFI_C "initSDL" (IO Int)


export
createWindow : String -> Int -> Int -> IO SDLWindow
createWindow title x y = 
  do ptr <- foreign FFI_C "createWindow" (String -> Int -> Int -> IO Ptr) title x y
     pure (MkWindow ptr)

export
createRenderer : SDLWindow -> IO SDLRenderer
createRenderer (MkWindow win) = 
  do ptr <- foreign FFI_C "createRenderer" (Ptr -> IO Ptr) win
     pure (MkRenderer ptr)

export
ttfGetError : IO String
ttfGetError = foreign FFI_C "TTF_GetError" (IO String)

initTTF : IO ()
initTTF = do ret <- foreign FFI_C "TTF_Init" (IO (Int))
             if ret < 0 
             then do msg <- ttfGetError
                     putStrLn msg
             else pure () 

ttfQuit : IO ()
ttfQuit = foreign FFI_C "TTF_Quit" (IO ())  
     
     
export 
startSDL : String -> Int -> Int -> IO (SDLWindow, SDLRenderer)
startSDL title width height = do win <- createWindow title width height
                                 ren <- createRenderer win
                                 initTTF
                                 pure (win, ren)

export
renderPresent : SDLRenderer -> IO ()
renderPresent (MkRenderer r) = foreign FFI_C "renderPresent" (Ptr -> IO()) r

export
renderCopy : SDLRenderer -> SDLTexture -> (src:SDLRect) -> (target:SDLRect) -> IO Int
renderCopy (MkRenderer r) (MkTexture t) (MkRect src) (MkRect target)
  = foreign FFI_C "SDL_RenderCopy" (Ptr -> Ptr -> Ptr -> Ptr -> IO Int) r t src target

export
renderCopyFull : SDLRenderer -> SDLTexture -> IO Int
renderCopyFull (MkRenderer r) (MkTexture t) 
  = foreign FFI_C "SDL_RenderCopy" (Ptr -> Ptr -> Ptr -> Ptr -> IO Int) r t prim__null prim__null

export
quit : IO ()
quit = foreign FFI_C "SDL_Quit" (IO ())

export
endSDL : SDLWindow -> SDLRenderer -> IO ()
endSDL (MkWindow win) (MkRenderer ren) = do ttfQuit
                                            foreign FFI_C "quit" (Ptr -> Ptr -> IO ()) win ren

-- textures

export
sdlCreateTextureFromSurface : SDLRenderer -> SDLSurface -> IO SDLTexture
sdlCreateTextureFromSurface (MkRenderer r) (MkSurface s)
  = do ptr <- foreign FFI_C "SDL_CreateTextureFromSurface" (Ptr -> Ptr -> IO Ptr) r s
       pure (MkTexture ptr)

export
sdlCreateTexture : SDLRenderer -> (format : SDLPixelFormat) -> (access : SDLTextureAccess) -> (width: Int) -> (height: Int) -> IO SDLTexture
sdlCreateTexture (MkRenderer r) format access width height
  = do f <-foreign FFI_C "idr_get_pixel_format" (Int -> IO Int) (toSDLInt format)
       ptr <- foreign FFI_C "SDL_CreateTexture" (Ptr -> Int -> Int -> Int -> Int -> IO Ptr) r f (toSDLInt access) width height
       pure (MkTexture ptr)


export
sdlFreeSurface : SDLSurface -> IO ()
sdlFreeSurface (MkSurface srf) = foreign FFI_C "SDL_FreeSurface" (Ptr -> IO ()) srf

-- structs

export
color : Color -> IO SDLColor
color (RGBA r g b a) = do ptr <- foreign FFI_C "color" (Int -> Int -> Int -> Int -> IO Ptr) r g b a
                          pure $ MkColor ptr

export 
rect : (x:Int) -> (y:Int) -> (w:Int) -> (h:Int) -> IO SDLRect
rect x y w h = do ptr <- foreign FFI_C "rect" (Int -> Int -> Int -> Int -> IO Ptr) x y w h
                  pure $ MkRect ptr
                  
-- array helper

private 
newArray : Int -> IO (Ptr)
newArray len = foreign FFI_C "newArray" (Int -> IO (Ptr)) len

private 
setValue : Ptr -> Int -> Int -> IO ()
setValue arr idx val = foreign FFI_C "setValue" (Ptr -> Int -> Int -> IO ()) arr idx val

private 
packValues : Ptr -> Int -> List Int -> IO ()
packValues arr i [] = pure ()
packValues arr i (x :: xs) = 
  do setValue arr i x
     packValues arr (i + 1) xs

private 
packList : List Int -> IO (Ptr)
packList xs = do 
  let len = toIntNat $ length xs
  arr <- newArray $ len
  packValues arr 0 xs
  pure arr

export 
free : Ptr -> IO ()
free ptr = foreign FFI_C "free" (Ptr -> IO ()) ptr

-- Some drawing primitives

export
filledRect : SDLRenderer -> Int -> Int -> Int -> Int ->
                           Int -> Int -> Int -> Int -> IO ()
filledRect (MkRenderer ptr) x y w h r g b a 
      = foreign FFI_C "boxRGBA"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y w h r g b a

export
filledEllipse : SDLRenderer -> Int -> Int -> Int -> Int ->
                              Int -> Int -> Int -> Int -> IO ()
filledEllipse (MkRenderer ptr) x y rx ry r g b a 
      = foreign FFI_C "filledEllipse"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y rx ry r g b a

export
drawLine : SDLRenderer -> Int -> Int -> Int -> Int ->
                         Int -> Int -> Int -> Int -> IO ()
drawLine (MkRenderer ptr) x y ex ey r g b a 
      = foreign FFI_C "drawLine"
           (Ptr -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x y ex ey r g b a

export
filledTrigon : SDLRenderer -> Int -> Int -> Int -> Int -> Int -> Int ->
                         Int -> Int -> Int -> Int -> IO ()
filledTrigon (MkRenderer ptr) x1 y1 x2 y2 x3 y3 r g b a 
      = foreign FFI_C "filledTrigon"
           (Ptr -> Int -> Int -> Int -> Int -> Int -> Int ->
            Int -> Int -> Int -> Int -> IO ()) ptr x1 y1 x2 y2 x3 y3 r g b a


export
filledPolygon : SDLRenderer -> List Int -> List Int -> 
                              Int -> Int -> Int -> Int -> IO ()
filledPolygon (MkRenderer ptr) xs ys r g b a = 
  do 
    xarr <- packList xs
    yarr <- packList ys
    let len = toIntNat $ length xs
    foreign FFI_C "filledPolygon" (Ptr -> Ptr -> Ptr -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr xarr yarr len r g b a

export
polygonAA : SDLRenderer -> List Int -> List Int -> 
                              Int -> Int -> Int -> Int -> IO ()
polygonAA (MkRenderer ptr) xs ys r g b a = 
  do 
    xarr <- packList xs
    yarr <- packList ys
    let len = toIntNat $ length xs
    foreign FFI_C "polygonAA" (Ptr -> Ptr -> Ptr -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr xarr yarr len r g b a

export
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

export
sdlPixel : SDLRenderer -> Int -> Int ->
                       Int -> Int -> Int -> Int -> IO ()
sdlPixel (MkRenderer ptr) x y r g b a 
  = foreign FFI_C "pixelRGBA" (Ptr -> Int -> Int -> Int -> Int -> Int -> Int -> IO ()) ptr x y r g b a


export
sdlSetRenderDrawColor : SDLRenderer -> Int -> Int -> Int -> Int -> IO ()
sdlSetRenderDrawColor (MkRenderer ptr) r g b a = foreign FFI_C "SDL_SetRenderDrawColor" 
           (Ptr -> Int -> Int -> Int -> Int -> IO ()) ptr r g b a

export
sdlRenderClear : SDLRenderer -> IO ()
sdlRenderClear (MkRenderer ptr) = foreign FFI_C "SDL_RenderClear" (Ptr -> IO()) ptr


-- TODO: More keys still to add... careful to do the right mappings in
-- KEY in sdlrun.c

public export
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
	 
public export	 
implementation Show Key where
  show (KeyAny c) = (show c)
  show _          = "special"

public export	 
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

public export	 
data Button = Left | Middle | Right 

public export	 
implementation Eq Button where
  Left   == Left   = True
  Middle == Middle = True
  Right  == Right  = True
  _      == _      = False

public export	 
data Event = KeyDown Key                        -- 0
           | KeyUp Key                          -- 1
           | MouseMotion Int Int Int Int        -- 2
           | MouseButtonDown Button Int Int     -- 3
           | MouseButtonUp Button Int Int       -- 4
	   | MouseWheel Int                     -- 5
	   | Resize Int Int                     -- 6
	   | AppQuit                            -- 7
	   | WindowEvent                        -- 8


public export	 
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

public export	 
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

export
pollEvent : IO (Maybe Event)
pollEvent 
    = do MkRaw e <- 
         foreign FFI_C "pollEvent" (Ptr -> IO (Raw (Maybe Event))) (prim__vm prim__TheWorld)
         pure e

export
waitEvent : IO (Maybe Event)
waitEvent 
    = do MkRaw e <- 
         foreign FFI_C "waitEvent" (Ptr -> IO (Raw (Maybe Event))) (prim__vm prim__TheWorld)
         pure e


public export
data TextureRaw = MkTextureRaw Ptr Int

export
lockTexture : SDLTexture -> IO TextureRaw
lockTexture (MkTexture t) = do MkRaw tr <- foreign FFI_C "idr_lock_texture" (Ptr -> Ptr -> IO (Raw TextureRaw)) t (prim__vm prim__TheWorld)
                               pure tr

export
unlockTexture : SDLTexture -> IO ()
unlockTexture (MkTexture t) = do foreign FFI_C "SDL_UnlockTexture" (Ptr -> IO ()) t


-- ---------------------------------------------------------------------------
-- GL 

export
data SDLGLContext = MkGLContext Ptr

export
createGLContext : SDLWindow -> IO SDLGLContext
createGLContext (MkWindow ptr) = do p <- foreign FFI_C "createGLContext" (Ptr -> IO Ptr) ptr
                                    pure $ MkGLContext p
  
export
deleteGLContext : SDLGLContext -> IO ()
deleteGLContext (MkGLContext ptr) = foreign FFI_C "deleteGLContext" (Ptr -> IO ()) ptr                                                                  

export
glSetSwapInterval : Int -> IO ()
glSetSwapInterval interval = foreign FFI_C "SDL_GL_SetSwapInterval" (Int -> IO ()) interval

export
glSwapWindow : SDLWindow -> IO ()
glSwapWindow (MkWindow ptr) = foreign FFI_C "SDL_GL_SwapWindow" (Ptr -> IO ()) ptr

export
glMakeCurrent : SDLWindow -> SDLGLContext -> IO ()
glMakeCurrent (MkWindow win) (MkGLContext ctx) = foreign FFI_C "glMakeCurrent" (Ptr -> Ptr -> IO ()) win ctx


public export                                                             
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

public export
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
 
public export
data SDLGlProfile =
  SDL_GL_CONTEXT_PROFILE_CORE
  | SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
  | SDL_GL_CONTEXT_PROFILE_ES

public export
implementation SDLEnum SDLGlProfile where
  toSDLInt   SDL_GL_CONTEXT_PROFILE_CORE           = 0x0001
  toSDLInt   SDL_GL_CONTEXT_PROFILE_COMPATIBILITY  = 0x0002
  toSDLInt   SDL_GL_CONTEXT_PROFILE_ES             = 0x0004

public export                                                                    
data SDLGlContextFlag =
  SDL_GL_CONTEXT_DEBUG_FLAG
  | SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG
  | SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG
  | SDL_GL_CONTEXT_RESET_ISOLATION_FLAG

public export
implementation SDLEnum SDLGlContextFlag where
  toSDLInt  SDL_GL_CONTEXT_DEBUG_FLAG              = 0x0001
  toSDLInt  SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = 0x0002
  toSDLInt  SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG      = 0x0004
  toSDLInt  SDL_GL_CONTEXT_RESET_ISOLATION_FLAG    = 0x0008

export
glSetAttribute : SDLGlAttr -> Int -> IO ()
glSetAttribute attr val = foreign FFI_C "SDL_GL_SetAttribute" (Int -> Int -> IO ()) (toSDLInt attr) val

