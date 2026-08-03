# Servidores MCP del proyecto

El archivo [`.mcp.json`](../.mcp.json) en la raíz define los servidores MCP que
Claude Code carga automáticamente al abrir este repositorio. Son tres:

| Servidor            | Para qué sirve                                  | Runtime  |
| ------------------- | ----------------------------------------------- | -------- |
| `desktop-commander` | Control del sistema de archivos / terminal      | npx      |
| `xtuple-mdm`        | Script local de xTuple MDM                       | Python   |
| `omi`               | Servidor MCP de Omi (memoria / contexto)         | Docker   |

## Requisitos

- **desktop-commander** — Node.js (usa `npx`, se descarga solo la primera vez).
- **xtuple-mdm** — Python 3.11 y el script `xtuple_mcp_server.py` en tu máquina.
- **omi** — Docker corriendo, con la imagen `omiai/mcp-server`.

## La API key va por variable de entorno (NO en el repo)

La `OMI_API_KEY` **no** está en `.mcp.json`. El config la lee de tu entorno con
`${OMI_API_KEY}`, así no queda expuesta en GitHub. Defínela en tu máquina:

**Windows (PowerShell):**

```powershell
setx OMI_API_KEY "tu_api_key_de_omi"
```

**macOS / Linux (bash/zsh):** agrégalo a `~/.zshrc` o `~/.bashrc`:

```sh
export OMI_API_KEY="tu_api_key_de_omi"
```

> Si tu key estuvo alguna vez en texto plano en un repo o chat, **rótala** en
> Omi y usa la nueva aquí.

## Nota sobre las rutas (Windows vs. Mac)

Las rutas de `xtuple-mdm` (`C:/Users/juanr/...`) y el `cmd /c` de
`desktop-commander` son específicas de **Windows**. En macOS tendrías que
ajustar `.mcp.json`:

- `desktop-commander`: usar `"command": "npx"` (sin `"cmd", "/c"`).
- `xtuple-mdm`: cambiar la ruta al `python3` y al script en tu Mac,
  p. ej. `"command": "python3"`, `"args": ["/Users/juanribot/.../xtuple_mcp_server.py"]`.

## Verificar

Con Claude Code abierto en este repo, corre `/mcp` para ver el estado de los
servidores (conectados / con error).
