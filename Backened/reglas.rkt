#lang racket

(provide reglas obtener-valor aplicar-reglas-a-base)

; ============================================================
; Reglas de inferencia - Akinator Stardew Valley
; EIF-400 Paradigmas de Programacion
; ============================================================
;
; Formato de cada regla:
;   (antecedentes consecuente-caracteristica consecuente-valor)
; donde antecedentes es una lista de (caracteristica valor) que deben
; cumplirse TODAS para que se derive el consecuente.
;
; IMPORTANTE: una regla solo agrega el hecho derivado si la entidad
; NO tiene ya un valor explicito para esa caracteristica (nunca
; sobrescribe hechos declarados directamente en la base).
; ============================================================

(define reglas
  '((((trabaja-en-joja si))                     es-npc si)
    (((trabaja-en-medicina si))                 es-npc si)
    (((trabaja-en-saloon si))                   es-npc si)
    (((tiene-tienda si))                        es-npc si)
    (((es-magico-o-misterioso si))              es-npc si)
    (((es-nino si))                             es-soltero no)
    (((esta-casado si))                         es-soltero no)
    (((es-anciano si) (esta-casado no))         es-soltero no)
    (((usa-silla-de-ruedas si))                 es-anciano si)
    (((trabaja-en-joja si))                     es-soltero si)))

; ------------------------------------------------------------
; obtener-valor: busca el valor de una caracteristica dentro de
; la lista de hechos de una entidad. Devuelve 'desconocido si no
; esta presente.
; ------------------------------------------------------------
(define (obtener-valor hechos caracteristica)
  (cond
    ((null? hechos) 'desconocido)
    ((eq? (caar hechos) caracteristica) (cadar hechos))
    (else (obtener-valor (cdr hechos) caracteristica))))

; ------------------------------------------------------------
; cumple-antecedentes?: verifica recursivamente que TODAS las
; condiciones de una regla se cumplan sobre los hechos dados.
; ------------------------------------------------------------
(define (cumple-antecedentes? antecedentes hechos)
  (cond
    ((null? antecedentes) #t)
    (else
      (let* ((condicion (car antecedentes))
             (caracteristica (car condicion))
             (valor-esperado (cadr condicion))
             (valor-real (obtener-valor hechos caracteristica)))
        (if (eq? valor-real valor-esperado)
            (cumple-antecedentes? (cdr antecedentes) hechos)
            #f)))))

; ------------------------------------------------------------
; aplicar-una-regla: si la regla aplica y el consecuente aun no
; esta en los hechos, lo agrega (cons) al frente de la lista.
; ------------------------------------------------------------
(define (aplicar-una-regla regla hechos)
  (let* ((antecedentes (car regla))
         (caracteristica (cadr regla))
         (valor (caddr regla)))
    (if (and (cumple-antecedentes? antecedentes hechos)
             (eq? (obtener-valor hechos caracteristica) 'desconocido))
        (cons (list caracteristica valor) hechos)
        hechos)))

; ------------------------------------------------------------
; aplicar-reglas-a-hechos: recorre recursivamente TODAS las
; reglas y las va aplicando en cadena sobre los hechos de una
; sola entidad.
; ------------------------------------------------------------
(define (aplicar-reglas-a-hechos lista-reglas hechos)
  (cond
    ((null? lista-reglas) hechos)
    (else
      (aplicar-reglas-a-hechos (cdr lista-reglas)
                                (aplicar-una-regla (car lista-reglas) hechos)))))

; ------------------------------------------------------------
; aplicar-reglas-a-entidad: aplica las reglas a los hechos de
; una entidad puntual, conservando su nombre.
; ------------------------------------------------------------
(define (aplicar-reglas-a-entidad entidad lista-reglas)
  (let* ((nombre (car entidad))
         (hechos (cdr entidad)))
    (cons nombre (aplicar-reglas-a-hechos lista-reglas hechos))))

; ------------------------------------------------------------
; aplicar-reglas-a-base: recorre recursivamente TODA la base de
; conocimiento aplicando las reglas a cada entidad.
; ------------------------------------------------------------
(define (aplicar-reglas-a-base base lista-reglas)
  (cond
    ((null? base) '())
    (else
      (cons (aplicar-reglas-a-entidad (car base) lista-reglas)
            (aplicar-reglas-a-base (cdr base) lista-reglas)))))