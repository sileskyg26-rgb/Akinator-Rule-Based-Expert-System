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
    "La base contiene personajes conocidos"
    (check-false (null? conocimiento))
    (check-not-false (assoc 'abigail conocimiento))
    (check-equal? (obtener-valor (hechos-de 'abigail) 'es-mujer) 'si))

   (test-case
    "Las reglas agregan hechos derivados"
    (define resultado
      (aplicar-reglas-a-base
       (list '(prueba (trabaja-en-joja si)))
       reglas))
    (check-equal? (obtener-valor (cdr (car resultado)) 'es-npc) 'si))

   (test-case
    "Las reglas preservan hechos explícitos"
    (define resultado
      (aplicar-reglas-a-base
       (list '(prueba (trabaja-en-joja si) (es-npc no)))
       reglas))
    (check-equal? (obtener-valor (cdr (car resultado)) 'es-npc) 'no))

   (test-case
    "El motor devuelve una pregunta al iniciar"
    (define resultado (inferir '() '()))
    (check-equal? (car resultado) 'pregunta)
    (check-true (symbol? (cadr resultado)))
    (check-true (exact-nonnegative-integer? (caddr resultado))))

   (test-case
    "Explicar devuelve coincidencias exactas"
    (define explicacion
      (explicar 'abigail '((es-mujer . si) (es-nino . no))))
    (check-not-false (member '(es-mujer si) explicacion))
    (check-not-false (member '(es-nino no) explicacion)))

   (test-case
    "Reiniciar devuelve un estado vacío"
    (check-equal? (reiniciar) '(() ())))))

(module+ main
  (displayln "=== INICIANDO PRUEBAS DEL MOTOR Y REGLAS ===")
  (run-tests motor-tests)
  (displayln "=== PRUEBAS DE RACKET FINALIZADAS EXITOSAMENTE ==="))
