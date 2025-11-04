# 🕵️‍♂️ Recon Domain — Herramienta básica de reconocimiento de dominios

**Autor:** JCFM
**Versión:** 1.2 (2025-11-04)  
**Licencia:** Uso educativo y personal  

---

## 📖 Descripción

`recon_domain.sh` es un script en **Bash** para realizar una recopilación de información inicial (reconocimiento pasivo) sobre un dominio.  
Reúne datos DNS, WHOIS y SSL/TLS y los guarda en un informe legible, con todos los comandos ejecutados documentados entre paréntesis.  

Está pensado para **estudiantes de ciberseguridad** y **auditores** que deseen automatizar tareas básicas de enumeración sin depender de herramientas externas complejas.

---

## 🧩 Funcionalidades principales

- 🔍 Consulta **WHOIS** completa del dominio.  
- 🌐 Obtención de registros DNS (`A`, `AAAA`, `MX`, `NS`, `TXT`, `SOA`).  
- 🔒 Verificación de **DNSSEC** y traza de resolución (`dig +trace`).  
- ↩️ Consulta **inversa (PTR)** sobre la IP principal.  
- 🔑 Análisis **SSL/TLS** (emisor, sujeto y fechas de validez del certificado).  
- 🧱 Estructura clara: cada sección muestra el **comando ejecutado**.  
- 🧽 Limpieza visual (`clear` antes del informe final).  
- 📁 Crea automáticamente el directorio de salida si no existe.  

---

## 🧰 Requisitos

- Bash 4.x o superior  
- Herramientas disponibles en la mayoría de distribuciones Linux o macOS:
  - `whois`
  - `dig` (paquete `dnsutils`)
  - `openssl`

En Debian/Ubuntu puedes instalarlas con:

```bash
sudo apt update
sudo apt install whois dnsutils openssl

