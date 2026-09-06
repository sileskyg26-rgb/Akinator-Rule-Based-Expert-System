#lang racket

; ============================================================
; Base de conocimiento - Akinator Stardew Valley
; EIF-400 Paradigmas de Programacion
; ============================================================
;
; DOMINIO: Personajes (NPCs) de Stardew Valley
; (32 entidades: 30 residentes humanos + Krobus y la Enana)
;
; Formato de cada entidad (igual al del enunciado):
;   (nombre-entidad (caracteristica-1 valor) (caracteristica-2 valor) ...)
; valor puede ser: si | no
; (si una caracteristica no aparece para una entidad, se asume "desconocido")
;
; ============================================================
; LAS 21 CARACTERISTICAS USADAS (documentar en el informe tecnico)
; ============================================================
; 1.  es-npc                 -> es un personaje no jugable del pueblo
; 2.  es-soltero              -> es candidato de matrimonio (bachelor/bachelorette)
; 3.  es-mujer                -> es de genero femenino
; 4.  es-nino                 -> es un nino/nina
; 5.  es-anciano               -> es un adulto mayor
; 6.  vive-en-la-montana      -> su casa/zona esta en el area de la montana
; 7.  tiene-tienda            -> es dueno/a de un negocio o tienda
; 8.  trabaja-en-joja         -> trabaja para Joja Corporation
; 9.  le-gusta-pescar         -> tiene la pesca como afición/oficio marcado
; 10. le-gusta-mineria        -> le gusta explorar minas / trabajar con minerales
; 11. le-gusta-arte           -> practica musica, pintura, escritura o artesania
; 12. cria-animales           -> cria o cuida animales de granja
; 13. trabaja-en-medicina     -> trabaja en la clinica (medico/enfermera)
; 14. esta-casado             -> esta casado/a dentro del pueblo
; 15. tiene-hijos              -> tiene hijos o hijastros
; 16. trabaja-en-saloon       -> trabaja en el Stardrop Saloon
; 17. es-forastero            -> no nacio en Pelican Town, se mudo despues
; 18. le-gusta-cocinar        -> cocina o le gusta la gastronomia
; 19. usa-silla-de-ruedas     -> usa silla de ruedas
; 20. es-magico-o-misterioso  -> tiene un aire magico/misterioso/espiritual
; 21. es-hijo-unico           -> no tiene hermanos ni hermanas
;
; ============================================================

(define conocimiento
  '((abigail
      (es-npc si) (es-soltero si) (es-mujer si) (es-nino no) (es-anciano no)
      (le-gusta-mineria si) (le-gusta-arte si) (esta-casado no)
      (es-forastero no) (trabaja-en-joja no) (es-hijo-unico si))

    (alex
      (es-npc si) (es-soltero si) (es-mujer no) (es-anciano no)
      (le-gusta-arte no) (trabaja-en-joja no) (esta-casado no)
      (es-forastero no) (cria-animales no) (tiene-hijos no))

    (elliott
      (es-npc si) (es-soltero si) (es-mujer no) (le-gusta-pescar si)
      (le-gusta-arte si) (es-forastero si) (esta-casado no)
      (vive-en-la-montana no) (trabaja-en-joja no) (usa-silla-de-ruedas no))

    (emily
      (es-npc si) (es-soltero si) (es-mujer si) (trabaja-en-saloon si)
      (le-gusta-arte si) (es-magico-o-misterioso si) (esta-casado no)
      (es-nino no) (trabaja-en-joja no) (es-hijo-unico no))

    (haley
      (es-npc si) (es-soltero si) (es-mujer si) (le-gusta-arte si)
      (cria-animales no) (es-forastero no) (esta-casado no)
      (trabaja-en-joja no) (le-gusta-pescar no) (es-hijo-unico no))

    (harvey
      (es-npc si) (es-soltero si) (es-mujer no) (trabaja-en-medicina si)
      (es-anciano no) (esta-casado no) (es-forastero no) (trabaja-en-joja no))

    (leah
      (es-npc si) (es-soltero si) (es-mujer si) (le-gusta-arte si)
      (es-forastero si) (cria-animales no) (esta-casado no) (trabaja-en-joja no))

    (maru
      (es-npc si) (es-soltero si) (es-mujer si) (trabaja-en-medicina si)
      (vive-en-la-montana si) (le-gusta-mineria si) (esta-casado no) (tiene-hijos no)
      (es-hijo-unico no))

    (penny
      (es-npc si) (es-soltero si) (es-mujer si) (le-gusta-cocinar no)
      (tiene-hijos no) (esta-casado no) (es-forastero no) (trabaja-en-joja no)
      (es-hijo-unico si))

    (sam
      (es-npc si) (es-soltero si) (es-mujer no) (le-gusta-arte si)
      (cria-animales no) (esta-casado no) (es-forastero no) (trabaja-en-joja no)
      (es-hijo-unico no))

    (sebastian
      (es-npc si) (es-soltero si) (es-mujer no) (vive-en-la-montana si)
      (le-gusta-arte no) (es-forastero no) (esta-casado no) (trabaja-en-joja no)
      (es-hijo-unico no))

    (shane
      (es-npc si) (es-soltero si) (es-mujer no) (trabaja-en-joja si)
      (cria-animales si) (esta-casado no) (es-forastero no)
      (es-anciano no))

    (caroline
      (es-npc si) (es-soltero no) (es-mujer si) (esta-casado si)
      (tiene-hijos si) (tiene-tienda no) (trabaja-en-joja no) (es-forastero no))

    (clint
      (es-npc si) (es-soltero no) (es-mujer no) (tiene-tienda si)
      (le-gusta-mineria si) (esta-casado no) (trabaja-en-joja no) (es-anciano no))

    (demetrius
      (es-npc si) (es-soltero no) (es-mujer no) (esta-casado si)
      (vive-en-la-montana si) (trabaja-en-medicina no) (tiene-hijos si)
      (le-gusta-mineria si))

    (evelyn
      (es-npc si) (es-soltero no) (es-mujer si) (es-anciano si)
      (cria-animales no) (tiene-hijos si) (esta-casado si) (trabaja-en-joja no))

    (george
      (es-npc si) (es-soltero no) (es-mujer no) (es-anciano si)
      (usa-silla-de-ruedas si) (esta-casado si) (tiene-hijos no) (trabaja-en-joja no))

    (gus
      (es-npc si) (es-soltero no) (es-mujer no) (trabaja-en-saloon si)
      (tiene-tienda si) (le-gusta-cocinar si) (esta-casado no) (es-anciano no))

    (jas
      (es-npc si) (es-soltero no) (es-mujer si) (es-nino si)
      (cria-animales no) (tiene-hijos no) (esta-casado no) (trabaja-en-joja no)
      (es-hijo-unico si))

    (jodi
      (es-npc si) (es-soltero no) (es-mujer si) (esta-casado si)
      (tiene-hijos si) (le-gusta-cocinar si) (trabaja-en-joja no) (es-forastero no))

    (kent
      (es-npc si) (es-soltero no) (es-mujer no) (esta-casado si)
      (es-forastero no) (tiene-hijos si) (trabaja-en-joja no) (es-anciano no))

    (lewis
      (es-npc si) (es-soltero no) (es-mujer no) (es-anciano si)
      (esta-casado no) (trabaja-en-joja no) (tiene-hijos no) (es-forastero no))

    (linus
      (es-npc si) (es-soltero no) (es-mujer no) (vive-en-la-montana si)
      (es-forastero si) (esta-casado no) (tiene-hijos no) (trabaja-en-joja no))

    (marnie
      (es-npc si) (es-soltero no) (es-mujer si) (cria-animales si)
      (tiene-tienda si) (esta-casado no) (tiene-hijos no) (es-anciano no))

    (pam
      (es-npc si) (es-soltero no) (es-mujer si) (tiene-hijos si)
      (esta-casado no) (trabaja-en-joja no) (cria-animales no) (es-anciano no))

    (pierre
      (es-npc si) (es-soltero no) (es-mujer no) (tiene-tienda si)
      (esta-casado si) (tiene-hijos si) (es-forastero no) (trabaja-en-joja no))

    (robin
      (es-npc si) (es-soltero no) (es-mujer si) (vive-en-la-montana si)
      (esta-casado si) (tiene-tienda si) (tiene-hijos si) (trabaja-en-joja no))

    (vincent
      (es-npc si) (es-soltero no) (es-mujer no) (es-nino si)
      (tiene-hijos no) (esta-casado no) (trabaja-en-joja no) (cria-animales no)
      (es-hijo-unico no))

    (willy
      (es-npc si) (es-soltero no) (es-mujer no) (le-gusta-pescar si)
      (tiene-tienda si) (es-forastero si) (esta-casado no) (es-anciano no))

    (wizard
      (es-npc si) (es-soltero no) (es-mujer no) (es-magico-o-misterioso si)
      (es-forastero si) (esta-casado no) (tiene-hijos no) (es-anciano no))

    (krobus
      (es-npc si) (es-soltero si) (es-mujer no) (es-magico-o-misterioso si)
      (tiene-tienda si) (es-forastero si) (vive-en-la-montana no)
      (esta-casado no) (tiene-hijos no) (trabaja-en-joja no))

    (la-enana
      (es-npc si) (es-soltero no) (es-mujer si) (es-magico-o-misterioso si)
      (tiene-tienda si) (le-gusta-mineria si) (es-forastero si)
      (esta-casado no) (tiene-hijos no) (vive-en-la-montana no))))


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


; ============================================================
; Motor de inferencia - Akinator Stardew Valley
; EIF-400 Paradigmas de Programacion
; ============================================================
;
; Este archivo asume que ya estan cargados:
;   - conocimiento.scm  (define 'conocimiento')
;   - reglas.scm        (define 'reglas' y 'aplicar-reglas-a-base')
;
; En MIT/GNU Scheme o DrRacket #lang scheme:
;   (load "conocimiento.scm")
;   (load "reglas.scm")
;   (load "motor.scm")
;
; ------------------------------------------------------------
; REPRESENTACION USADA EN ESTE ARCHIVO
; ------------------------------------------------------------
; respuestas: lista de (caracteristica . respuesta-usuario)
;             ej: ((es-mujer . si) (es-nino . no-se) (tiene-tienda . no))
; candidatos: lista de (nombre . puntaje) ej: ((abigail . 2.3) (shane . -1.0))
; ============================================================

; ------------------------------------------------------------
; valor-numerico: convierte un hecho real (si/no/desconocido) a
; un numero entre -1.0 y 1.0
; ------------------------------------------------------------
(define (valor-numerico valor)
  (cond
    ((eq? valor 'si) 1.0)
    ((eq? valor 'no) -1.0)
    (else 0.0)))

; ------------------------------------------------------------
; signal-numerico: convierte la respuesta del usuario a un
; numero entre -1.0 y 1.0, segun la escala definida en el
; enunciado (punto 11).
; ------------------------------------------------------------
(define (signal-numerico respuesta)
  (cond
    ((eq? respuesta 'si) 1.0)
    ((eq? respuesta 'no) -1.0)
    ((eq? respuesta 'no-se) 0.0)
    ((eq? respuesta 'probablemente) 0.7)
    ((eq? respuesta 'probablemente-no) -0.7)
    (else 0.0)))

; ------------------------------------------------------------
; contribucion: el "acuerdo" entre el hecho real y la respuesta,
; PONDERADO por que tan rara/informativa es esa coincidencia en
; toda la base de conocimiento (peso-informativo, ver abajo).
; ------------------------------------------------------------
(define (contribucion valor-real respuesta-usuario caracteristica)
  (* (valor-numerico valor-real)
     (signal-numerico respuesta-usuario)
     (peso-informativo caracteristica valor-real)))

; ------------------------------------------------------------
; PESO INFORMATIVO (idea de ganancia de informacion, punto 17
; del enunciado): una coincidencia en un valor RARO (que pocas
; entidades comparten) vale mucho mas que una coincidencia en un
; valor COMUN (que casi todas comparten), porque esa ultima casi
; no ayuda a diferenciar candidatos.
;   peso = 1 - (cantidad de entidades con ese valor / total)
; Ejemplo: "es-nino=si" (2 de 32) -> peso ~0.94 (muy informativo)
;          "esta-casado=no" (24 de 32) -> peso ~0.25 (poco informativo)
; ------------------------------------------------------------
(define total-entidades (length conocimiento))

(define (contar-valor-en-base caracteristica valor base)
  (cond
    ((null? base) 0)
    ((eq? (obtener-valor (cdar base) caracteristica) valor)
      (+ 1 (contar-valor-en-base caracteristica valor (cdr base))))
    (else (contar-valor-en-base caracteristica valor (cdr base)))))

(define (peso-informativo caracteristica valor)
  (let* ((cantidad (contar-valor-en-base caracteristica valor base-con-reglas))
         (proporcion (/ (exact->inexact cantidad) (exact->inexact total-entidades))))
    (- 1.0 proporcion)))

; maximo-peso-caracteristica: el mayor peso posible para esta
; caracteristica (entre coincidir en si o coincidir en no). Sirve
; para normalizar la confianza mas adelante.
(define (maximo-peso-caracteristica caracteristica)
  (max (peso-informativo caracteristica 'si) (peso-informativo caracteristica 'no)))

(define (maximo-posible-respuestas respuestas)
  (cond
    ((null? respuestas) 0.0)
    (else (+ (maximo-peso-caracteristica (caar respuestas))
             (maximo-posible-respuestas (cdr respuestas))))))

; ------------------------------------------------------------
; puntaje-entidad: suma recursivamente la contribucion de cada
; respuesta dada, comparandola contra los hechos de UNA entidad.
; ------------------------------------------------------------
(define (puntaje-entidad hechos respuestas)
  (cond
    ((null? respuestas) 0.0)
    (else
      (let* ((par (car respuestas))
             (caracteristica (car par))
             (respuesta-usuario (cdr par))
             (valor-real (obtener-valor hechos caracteristica)))
        (+ (contribucion valor-real respuesta-usuario caracteristica)
           (puntaje-entidad hechos (cdr respuestas)))))))

; ------------------------------------------------------------
; filtrar-candidatos: recorre TODA la base (ya con reglas
; aplicadas) y calcula el puntaje de cada entidad segun las
; respuestas acumuladas hasta el momento.
; ------------------------------------------------------------
(define (filtrar-candidatos base respuestas)
  (cond
    ((null? base) '())
    (else
      (let* ((entidad (car base))
             (nombre (car entidad))
             (hechos (cdr entidad))
             (puntaje (puntaje-entidad hechos respuestas)))
        (cons (cons nombre puntaje)
              (filtrar-candidatos (cdr base) respuestas))))))

; ------------------------------------------------------------
; mejor-candidato: encuentra recursivamente el par (nombre . puntaje)
; con el puntaje mas alto.
; ------------------------------------------------------------
(define (mejor-candidato candidatos)
  (cond
    ((null? candidatos) #f)
    ((null? (cdr candidatos)) (car candidatos))
    (else
      (let ((resto (mejor-candidato (cdr candidatos)))
            (actual (car candidatos)))
        (if (> (cdr actual) (cdr resto)) actual resto)))))

; ------------------------------------------------------------
; segundo-mejor-puntaje: el puntaje mas alto entre TODOS los
; candidatos EXCEPTO el que ya se identifico como mejor. Sirve
; para medir que tan "solo" quedo el mejor candidato.
; ------------------------------------------------------------
(define (segundo-mejor-puntaje candidatos nombre-mejor)
  (cond
    ((null? candidatos) -100.0)
    ((eq? (caar candidatos) nombre-mejor)
      (segundo-mejor-puntaje (cdr candidatos) nombre-mejor))
    (else
      (max (cdar candidatos)
           (segundo-mejor-puntaje (cdr candidatos) nombre-mejor)))))

; ------------------------------------------------------------
; calcular-confianza: mide que tanto domina el mejor candidato
; sobre el segundo mejor, como PROPORCION del puntaje total entre
; ambos:
;     confianza = puntaje-mejor / (puntaje-mejor + puntaje-segundo)
; Si el segundo lugar tiene puntaje negativo, se trata como 0
; (no le "resta" credito al lider). Si el mejor candidato tiene
; puntaje 0 o negativo, no hay suficiente evidencia -> confianza 0.
; Esta forma es mas robusta que dividir contra un "maximo teorico
; acumulado", porque no penaliza al candidato correcto por tener
; caracteristicas "desconocido" en preguntas que no le aplican.
; ------------------------------------------------------------
(define (calcular-confianza candidatos)
  (if (null? candidatos)
      0.0
      (let* ((mejor (mejor-candidato candidatos))
             (nombre-mejor (car mejor))
             (puntaje-mejor (cdr mejor))
             (puntaje-segundo-bruto (segundo-mejor-puntaje candidatos nombre-mejor))
             (puntaje-segundo (max 0.0 puntaje-segundo-bruto)))
        (if (<= puntaje-mejor 0.0)
            0.0
            (min 1.0 (/ puntaje-mejor (+ puntaje-mejor puntaje-segundo)))))))

; ============================================================
; SELECCION DINAMICA DE PREGUNTAS
; ============================================================

; Lista de las 20 caracteristicas usadas en el dominio (deben
; coincidir exactamente con las de conocimiento.scm)
(define todas-las-caracteristicas
  '(es-npc es-soltero es-mujer es-nino es-anciano vive-en-la-montana
    tiene-tienda trabaja-en-joja le-gusta-pescar le-gusta-mineria
    le-gusta-arte cria-animales trabaja-en-medicina esta-casado
    tiene-hijos trabaja-en-saloon es-forastero le-gusta-cocinar
    usa-silla-de-ruedas es-magico-o-misterioso es-hijo-unico))

; Un candidato queda descartado PERMANENTEMENTE en el momento en
; que su puntaje acumulado, EN CUALQUIER PUNTO del historial de
; respuestas (no solo al final), cae por debajo de este umbral.
; Una vez descartado no puede "recuperarse" aunque respuestas
; posteriores lo hubieran favorecido matematicamente.
(define umbral-descarte -1.0)

(define (pertenece? elemento lista)
  (cond
    ((null? lista) #f)
    ((eq? elemento (car lista)) #t)
    (else (pertenece? elemento (cdr lista)))))

(define (quitar-preguntadas caracteristicas preguntadas)
  (cond
    ((null? caracteristicas) '())
    ((pertenece? (car caracteristicas) preguntadas)
      (quitar-preguntadas (cdr caracteristicas) preguntadas))
    (else (cons (car caracteristicas) (quitar-preguntadas (cdr caracteristicas) preguntadas)))))

(define (contar-si caracteristica entidades)
  (cond
    ((null? entidades) 0)
    ((eq? (obtener-valor (cdar entidades) caracteristica) 'si)
      (+ 1 (contar-si caracteristica (cdr entidades))))
    (else (contar-si caracteristica (cdr entidades)))))

(define (contar-no caracteristica entidades)
  (cond
    ((null? entidades) 0)
    ((eq? (obtener-valor (cdar entidades) caracteristica) 'no)
      (+ 1 (contar-no caracteristica (cdr entidades))))
    (else (contar-no caracteristica (cdr entidades)))))

; balance: entre mas cerca de 0, mas pareja la particion si/no
; entre los candidatos activos -> mejor pregunta discriminante.
; IMPORTANTE: se penaliza con +1 por cada candidato "desconocido"
; en esa caracteristica, para que el motor prefiera preguntas con
; buena cobertura de datos en vez de preguntas con pocos hechos
; que por casualidad quedan 50/50.
(define (contar-desconocido caracteristica entidades)
  (cond
    ((null? entidades) 0)
    ((eq? (obtener-valor (cdar entidades) caracteristica) 'desconocido)
      (+ 1 (contar-desconocido caracteristica (cdr entidades))))
    (else (contar-desconocido caracteristica (cdr entidades)))))

(define (balance caracteristica entidades)
  (+ (abs (- (contar-si caracteristica entidades) (contar-no caracteristica entidades)))
     (contar-desconocido caracteristica entidades)))

(define (mejor-caracteristica caracteristicas entidades-activas)
  (cond
    ((null? caracteristicas) #f)
    ((null? (cdr caracteristicas)) (car caracteristicas))
    (else
      (let* ((actual (car caracteristicas))
             (resto (mejor-caracteristica (cdr caracteristicas) entidades-activas)))
        (if (<= (balance actual entidades-activas) (balance resto entidades-activas))
            actual
            resto)))))

; ------------------------------------------------------------
; DESCARTE PERMANENTE
; ------------------------------------------------------------
; En vez de mirar solo el puntaje final, reconstruimos la
; secuencia de sumas parciales EN ORDEN CRONOLOGICO (asumiendo
; que 'respuestas' trae primero la respuesta mas antigua) y
; buscamos el peor momento (minimo) de esa secuencia. Si ese
; minimo cayo alguna vez bajo el umbral, la entidad queda
; descartada para siempre, sin importar el puntaje final.
; ------------------------------------------------------------

(define (contribuciones-en-orden hechos respuestas)
  (cond
    ((null? respuestas) '())
    (else
      (cons (contribucion (obtener-valor hechos (caar respuestas)) (cdar respuestas) (caar respuestas))
            (contribuciones-en-orden hechos (cdr respuestas))))))

; sumas-parciales: dada una lista de numeros y un acumulado
; inicial, devuelve la lista de sumas prefijo por prefijo.
(define (sumas-parciales numeros acumulado)
  (cond
    ((null? numeros) '())
    (else
      (let ((nuevo-acumulado (+ acumulado (car numeros))))
        (cons nuevo-acumulado (sumas-parciales (cdr numeros) nuevo-acumulado))))))

(define (minimo-lista lista)
  (cond
    ((null? lista) 0.0)
    ((null? (cdr lista)) (car lista))
    (else (min (car lista) (minimo-lista (cdr lista))))))

; minimo-acumulado: el peor puntaje que tuvo esta entidad en
; cualquier momento del historial (0.0 si aun no hay respuestas).
(define (minimo-acumulado hechos respuestas)
  (minimo-lista (sumas-parciales (contribuciones-en-orden hechos respuestas) 0.0)))

; entidad-activa?: sigue activa si su puntaje NUNCA cayo bajo el
; umbral de descarte en ningun prefijo del historial.
(define (entidad-activa? hechos respuestas)
  (>= (minimo-acumulado hechos respuestas) umbral-descarte))

; entidades-activas: filtra la base de conocimiento dejando solo
; las entidades que siguen activas segun el historial completo.
(define (entidades-activas base respuestas)
  (cond
    ((null? base) '())
    ((entidad-activa? (cdar base) respuestas)
      (cons (car base) (entidades-activas (cdr base) respuestas)))
    (else (entidades-activas (cdr base) respuestas))))

; seleccionar-pregunta: elige la caracteristica sin preguntar aun
; que mejor divide a los candidatos ACTIVOS (segun descarte
; permanente). Devuelve #f si ya no quedan caracteristicas.
(define (seleccionar-pregunta base respuestas caracteristicas-preguntadas)
  (let* ((disponibles (quitar-preguntadas todas-las-caracteristicas caracteristicas-preguntadas))
         (activas (entidades-activas base respuestas)))
    (if (null? disponibles)
        #f
        (mejor-caracteristica disponibles activas))))

; ============================================================
; CICLO PRINCIPAL: inferir
; ============================================================

; Base de conocimiento con las reglas ya aplicadas UNA sola vez
; (se calcula al cargar el archivo, no en cada pregunta).
(define base-con-reglas (aplicar-reglas-a-base conocimiento reglas))

(define umbral-confianza 0.6)
(define umbral-incertidumbre 0.4)
(define maximo-preguntas 15)

; inferir: recibe el historial de respuestas y de preguntas ya
; hechas, y decide si hay veredicto o cual es la siguiente
; pregunta. Devuelve una de estas tres formas:
;   (veredicto nombre confianza)
;   (veredicto ninguno confianza)        -- se descartaron todos,
;                                            o se agoto el limite
;                                            de preguntas sin
;                                            suficiente certeza
;   (pregunta caracteristica candidatos-restantes)
(define (inferir respuestas caracteristicas-preguntadas)
  (let* ((activas (entidades-activas base-con-reglas respuestas))
         (candidatos (filtrar-candidatos activas respuestas))
         (num-respondidas (length respuestas)))
    (cond
      ((null? candidatos)
        (list 'veredicto 'ninguno 0.0))
      (else
        (let ((confianza (calcular-confianza candidatos)))
          (cond
            ((>= confianza umbral-confianza)
              (list 'veredicto (car (mejor-candidato candidatos)) confianza))
            ((and (>= num-respondidas maximo-preguntas) (< confianza umbral-incertidumbre))
              (list 'veredicto 'ninguno confianza))
            ((>= num-respondidas maximo-preguntas)
              (list 'veredicto (car (mejor-candidato candidatos)) confianza))
            (else
              (let ((siguiente (seleccionar-pregunta base-con-reglas respuestas caracteristicas-preguntadas)))
                (if siguiente
                    (list 'pregunta siguiente (length candidatos))
                    (list 'veredicto (car (mejor-candidato candidatos)) confianza))))))))))

; ============================================================
; EXPLICABILIDAD
; ============================================================

; explicar: dado el nombre de la entidad predicha y el historial
; de respuestas, devuelve las respuestas cuyo valor real coincidio
; EXACTAMENTE con lo que dijo el usuario (sí/sí o no/no), que son
; las que mas influyeron en el veredicto.
(define (explicar nombre-entidad respuestas)
  (let ((entidad (buscar-entidad nombre-entidad base-con-reglas)))
    (if entidad
        (explicar-hechos (cdr entidad) respuestas)
        '())))

(define (buscar-entidad nombre base)
  (cond
    ((null? base) #f)
    ((eq? (caar base) nombre) (car base))
    (else (buscar-entidad nombre (cdr base)))))

(define (coincidencia-exacta? valor-real respuesta-usuario)
  (= (* (valor-numerico valor-real) (signal-numerico respuesta-usuario)) 1.0))

(define (explicar-hechos hechos respuestas)
  (cond
    ((null? respuestas) '())
    (else
      (let* ((par (car respuestas))
             (caracteristica (car par))
             (respuesta-usuario (cdr par))
             (valor-real (obtener-valor hechos caracteristica)))
        (if (coincidencia-exacta? valor-real respuesta-usuario)
            (cons (list caracteristica respuesta-usuario) (explicar-hechos hechos (cdr respuestas)))
            (explicar-hechos hechos (cdr respuestas)))))))

; ============================================================
; REINICIO
; ============================================================

; reiniciar: devuelve el estado inicial vacio: sin respuestas y
; sin preguntas hechas. Python simplemente vuelve a usar estas
; listas vacias como punto de partida de una nueva partida.
(define (reiniciar) (list '() '()))
