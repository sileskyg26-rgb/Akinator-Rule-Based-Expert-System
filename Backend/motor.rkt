#lang racket

(require "conocimiento.rkt")
(require "reglas.rkt")

(provide inferir explicar reiniciar)

; ============================================================
; Motor de inferencia - Akinator Stardew Valley
; EIF-400 Paradigmas de Programacion
; ============================================================
;
; Este archivo importa:
;   - conocimiento.rkt  (define 'conocimiento')
;   - reglas.rkt        (define 'reglas', 'obtener-valor' y
;                       'aplicar-reglas-a-base')
;
; Ejecucion:
;   racket motor.rkt        -> arranca el servidor JSON
;   En DrRacket: abrir motor.rkt y Run.
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

; Lista de las 21 caracteristicas usadas en el dominio (deben
; coincidir exactamente con las de conocimiento.rkt)
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

; ------------------------------------------------------------
; mejor-caracteristica: en vez de elegir siempre la UNICA mejor
; (lo cual hace que la primera pregunta de cada partida sea
; siempre identica), junta TODAS las caracteristicas cuyo
; balance este cerca del minimo (dentro de 'margen-empate') y
; elige una al azar entre esas. Le da variedad a las partidas sin
; sacrificar calidad, porque solo se sortea entre las mejores.
; ------------------------------------------------------------
(define margen-empate 2)

(define (balance-minimo caracteristicas entidades-activas)
  (cond
    ((null? caracteristicas) +inf.0)
    ((null? (cdr caracteristicas)) (balance (car caracteristicas) entidades-activas))
    (else (min (balance (car caracteristicas) entidades-activas)
               (balance-minimo (cdr caracteristicas) entidades-activas)))))

(define (caracteristicas-cercanas-al-minimo caracteristicas entidades-activas minimo)
  (cond
    ((null? caracteristicas) '())
    ((<= (balance (car caracteristicas) entidades-activas) (+ minimo margen-empate))
      (cons (car caracteristicas)
            (caracteristicas-cercanas-al-minimo (cdr caracteristicas) entidades-activas minimo)))
    (else (caracteristicas-cercanas-al-minimo (cdr caracteristicas) entidades-activas minimo))))

(define (elegir-al-azar lista)
  (list-ref lista (random (length lista))))

(define (mejor-caracteristica caracteristicas entidades-activas)
  (if (null? caracteristicas)
      #f
      (let* ((minimo (balance-minimo caracteristicas entidades-activas))
             (mejores (caracteristicas-cercanas-al-minimo caracteristicas entidades-activas minimo)))
        (elegir-al-azar mejores))))

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

(define umbral-confianza 0.55)
(define umbral-incertidumbre 0.3)
(define maximo-preguntas 15)

; minimo-preguntas: no se permite dar veredicto (por alta que sea
; la confianza calculada) antes de haber hecho al menos esta
; cantidad de preguntas. Esto evita el caso de un EMPATE
; temprano: con muy pocas respuestas, varios candidatos distintos
; pueden quedar con el mismo puntaje exacto, y la formula de
; confianza da matematicamente 0.5 (mitad y mitad) -- que cruzaria
; el umbral por pura coincidencia numerica, no porque el sistema
; realmente identifico a alguien.
(define minimo-preguntas 12)

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
            ((and (>= confianza umbral-confianza) (>= num-respondidas minimo-preguntas))
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


; ############################################################
; ADAPTADOR JSON - puente entre Python y el motor de inferencia
; ############################################################
;
; Protocolo: un mensaje JSON por linea (stdin/stdout)
;
; Entrada (Python -> Scheme):
;   {"accion":"inferir",
;    "respuestas":[["es-mujer","si"],["es-nino","no"]],
;    "preguntadas":["es-mujer","es-nino"]}
;
; Salida (Scheme -> Python), segun el estado:
;   {"tipo":"pregunta","caracteristica":"es-soltero","candidatos":18}
;   {"tipo":"veredicto","entidad":"abigail","confianza":0.83,
;    "explicacion":[["es-mujer","si"],["le-gusta-mineria","si"]]}
;   {"tipo":"veredicto","entidad":null,"confianza":0.31,"explicacion":[]}
;   {"tipo":"error","mensaje":"..."}
;
; Las respuestas viajan como LISTA de pares (no como objeto JSON)
; para preservar el orden cronologico, que el descarte permanente
; necesita para calcular las sumas parciales en orden.
; ############################################################

(require json)

; ------------------------------------------------------------
; json->par: convierte ["es-mujer","si"] en el par
; (es-mujer . si) que usa el motor de inferencia.
; ------------------------------------------------------------
(define (json->par p)
  (cons (string->symbol (car p)) (string->symbol (cadr p))))

; ------------------------------------------------------------
; explicacion->json: convierte la lista de evidencias del motor
; en pares de strings para JSON.
; ------------------------------------------------------------
(define (explicacion->json evidencia)
  (map (lambda (e) (list (symbol->string (car e))
                         (symbol->string (cadr e))))
       evidencia))

; ------------------------------------------------------------
; resultado->json: traduce el veredicto del motor a JSON.
; Si el veredicto es 'ninguno, la entidad va como null (#f)
; y no se llama explicar.
; ------------------------------------------------------------
(define (resultado->json res respuestas)
  (if (eq? (car res) 'pregunta)
      (hash 'tipo "pregunta"
            'caracteristica (symbol->string (cadr res))
            'candidatos (caddr res))
      (let ((nombre (cadr res))
            (confianza (exact->inexact (caddr res))))
        (if (eq? nombre 'ninguno)
            (hash 'tipo "veredicto"
                  'entidad #f
                  'confianza confianza
                  'explicacion '())
            (hash 'tipo "veredicto"
                  'entidad (symbol->string nombre)
                  'confianza confianza
                  'explicacion (explicacion->json (explicar nombre respuestas)))))))

; ------------------------------------------------------------
; procesar-mensaje: parsea una linea JSON, ejecuta inferir y
; devuelve la linea JSON de respuesta.
; ------------------------------------------------------------
(define (procesar-mensaje linea)
  (let* ((msg (string->jsexpr linea))
         (respuestas (map json->par (hash-ref msg 'respuestas '())))
         (preguntadas (map string->symbol (hash-ref msg 'preguntadas '()))))
    (jsexpr->string (resultado->json (inferir respuestas preguntadas) respuestas))))

; ------------------------------------------------------------
; servidor: ciclo principal. Lee una linea, responde una linea.
; El flush-output es OBLIGATORIO: sin el, Python se queda
; esperando forever porque la salida queda bufferizada.
; ------------------------------------------------------------
(define (servidor)
  (let loop ()
    (let ((linea (read-line (current-input-port) 'any)))
      (unless (eof-object? linea)
        (with-handlers ((exn:fail?
                         (lambda (e)
                           (displayln (jsexpr->string
                                       (hash 'tipo "error"
                                             'mensaje (exn-message e))))
                           (flush-output (current-output-port)))))
          (displayln (procesar-mensaje linea))
          (flush-output (current-output-port)))
        (loop)))))

(module+ main
  (servidor))