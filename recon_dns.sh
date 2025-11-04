#!/usr/bin/env bash
# recon_domain.sh
# Autor: JCFM
# Versión: ampliada y mejorada (muestra comando y limpia pantalla)
# -------------------------------------

set -u
clear

# === 1) Pedir dominio ===
read -rp "Dominio a investigar: " DOMAIN

# === 2) Pedir ruta de salida ===
read -rp "Ruta y nombre del fichero de salida (ej: ./resultados/mi_dominio_result.txt): " OUTFILE
OUTDIR=$(dirname "$OUTFILE")

# Crear el directorio si no existe
if [ ! -d "$OUTDIR" ]; then
  echo "El directorio '$OUTDIR' no existe. Creándolo..."
  mkdir -p "$OUTDIR" || { echo "❌ Error: no se pudo crear el directorio."; exit 1; }
fi

# Confirmar sobrescritura
if [ -e "$OUTFILE" ]; then
  read -rp "El fichero '$OUTFILE' ya existe. ¿Sobrescribir? [y/N]: " CONF
  case "$CONF" in
    [Yy]*) : ;; 
    *) echo "Cancelado."; exit 1 ;;
  esac
fi

# === 3) Encabezado ===
{
  echo "========================================"
  echo "INFORME DE RECONOCIMIENTO DE DOMINIO"
  echo "========================================"
  echo "Dominio: $DOMAIN"
  echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "========================================"
  echo
} > "$OUTFILE"

# === Función para agregar secciones con comando visible ===
run_section () {
  local title="$1"
  shift
  local cmd_display="$*"
  echo ">>> $title  [comando: $cmd_display]" >> "$OUTFILE"
  echo "----------------------------------------" >> "$OUTFILE"
  "$@" >> "$OUTFILE" 2>&1
  echo -e "\n" >> "$OUTFILE"
}

# === 4) WHOIS ===
run_section "Información WHOIS" whois "$DOMAIN"

# === 5) DNS básico ===
run_section "Registros A (IPv4)" dig "$DOMAIN" A +short
run_section "Registros AAAA (IPv6)" dig "$DOMAIN" AAAA +short
run_section "Servidores de correo (MX)" dig "$DOMAIN" MX +short
run_section "Servidores de nombres (NS)" dig "$DOMAIN" NS +short
run_section "Registros TXT" dig "$DOMAIN" TXT +short
run_section "Registro SOA" dig "$DOMAIN" SOA +noall +authority

# === 6) DNSSEC y TRACE ===
run_section "DNSSEC (firmas, RRSIG, AD flag)" dig +dnssec "$DOMAIN"
run_section "Traza DNS completa (desde raíz)" dig +trace "$DOMAIN"

# === 7) Reverse lookup de la IP principal ===
FIRST_IP=$(dig "$DOMAIN" A +short | head -n1)
if [ -n "$FIRST_IP" ]; then
  run_section "Reverse lookup (PTR) para $FIRST_IP" dig -x "$FIRST_IP" +short
else
  echo ">>> No se encontró registro A para reverse lookup." >> "$OUTFILE"
  echo >> "$OUTFILE"
fi

# === 8) Información SSL/TLS (si hay HTTPS) ===
echo ">>> Análisis SSL/TLS  [comando: openssl s_client -connect $DOMAIN:443 -servername $DOMAIN | openssl x509 -noout -issuer -subject -dates]" >> "$OUTFILE"
echo "----------------------------------------" >> "$OUTFILE"
openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" < /dev/null 2>/dev/null \
  | openssl x509 -noout -issuer -subject -dates >> "$OUTFILE"
echo -e "\n" >> "$OUTFILE"

# === 9) Cierre ===
echo "========================================" >> "$OUTFILE"
echo "FIN DEL INFORME" >> "$OUTFILE"
echo "========================================" >> "$OUTFILE"

# === 10) Limpiar pantalla y mostrar resumen ===
clear
echo "=== ✅ Informe generado en: $OUTFILE ==="
echo
cat "$OUTFILE"
