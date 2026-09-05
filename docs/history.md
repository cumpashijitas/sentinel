# Sentinel V2 — historial y estadísticas básicas (Fase 9)

Tres pantallas de solo lectura sobre datos que el resto de la app ya
produce: viajes finalizados, eventos de accidente propios, y un puñado de
números derivados de ambos. Nada en esta fase escribe nada — es la
contraparte de "ver" a todo lo construido en las Fases 1–8.

## Qué NO es esta fase

No hay paginación (las listas son por usuario y, en el uso real de la app,
chicas — mismo argumento que ya usan `myGroupsProvider`/
`emergencyContactsProvider`, ver `docs/architecture.md`), no hay filtros ni
búsqueda, y las "estadísticas básicas" son exactamente eso: conteos y sumas
simples, no analítica.

## Entidades y de dónde salen

| Entidad | Tabla(s) | Quién la arma |
|---|---|---|
| `RideHistoryEntry` (`features/rides/domain/entities/`) | `ride_session_members` → `ride_sessions` → `ride_groups` | `RideSessionRepositoryImpl.fetchHistory` |
| `AccidentEvent` (ya existía, Fase 7) | `accident_events` | `AccidentEventRepositoryImpl.fetchMine`/`fetchById` |
| `RideStatistics` (`features/history/domain/entities/`) | — (derivada, no persistida) | `RideStatisticsCalculator.compute` |

`RideHistoryEntry` vive en `features/rides/`, no en `features/history/`:
`ride_sessions`/`ride_session_members` ya son responsabilidad de
`RideSessionRepository` (Fase 4), así que el historial es un método más de
ese mismo repositorio (`fetchHistory`), no una tabla nueva que justifique
un repositorio propio. `features/history/` solo contiene lo que de verdad
es nuevo en esta fase: las páginas, los providers que combinan ambos
repositorios, y `RideStatistics`/`RideStatisticsCalculator`.

## `fetchHistory`: un embed anidado de PostgREST, no tres consultas

A diferencia de `GroupRepositoryImpl.fetchMembers`/
`RideSessionRepositoryImpl.fetchParticipants` (que arman el resultado en
Dart a partir de dos consultas porque `ride_group_members`/
`ride_session_members` no tienen FK directa a `profiles`), aquí sí hay una
cadena de FKs real: `ride_session_members.session_id → ride_sessions.id` y
`ride_sessions.group_id → ride_groups.id`. Eso permite un único `select`
con embed anidado:

```dart
_client
    .from('ride_session_members')
    .select('session_id, ride_sessions(*, ride_groups(name))')
    .eq('user_id', userId);
```

PostgREST resuelve las dos relaciones en una sola consulta SQL; verificado
en vivo contra el stack local (no solo con fakes — ver "Qué se verificó en
vivo" más abajo). RLS se aplica normalmente a cada tabla embebida: una fila
cuya `ride_sessions` ya no sea visible para el caller (p. ej. abandonó el
grupo) embebe como `null` en vez de romper la consulta completa —
`fetchHistory` filtra esas filas en Dart en lugar de asumir que el embed
siempre está presente.

Filtro y orden (`status == 'finished'`, más reciente primero) se hacen en
Dart, no en la query, a propósito: `ride_session_status` incluye
`'cancelled'`, pero ningún código de este repo lo produce todavía (no
existe un RPC "cancelar sesión en espera" — ver `docs/database.md`), así
que `fetchHistory` lo excluye en vez de mostrarle al usuario un estado que
el producto nunca alcanza. Si en el futuro se agrega esa RPC, esta es la
única línea que hay que tocar.

## Estadísticas: calculadas en el cliente, no una RPC nueva

`RideStatisticsCalculator.compute(rides, accidents)` es una función pura
— mismo espíritu que `MemberTrackingService`/`AccidentDetectionService` —
que recibe las listas que las otras dos pestañas ya cargan y devuelve
`RideStatistics` (viajes completados, tiempo total, accidentes
"reales"). Deliberadamente no hay una RPC `get_ride_statistics()`: ambas
listas ya están completas en memoria para las pestañas de Viajes/
Accidentes, así que sumar del lado del servidor sería un segundo viaje de
red para recalcular algo que el cliente ya tiene. Reconsiderar si el
historial llega a crecer lo suficiente como para que traerlo completo deje
de ser razonable (mismo punto de revisión que la falta de paginación,
arriba).

"Accidentes" en las estadísticas cuenta solo `confirmed`/`notified`/
`resolved` — un `candidate` descartado con "Estoy bien" (`cancelled`) fue
una falsa alarma, no un accidente, y no debe inflar el número.

## Pantallas

- **`HistoryPage`** (`/history`): tres tabs (`TabBar`/`TabBarView` sobre
  `DefaultTabController`) — Viajes, Accidentes, Estadísticas. Cada tab
  observa su propio provider (`rideHistoryProvider`/
  `accidentHistoryProvider`/`rideStatisticsProvider`) de forma
  independiente.
- **`AccidentDetailPage`** (`/accidents/:id`): detalle de un
  `accident_event` — estado, impacto/G-force/velocidad/confianza si están
  presentes, coordenadas (texto plano, sin mapa embebido — ver deuda
  técnica), y un botón "Ver viaje" si el evento tiene `session_id`.
  Alcanzable tanto desde la pestaña de Accidentes como por link directo
  (`context.push('/accidents/$id')`), útil para un futuro deep link desde
  una notificación push real.

Ambas reemplazan los `PlaceholderPage` que el router ya tenía reservados
para estas rutas desde el arranque del proyecto.

## `AccidentEventRepository`: ahora también expone lectura

Fase 7 solo necesitaba escribir `accident_events` (`reportCandidate`/
`cancel`/`confirm`), siempre construido a mano
(`AccidentEventRepositoryImpl(...)`) dentro del engine de background o el
handler de notificaciones — ninguno de los dos corre dentro del árbol de
widgets, así que no había necesidad de un provider de Riverpod. Esta fase
agrega `fetchMine`/`fetchById` al mismo repositorio (no uno nuevo — sigue
siendo la única puerta de entrada a esa tabla) y, por primera vez, un
provider real (`accident_event_providers.dart`) para el código que sí
corre dentro del árbol de widgets.

## Qué se verificó en vivo

La query de `fetchHistory` (embed anidado de dos niveles) se probó contra
Supabase local real, no solo con fakes: se insertó una `ride_sessions`
`finished` de prueba y se confirmó vía REST (`service_role`, para aislar la
verificación estructural de RLS) que PostgREST devuelve
`ride_sessions.ride_groups.name` correctamente anidado, con la sesión
`active` ya sembrada por `seed.sql` presente en el mismo resultado — la
fila de prueba se eliminó después de verificar.

## Deuda técnica

- **`AccidentDetailPage` no muestra un mapa ni un link externo para la
  ubicación**: solo texto plano (`lat, lng`). No se agregó `url_launcher`
  para esto — es una dependencia nueva para un solo botón "abrir en Maps",
  y esta fase ya reutiliza `google_maps_flutter` en ningún lado. Candidato
  razonable si se vuelve a tocar esta pantalla.
- **El botón "Ver viaje" de un viaje del historial reutiliza
  `RideSessionPage`, que muestra "Sin participantes" para una sesión
  `finished`**: `fetchParticipants` filtra `status = 'active'` en la
  consulta — correcto para el mapa en vivo (Fase 5: nunca mostrar a
  alguien que ya no comparte ubicación), pero significa que no hay forma
  de ver el roster *histórico* de quién participó. No se tocó
  `fetchParticipants` para no arriesgar ese caso de uso real por uno nuevo;
  una pantalla de detalle de viaje finalizado dedicada queda pendiente.
- **Sin paginación** (ver "Qué NO es esta fase").
- Deuda heredada de fases anteriores sin cambios en esta: ver
  `docs/alerts.md` (credenciales de proveedor, `PushTokenSource` real) y
  `docs/database.md` (retención de `location_history`/`alerts`).
