#lang info

(define collection 'multi)

(define deps '("base"
               "data-lib"
               "draw-lib"
               "pict-lib"
               "gui-lib"
               "future-visualizer-pict"))
(define build-deps '("scheme-lib"
                     "scribble-lib"
                     "racket-doc"
                     "rackunit-lib"))

(define implies '("future-visualizer-pict"))

(define pkg-desc "Graphical performance tools for using futures")

(define pkg-authors '(jamesswaine))

(define version "1.1")

(define license
  '(Apache-2.0 OR MIT))
