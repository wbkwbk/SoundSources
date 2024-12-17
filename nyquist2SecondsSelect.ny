(define (linear-fade-in-first-second)
  (let* ((samplerate (sound-sr (sound-active)))
         (end-sample samplerate))
    (try
      (linear-fade-in-macro 0 end-sample)
      (error "Fehler beim Anwenden des Fade-ins."))))

(linear-fade-in-first-second)