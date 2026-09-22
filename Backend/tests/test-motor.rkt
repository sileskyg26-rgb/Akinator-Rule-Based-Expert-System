#lang racket

(require rackunit
         "../conocimiento.rkt"
         "../reglas.rkt"
         "../motor.rkt")

(define (hechos-de entidad)
  (cdr (assoc entidad conocimiento)))

(define motor-tests
  (test-suite
   "Pruebas del motor de inferencia y reglas"

   (test-case
    "La base de conocimiento contiene personajes y hechos"
    (check-false (null? conocimiento))
    (check-not-false (assoc 'abigail conocimiento))
    (check-equal? (obtener-valor (hechos-de 'abigail) 'es-mujer) 'si))

   (test-case
    "Las reglas agregan hechos derivados"
    (define hechos
      '((trabaja-en-joja si)
        (es-soltero no)))
    (define resultado
      (aplicar-reglas-a-base
       (list (cons 'prueba hechos))
       reglas))

    (check-equal?
     (obtener-valor (cdr (car resultado)) 'es-npc)
     'si)
    (check-equal?
     (obtener-valor (cdr (car resultado)) 'es-soltero)
     'no))

   (test-case
    "Las reglas no sobrescriben hechos explícitos"
    (define hechos
      '((trabaja-en-joja si)
        (es-npc no)))
    (define resultado
      (aplicar-reglas-a-base
       (list (cons 'prueba hechos))
       reglas))

    (check-equal?
     (obtener-valor (cdr (car resultado)) 'es-npc)
     'no))

   (test-case
    "El motor solicita una pregunta al iniciar una partida"
    (define resultado (inferir '() '()))

    (check-equal? (car resultado) 'pregunta)
    (check-true (symbol? (cadr resultado)))
    (check-true (exact-nonnegative-integer? (caddr resultado))))

   (test-case
    "El motor no repite una característica ya preguntada"
    (define primera (inferir '() '()))
    (define siguiente
      (inferir '() (list (cadr primera))))

    (check-equal? (car siguiente) 'pregunta)
    (check-not-equal? (cadr primera) (cadr siguiente)))

   (test-case
    "Explicar devuelve coincidencias exactas"
    (define explicacion
      (explicar 'abigail '((es-mujer . si) (es-nino . no))))

    (check-false (null? explicacion))
    (check-not-false (member '(es-mujer si) explicacion))
    (check-not-false (member '(es-nino no) explicacion)))

   (test-case
    "Explicar una entidad inexistente devuelve una lista vacía"
    (check-equal? (explicar 'personaje-inexistente '()) '()))

   (test-case
    "Reiniciar devuelve un estado vacío"
    (check-equal? (reiniciar) '(() ())))))

(module+ main
  (displayln "=== INICIANDO PRUEBAS DEL MOTOR Y REGLAS ===")
  (run-tests motor-tests)
  (displayln "=== PRUEBAS DE RACKET FINALIZADAS EXITOSAMENTE ==="))
