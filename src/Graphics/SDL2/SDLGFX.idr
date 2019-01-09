module SDLGFX

import Data.Vect
import Graphics.SDL2.SDL

%include C "sdlrun2.h"
%include C "SDL.h"
%include C "SDL2_gfxPrimitives.h"
%include C "SDL_ttf.h"
%link C "sdlrun2.o"
%lib C "SDL2_gfx"
%lib C "SDL2_ttf"

%access export

private 
newArray : Int -> IO (Ptr)
newArray len = foreign FFI_C "newArray" (Int -> IO (Ptr)) len

private 
setValue : Ptr -> Int -> Int -> IO ()
setValue arr idx val = foreign FFI_C "setValue" (Ptr -> Int -> Int -> IO ()) arr idx val

private 
packValues : Ptr -> Int -> Vect n Int -> IO ()
packValues arr i [] = pure ()
packValues arr i (x :: xs) = 
  do setValue arr i x
     packValues arr (i + 1) xs

private 
packVect : {n:Nat} -> Vect n Int -> IO (Ptr)
packVect {n} xs = do 
  let len = toIntNat n
  arr <- newArray $ len
  packValues arr 0 xs
  pure arr

public export
IntAndColorParams : Nat -> Type
IntAndColorParams Z = Int -> Int -> Int -> Int -> IO ()
IntAndColorParams (S n) = Int -> IntAndColorParams n

sdlPixel : SDLRenderer -> IntAndColorParams 2
sdlPixel (MkRenderer ptr) x y r g b a
  = foreign FFI_C "pixelRGBA" (Ptr -> IntAndColorParams 2) ptr x y r g b a

strokeHLine : SDLRenderer -> IntAndColorParams 3
strokeHLine (MkRenderer ptr) x1 x2 y r g b a
  = foreign FFI_C "hlineRGBA" (Ptr -> IntAndColorParams 3) ptr x1 x2 y r g b a

strokeVLine : SDLRenderer -> IntAndColorParams 3
strokeVLine (MkRenderer ptr) x y1 y2 r g b a
  = foreign FFI_C "vlineRGBA" (Ptr -> IntAndColorParams 3) ptr x y1 y2 r g b a

strokeRectangle : SDLRenderer -> IntAndColorParams 4
strokeRectangle (MkRenderer ptr) x1 y1 x2 y2 r g b a
  = foreign FFI_C "rectangleRGBA" (Ptr -> IntAndColorParams 4) ptr x1 y1 x2 y2 r g b a

filledRectangle : SDLRenderer -> IntAndColorParams 4
filledRectangle (MkRenderer ptr) x1 y1 x2 y2 r g b a
  = foreign FFI_C "boxRGBA" (Ptr -> IntAndColorParams 4) ptr x1 y1 x2 y2 r g b a

strokeRoundedRectangle : SDLRenderer -> IntAndColorParams 5
strokeRoundedRectangle (MkRenderer ptr) x1 y1 x2 y2 rad r g b a
  = foreign FFI_C "roundedRectangleRGBA" (Ptr -> IntAndColorParams 5) ptr x1 y1 x2 y2 rad r g b a

filledRoundedRectangle : SDLRenderer -> IntAndColorParams 5
filledRoundedRectangle (MkRenderer ptr) x1 y1 x2 y2 rad r g b a
  = foreign FFI_C "roundedBoxRGBA" (Ptr -> IntAndColorParams 5) ptr x1 y1 x2 y2 rad r g b a

strokeLine : SDLRenderer -> IntAndColorParams 4
strokeLine (MkRenderer ptr) x1 y1 x2 y2 r g b a
      = foreign FFI_C "lineRGBA"
           (Ptr -> IntAndColorParams 4) ptr x1 y1 x2 y2 r g b a

strokeAALine : SDLRenderer -> IntAndColorParams 4
strokeAALine (MkRenderer ptr) x1 y1 x2 y2 r g b a
      = foreign FFI_C "aalineRGBA"
           (Ptr -> IntAndColorParams 4) ptr x1 y1 x2 y2 r g b a

strokeCircle : SDLRenderer -> IntAndColorParams 3
strokeCircle (MkRenderer ptr) x y rad r g b a
      = foreign FFI_C "circleRGBA"
           (Ptr -> IntAndColorParams 3) ptr x y rad r g b a

filledCircle : SDLRenderer -> IntAndColorParams 3
filledCircle (MkRenderer ptr) x y rad r g b a
      = foreign FFI_C "filledCircleRGBA"
           (Ptr -> IntAndColorParams 3) ptr x y rad r g b a

strokeAACircle : SDLRenderer -> IntAndColorParams 3
strokeAACircle (MkRenderer ptr) x y rad r g b a
      = foreign FFI_C "aacircleRGBA"
           (Ptr -> IntAndColorParams 3) ptr x y rad r g b a

strokeArc : SDLRenderer -> IntAndColorParams 5
strokeArc (MkRenderer ptr) x y rad start end r g b a
      = foreign FFI_C "arcRGBA"
           (Ptr -> IntAndColorParams 5) ptr x y rad start end r g b a

strokePie : SDLRenderer -> IntAndColorParams 5
strokePie (MkRenderer ptr) x y rad start end r g b a
      = foreign FFI_C "pieRGBA"
           (Ptr -> IntAndColorParams 5) ptr x y rad start end r g b a

filledPie : SDLRenderer -> IntAndColorParams 5
filledPie (MkRenderer ptr) x y rad start end r g b a
      = foreign FFI_C "filledPieRGBA"
           (Ptr -> IntAndColorParams 5) ptr x y rad start end r g b a

strokeEllipse : SDLRenderer -> IntAndColorParams 4
strokeEllipse (MkRenderer ptr) x y rx ry r g b a
      = foreign FFI_C "ellipseRGBA"
           (Ptr -> IntAndColorParams 4) ptr x y rx ry r g b a

filledEllipse : SDLRenderer -> IntAndColorParams 4
filledEllipse (MkRenderer ptr) x y rx ry r g b a
      = foreign FFI_C "filledEllipseRGBA"
           (Ptr -> IntAndColorParams 4) ptr x y rx ry r g b a

strokeAAEllipse : SDLRenderer -> IntAndColorParams 4
strokeAAEllipse (MkRenderer ptr) x y rx ry r g b a
      = foreign FFI_C "aaellipseRGBA"
           (Ptr -> IntAndColorParams 4) ptr x y rx ry r g b a

strokeTrigon : SDLRenderer -> IntAndColorParams 6
strokeTrigon (MkRenderer ptr) x1 y1 x2 y2 x3 y3 r g b a
      = foreign FFI_C "trigonRGBA"
           (Ptr -> IntAndColorParams 6) ptr x1 y1 x2 y2 x3 y3 r g b a

filledTrigon : SDLRenderer -> IntAndColorParams 6
filledTrigon (MkRenderer ptr) x1 y1 x2 y2 x3 y3 r g b a
      = foreign FFI_C "filledTrigonRGBA"
           (Ptr -> IntAndColorParams 6) ptr x1 y1 x2 y2 x3 y3 r g b a

strokeAATrigon : SDLRenderer -> IntAndColorParams 6
strokeAATrigon (MkRenderer ptr) x1 y1 x2 y2 x3 y3 r g b a
      = foreign FFI_C "aatrigonRGBA"
           (Ptr -> IntAndColorParams 6) ptr x1 y1 x2 y2 x3 y3 r g b a

strokePolygon : SDLRenderer -> {n : Nat} -> Vect n Int -> Vect n Int -> IntAndColorParams 0
strokePolygon (MkRenderer ptr) {n} xs ys r g b a = 
  do 
    xarr <- packVect xs
    yarr <- packVect ys
    let len = toIntNat n
    foreign FFI_C "strokePolygon" (Ptr -> Ptr -> Ptr -> Int -> IntAndColorParams 0) ptr xarr yarr len r g b a

filledPolygon : SDLRenderer -> {n : Nat} -> Vect n Int -> Vect n Int -> IntAndColorParams 0
filledPolygon (MkRenderer ptr) {n} xs ys r g b a = 
  do 
    xarr <- packVect xs
    yarr <- packVect ys
    let len = toIntNat n
    foreign FFI_C "filledPolygon" (Ptr -> Ptr -> Ptr -> Int -> IntAndColorParams 0) ptr xarr yarr len r g b a

strokeAAPolygon : SDLRenderer -> {n : Nat} -> Vect n Int -> Vect n Int -> IntAndColorParams 0
strokeAAPolygon (MkRenderer ptr) {n} xs ys r g b a = 
  do 
    xarr <- packVect xs
    yarr <- packVect ys
    let len = toIntNat n
    foreign FFI_C "strokeAAPolygon" (Ptr -> Ptr -> Ptr -> Int -> IntAndColorParams 0) ptr xarr yarr len r g b a

strokeBezier : SDLRenderer -> {n : Nat} -> Vect n Int -> Vect n Int -> IntAndColorParams 1
strokeBezier (MkRenderer ptr) {n} xs ys steps r g b a =
  do 
    xarr <- packVect xs
    yarr <- packVect ys
    let len = toIntNat n
    foreign FFI_C "bezier" (Ptr -> Ptr -> Ptr -> Int -> IntAndColorParams 1) 
                                   ptr xarr yarr len steps r g b a

strokeThickLine : SDLRenderer -> IntAndColorParams 5
strokeThickLine (MkRenderer ptr) x1 y1 x2 y2 width r g b a
      = foreign FFI_C "thickLineRGBA"
           (Ptr -> IntAndColorParams 5) ptr x1 y1 x2 y2 width r g b a
