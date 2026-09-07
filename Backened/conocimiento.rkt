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
; LAS 20 CARACTERISTICAS USADAS (documentar en el informe tecnico)
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
      (es-npc si) (es-soltero si) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria si) (le-gusta-arte si) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon no)
      (es-forastero no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no) (es-hijo-unico si))

    (alex
      (es-npc si) (es-soltero si) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (tiene-hijos no)
      (trabaja-en-saloon no) (es-forastero no) (le-gusta-cocinar no)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (elliott
      (es-npc si) (es-soltero si) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar si)
      (le-gusta-mineria no) (le-gusta-arte si) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon no)
      (es-forastero si) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no))

    (emily
      (es-npc si) (es-soltero si) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte si) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon si)
      (le-gusta-cocinar no) (usa-silla-de-ruedas no) (es-magico-o-misterioso si)
      (es-hijo-unico no))

    (haley
      (es-npc si) (es-soltero si) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte si) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon no)
      (es-forastero no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no) (es-hijo-unico no))

    (harvey
      (es-npc si) (es-soltero si) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina si) (esta-casado no) (trabaja-en-saloon no)
      (es-forastero no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no))

    (leah
      (es-npc si) (es-soltero si) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte si) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon no)
      (es-forastero si) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no))

    (maru
      (es-npc si) (es-soltero si) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana si)
      (tiene-tienda no) (le-gusta-pescar no) (le-gusta-mineria si)
      (le-gusta-arte no) (cria-animales no) (trabaja-en-medicina si)
      (esta-casado no) (tiene-hijos no) (trabaja-en-saloon no)
      (le-gusta-cocinar no) (usa-silla-de-ruedas no) (es-magico-o-misterioso no)
      (es-hijo-unico no))

    (penny
      (es-npc si) (es-soltero si) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (tiene-hijos no)
      (trabaja-en-saloon no) (es-forastero no) (le-gusta-cocinar no)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no) (es-hijo-unico si))

    (sam
      (es-npc si) (es-soltero si) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte si) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon no)
      (es-forastero no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no) (es-hijo-unico no))

    (sebastian
      (es-npc si) (es-soltero si) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana si)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon no)
      (es-forastero no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no) (es-hijo-unico no))

    (shane
      (es-npc si) (es-soltero si) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja si) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales si)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon no)
      (es-forastero no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no))

    (caroline
      (es-npc si) (es-soltero no) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado si) (tiene-hijos si)
      (trabaja-en-saloon no) (es-forastero no) (le-gusta-cocinar no)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (clint
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda si) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria si) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (trabaja-en-saloon no)
      (le-gusta-cocinar no) (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (demetrius
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana si)
      (tiene-tienda no) (le-gusta-pescar no) (le-gusta-mineria si)
      (le-gusta-arte no) (cria-animales no) (trabaja-en-medicina no)
      (esta-casado si) (tiene-hijos si) (trabaja-en-saloon no)
      (le-gusta-cocinar no) (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (evelyn
      (es-npc si) (es-soltero no) (es-mujer si)
      (es-nino no) (es-anciano si) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado si) (tiene-hijos si)
      (trabaja-en-saloon no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no))

    (george
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano si) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado si) (tiene-hijos no)
      (trabaja-en-saloon no) (le-gusta-cocinar no) (usa-silla-de-ruedas si)
      (es-magico-o-misterioso no))

    (gus
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda si) (le-gusta-pescar no) (le-gusta-mineria no)
      (le-gusta-arte no) (cria-animales no) (trabaja-en-medicina no)
      (esta-casado no) (trabaja-en-saloon si) (le-gusta-cocinar si)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (jas
      (es-npc si) (es-soltero no) (es-mujer si)
      (es-nino si) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (tiene-hijos no)
      (trabaja-en-saloon no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no) (es-hijo-unico si))

    (jodi
      (es-npc si) (es-soltero no) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado si) (tiene-hijos si)
      (trabaja-en-saloon no) (es-forastero no) (le-gusta-cocinar si)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (kent
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado si) (tiene-hijos si)
      (trabaja-en-saloon no) (es-forastero no) (le-gusta-cocinar no)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (lewis
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano si) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (tiene-hijos no)
      (trabaja-en-saloon no) (es-forastero no) (le-gusta-cocinar no)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (linus
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana si)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (tiene-hijos no)
      (trabaja-en-saloon no) (es-forastero si) (le-gusta-cocinar no)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (marnie
      (es-npc si) (es-soltero no) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda si) (le-gusta-pescar no) (le-gusta-mineria no)
      (le-gusta-arte no) (cria-animales si) (trabaja-en-medicina no)
      (esta-casado no) (tiene-hijos no) (trabaja-en-saloon no)
      (le-gusta-cocinar no) (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (pam
      (es-npc si) (es-soltero no) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (tiene-hijos si)
      (trabaja-en-saloon no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no))

    (pierre
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda si) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado si) (tiene-hijos si)
      (trabaja-en-saloon no) (es-forastero no) (le-gusta-cocinar no)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (robin
      (es-npc si) (es-soltero no) (es-mujer si)
      (es-nino no) (es-anciano no) (vive-en-la-montana si)
      (tiene-tienda si) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado si) (tiene-hijos si)
      (trabaja-en-saloon no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no))

    (vincent
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino si) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (tiene-hijos no)
      (trabaja-en-saloon no) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso no) (es-hijo-unico no))

    (willy
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda si) (le-gusta-pescar si) (le-gusta-mineria no)
      (le-gusta-arte no) (cria-animales no) (trabaja-en-medicina no)
      (esta-casado no) (trabaja-en-saloon no) (es-forastero si)
      (le-gusta-cocinar no) (usa-silla-de-ruedas no) (es-magico-o-misterioso no))

    (wizard
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda no) (le-gusta-pescar no) (le-gusta-mineria no)
      (le-gusta-arte no) (cria-animales no) (trabaja-en-medicina no)
      (esta-casado no) (tiene-hijos no) (trabaja-en-saloon no)
      (es-forastero si) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso si))

    (krobus
      (es-npc si) (es-soltero si) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda si) (trabaja-en-joja no) (le-gusta-pescar no)
      (le-gusta-mineria no) (le-gusta-arte no) (cria-animales no)
      (trabaja-en-medicina no) (esta-casado no) (tiene-hijos no)
      (trabaja-en-saloon no) (es-forastero si) (le-gusta-cocinar no)
      (usa-silla-de-ruedas no) (es-magico-o-misterioso si))

    (enano
      (es-npc si) (es-soltero no) (es-mujer no)
      (es-nino no) (es-anciano no) (vive-en-la-montana no)
      (tiene-tienda si) (le-gusta-pescar no) (le-gusta-mineria si)
      (le-gusta-arte no) (cria-animales no) (trabaja-en-medicina no)
      (esta-casado no) (tiene-hijos no) (trabaja-en-saloon no)
      (es-forastero si) (le-gusta-cocinar no) (usa-silla-de-ruedas no)
      (es-magico-o-misterioso si))))