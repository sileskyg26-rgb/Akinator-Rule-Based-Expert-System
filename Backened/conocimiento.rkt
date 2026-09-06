#lang racket

(provide conocimiento)

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

    (enano
      (es-npc si) (es-soltero no) (es-mujer si) (es-magico-o-misterioso si)
      (tiene-tienda si) (le-gusta-mineria si) (es-forastero si)
      (esta-casado no) (tiene-hijos no) (vive-en-la-montana no))))