# Stardew Akinator Protocol

## Version

The current protocol version is `1`. Every request and every response includes
the numeric field `version`.

Clients must reject responses with an unsupported version. The backend returns a
protocol error when a request omits `version` or sends a different version.

## Transport

- Transport: standard input and standard output.
- Encoding: UTF-8.
- Framing: one JSON object per line.
- Request direction: Python frontend to Racket backend.
- Response direction: Racket backend to Python frontend.

## Request: infer

The only supported action is `inferir`.

```json
{
  "version": 1,
  "accion": "inferir",
  "respuestas": [
    ["es-mujer", "si"],
    ["es-nino", "no"]
  ],
  "preguntadas": ["es-mujer", "es-nino"]
}
```

### Required fields

| Field | Type | Allowed values |
| --- | --- | --- |
| `version` | integer | `1` |
| `accion` | string | `"inferir"` |
| `respuestas` | array | Arrays containing `[feature, answer]` |
| `preguntadas` | array | Feature-name strings |

Each answer pair must contain two strings:

- Feature: one of the characteristics defined in
  [`Backend/motor.rkt`](../Backend/motor.rkt).
- Answer: `si`, `no`, `no-se`, `probablemente`, or `probablemente-no`.

The arrays preserve chronological order. `respuestas` must contain the answers
in the same order in which the questions were presented.

## Response: question

```json
{
  "version": 1,
  "tipo": "pregunta",
  "caracteristica": "le-gusta-mineria",
  "candidatos": 8
}
```

| Field | Type | Description |
| --- | --- | --- |
| `version` | integer | Protocol version. |
| `tipo` | string | `"pregunta"`. |
| `caracteristica` | string | Next feature to ask. |
| `candidatos` | integer | Number of active candidates. |

## Response: verdict

```json
{
  "version": 1,
  "tipo": "veredicto",
  "entidad": "abigail",
  "confianza": 0.83,
  "explicacion": [["es-mujer", "si"]]
}
```

When no character can be identified, `entidad` is `null` and `explicacion` is
an empty array.

| Field | Type | Description |
| --- | --- | --- |
| `version` | integer | Protocol version. |
| `tipo` | string | `"veredicto"`. |
| `entidad` | string or null | Predicted character identifier. |
| `confianza` | number | Value between `0` and `1`. |
| `explicacion` | array | Matching feature/answer pairs. |

## Response: error

```json
{
  "version": 1,
  "tipo": "error",
  "mensaje": "Versión de protocolo incompatible: 2; se esperaba 1."
}
```

Errors are returned for an unsupported protocol version, an unsupported action,
malformed JSON, or an inference failure. The frontend should display the
message and must not interpret an error as a question or verdict.

## Compatibility rules

The backend may add optional response fields in a compatible release. Changing
field types, allowed values, required fields, or response meanings requires a
new protocol version.
