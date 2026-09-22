#lang racket

(require racket/list
         racket/string
         racket/runtime-path
         "conocimiento.rkt"
         "reglas.rkt")

(provide todas-las-caracteristicas
         valores-validos
         entidades-documentadas
         validar-conocimiento
         validar-reglas
         validar-base)

(define todas-las-caracteristicas
  '(es-npc es-soltero es-mujer es-nino es-anciano vive-en-la-montana
    tiene-tienda trabaja-en-joja le-gusta-pescar le-gusta-mineria
    le-gusta-arte cria-animales trabaja-en-medicina esta-casado
    tiene-hijos trabaja-en-saloon es-forastero le-gusta-cocinar
    usa-silla-de-ruedas es-magico-o-misterioso es-hijo-unico))

(define valores-validos '(si no))
(define entidades-documentadas 31)
(define-runtime-path imagenes-directory "../Frontend/images")

(define (hechos-de entidad)
  (if (and (pair? entidad) (list? (cdr entidad)))
      (cdr entidad)
      '()))

(define (condiciones-cumplen? condiciones hechos)
  (andmap (lambda (condicion)
            (and (formato-hecho-valido? condicion)
                 (equal? (obtener-valor hechos (car condicion))
                         (cadr condicion))))
          condiciones))

(define (duplicados elementos)
  (define (recorrer restantes vistos resultado)
    (cond
      [(null? restantes) (remove-duplicates (reverse resultado))]
      [(member (car restantes) vistos)
       (recorrer (cdr restantes) vistos (cons (car restantes) resultado))]
      [else
       (recorrer (cdr restantes)
                 (cons (car restantes) vistos)
                 resultado)]))
  (recorrer elementos '() '()))

(define (formato-hecho-valido? hecho)
  (and (list? hecho)
       (= (length hecho) 2)
       (symbol? (car hecho))))

(define (validar-entidad entidad)
  (define nombre (and (pair? entidad) (car entidad)))
  (define hechos (and (pair? entidad) (cdr entidad)))
  (define nombres-hechos
    (if (list? hechos)
        (filter symbol? (map car (filter formato-hecho-valido? hechos)))
        '()))
  (define errores
    (append
     (if (symbol? nombre) '() (list "La entidad no tiene un nombre simbólico válido."))
     (if (list? hechos) '() (list (format "~a no contiene una lista de hechos." nombre)))
     (for/list ([hecho (in-list (if (list? hechos) hechos '()))]
                #:unless (formato-hecho-valido? hecho))
       (format "~a contiene un hecho con formato inválido: ~a" nombre hecho))
     (for/list ([caracteristica (in-list (remove-duplicates nombres-hechos))]
                #:unless (member caracteristica todas-las-caracteristicas))
       (format "~a usa una característica desconocida: ~a"
               nombre caracteristica))
     (for/list ([hecho (in-list (filter formato-hecho-valido? (if (list? hechos) hechos '())))]
                #:unless (member (cadr hecho) valores-validos))
       (format "~a tiene un valor inválido para ~a: ~a"
               nombre (car hecho) (cadr hecho)))
     (for/list ([caracteristica (in-list (duplicados nombres-hechos))])
       (format "~a repite la característica: ~a" nombre caracteristica))))
  (define faltantes
    (for/list ([caracteristica (in-list todas-las-caracteristicas)]
               #:unless (member caracteristica nombres-hechos))
      (format "~a no define la característica ~a; se tratará como desconocida."
              nombre caracteristica)))
  (values errores faltantes))

(define (validar-conocimiento base)
  (define nombres (map car base))
  (define entity-results
    (for/list ([entidad (in-list base)])
      (call-with-values
       (lambda () (validar-entidad entidad))
       list)))
  (hash
   'errores
   (append
    (for/list ([nombre (in-list (duplicados nombres))])
      (format "La base repite la entidad: ~a" nombre))
    (apply append (map car entity-results)))
   'advertencias
   (apply append (map cadr entity-results))))

(define (imagenes-disponibles [directorio imagenes-directory])
  (if (directory-exists? directorio)
      (for/list ([ruta (in-list (directory-list directorio))]
                 #:when (regexp-match? #rx"(?i)\\.png$" (path->string ruta)))
        (string-downcase
         (path->string
          (path-replace-extension (file-name-from-path ruta) #""))))
      '()))

(define (validar-imagenes base)
  (define imagenes (imagenes-disponibles))
  (for/list ([entidad (in-list base)]
             #:when (and (pair? entidad)
                         (symbol? (car entidad))
                         (not (member (string-downcase (symbol->string (car entidad)))
                                      imagenes))))
    (format "La entidad ~a no tiene una imagen PNG en Frontend/images."
            (car entidad))))

(define (validar-cantidad-entidades base)
  (if (= (length base) entidades-documentadas)
      '()
      (list
       (format "La documentación espera ~a entidades, pero la base contiene ~a."
               entidades-documentadas
               (length base)))))

(define (validar-condicion condicion contexto)
  (cond
    [(not (formato-hecho-valido? condicion))
     (list (format "~a contiene una condición inválida: ~a" contexto condicion))]
    [(not (member (car condicion) todas-las-caracteristicas))
     (list (format "~a usa una característica desconocida: ~a"
                   contexto (car condicion)))]
    [(not (member (cadr condicion) valores-validos))
     (list (format "~a usa un valor inválido: ~a" contexto (cadr condicion)))]
    [else '()]))

(define (validar-regla regla indice)
  (define contexto (format "La regla ~a" indice))
  (if (and (list? regla) (= (length regla) 3) (list? (car regla)))
      (append
       (apply append
              (for/list ([condicion (in-list (car regla))])
                (validar-condicion condicion contexto)))
       (if (member (cadr regla) todas-las-caracteristicas)
           '()
           (list (format "~a usa un consecuente desconocido: ~a"
                         contexto (cadr regla))))
       (if (member (caddr regla) valores-validos)
           '()
           (list (format "~a usa un valor de consecuente inválido: ~a"
                         contexto (caddr regla)))))
      (list (format "~a tiene una estructura inválida: ~a" contexto regla))))

(define (validar-reglas lista-reglas)
  (apply append
         (for/list ([regla (in-list lista-reglas)]
                    [indice (in-naturals 1)])
           (validar-regla regla indice))))

(define (regla-valida? regla)
  (and (list? regla)
       (= (length regla) 3)
       (list? (car regla))
       (andmap formato-hecho-valido? (car regla))
       (formato-hecho-valido? (list (cadr regla) (caddr regla)))))

(define (validar-contradicciones base lista-reglas)
  (apply append
         (for/list ([entidad (in-list base)]
                    #:when (and (pair? entidad) (symbol? (car entidad))))
           (define hechos (hechos-de entidad))
           (define aplicables
             (filter (lambda (regla)
                       (and (regla-valida? regla)
                            (condiciones-cumplen? (car regla) hechos)))
                     lista-reglas))
           (define contradicciones
             (for*/list ([regla-a (in-list aplicables)]
                         [regla-b (in-list aplicables)]
                         #:when (and (not (eq? regla-a regla-b))
                                     (equal? (cadr regla-a) (cadr regla-b))
                                     (not (equal? (caddr regla-a) (caddr regla-b)))))
               (format "~a activa reglas contradictorias para ~a: ~a y ~a."
                       (car entidad)
                       (cadr regla-a)
                       (caddr regla-a)
                       (caddr regla-b))))
           (define contradicciones-explicitas
             (for/list ([regla (in-list aplicables)]
                        #:when (and (not (equal? (obtener-valor hechos (cadr regla))
                                                 'desconocido))
                                    (not (equal? (obtener-valor hechos (cadr regla))
                                                 (caddr regla)))))
               (format "~a contradice el hecho explícito ~a=~a con una regla que deriva ~a."
                       (car entidad)
                       (cadr regla)
                       (obtener-valor hechos (cadr regla))
                       (caddr regla))))
           (append contradicciones contradicciones-explicitas))))

(define (validar-base [base conocimiento] [lista-reglas reglas])
  (define conocimiento-reporte (validar-conocimiento base))
  (define errores-reglas (validar-reglas lista-reglas))
  (define errores-cantidad (validar-cantidad-entidades base))
  (define errores-imagenes (validar-imagenes base))
  (define errores-contradicciones (validar-contradicciones base lista-reglas))
  (hash
   'errores (append (hash-ref conocimiento-reporte 'errores)
                    errores-reglas
                    errores-cantidad
                    errores-imagenes
                    errores-contradicciones)
   'advertencias (hash-ref conocimiento-reporte 'advertencias)))

(define (mostrar-reporte reporte)
  (define errores (hash-ref reporte 'errores))
  (define advertencias (hash-ref reporte 'advertencias))
  (printf "Entidades validadas: ~a~n" (length conocimiento))
  (printf "Características esperadas: ~a~n" (length todas-las-caracteristicas))
  (printf "Reglas validadas: ~a~n" (length reglas))
  (printf "Entidades documentadas: ~a~n" entidades-documentadas)
  (printf "Errores: ~a~n" (length errores))
  (printf "Advertencias por datos ausentes: ~a~n" (length advertencias))
  (for ([error (in-list errores)])
    (printf "ERROR: ~a~n" error))
  (when (pair? advertencias)
    (printf "Las advertencias indican campos que el motor tratará como 'desconocido'.~n")))

(module+ main
  (define reporte (validar-base))
  (mostrar-reporte reporte)
  (if (null? (hash-ref reporte 'errores))
      (exit 0)
      (exit 1)))
