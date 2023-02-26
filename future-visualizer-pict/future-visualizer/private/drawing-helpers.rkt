#lang racket/base
(require pict
         "display.rkt"
         "constants.rkt")
(provide opacity-layer
         circle-pict
         rect-pict
         text-pict
         text-block-pict
         draw-line-onto
         make-stand-out
         at
         draw-stack-onto)

;;opacity-layer : float uint uint -> pict
(define (opacity-layer alpha w h)
  (cellophane (colorize (filled-rectangle w h)
                        "white")
              0.6))

;;circle-pict : string string uint [uint] -> pict
(define (circle-pict color stroke-color width #:stroke-width [stroke-width 1])
  (define dx (min stroke-width (* 2 width)))
  (pin-over (colorize (filled-ellipse width width)
                      (if (dx . < . 1)
                          color
                          stroke-color))
            dx
            dx
            (colorize (filled-ellipse (- width (* dx 2))
                                      (- width (* dx 2)))
                      color)))

;;rect-pict : string string uint uint [uint] -> pict
(define (rect-pict color stroke-color width height #:stroke-width [stroke-width 1])
  (define dx (min (* 2 stroke-width) (/ width 2)))
  (define dy (min (* 2 stroke-width) (/ height 2)))
  (pin-over (colorize (filled-rectangle width height)
                      (if (or (dx . <= . (/ width 2))
                              (dy . <= . (/ height 2)))
                          color
                          stroke-color))
            dx
            dy
            (colorize (filled-rectangle (- width (* dx 2))
                                        (- height (* dy 2)))
                      color)))

;;text-pict : string [string] -> pict
(define (text-pict t #:color [color "black"])
  (colorize (text t) color))

;;text-block-pict : string [string] [string] [uint] [float] [uint] [uint] -> pict
(define (text-block-pict t #:backcolor [backcolor "white"]
                         #:forecolor [forecolor "black"]
                         #:padding [padding 10]
                         #:opacity [opacity 1.0]
                         #:width [width 0]
                         #:height [height 0])
  (let* ([textp (colorize (text t) forecolor)]
         [padx2 (* padding 2)]
         [text-cont (pin-over (blank (+ (pict-width textp) padx2)
                                     (+ (pict-height textp) padx2))
                              padding
                              padding
                              textp)]
         [bg (cellophane (colorize (filled-rectangle (max width (pict-width text-cont))
                                                     (max height (pict-height text-cont)))
                                   backcolor)
                         opacity)])
    (lc-superimpose bg text-cont))) 

;;draw-line-onto : pict uint uint uint uint string -> pict
(define (draw-line-onto base
                        startx
                        starty
                        endx
                        endy
                        color
                        #:width [width 1]
                        #:with-arrow [with-arrow #f]
                        #:arrow-sz [arrow-sz 10]
                        #:style [style 'solid])
  (let ([dx (- endx startx)]
        [dy (- endy starty)]
        [line-f (if with-arrow pip-arrow-line pip-line)])
    (pin-over base
              startx
              starty
              (linewidth width
                         (linestyle style
                                    (colorize (line-f dx dy arrow-sz)
                                              color))))))

;;make-stand-out : pict -> pict
(define (make-stand-out pict)
  (scale pict 2))

(struct draw-at (x y p) #:transparent)

;;at : uint uint pict -> draw-at
(define (at x y p)
  (draw-at x y p))

;;draw-stack-onto : pict (listof pict) -> pict
(define (draw-stack-onto base . picts)
  (for/fold ([p base]) ([cur-p (in-list picts)])
    (cond
      [(pict? cur-p) (pin-over p 0 0 cur-p)]
      [(draw-at? cur-p) (pin-over p
                                  (draw-at-x cur-p)
                                  (draw-at-y cur-p)
                                  (draw-at-p cur-p))]
      [else (error 'draw-onto "Invalid argument in 'picts' list.")])))
