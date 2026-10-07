# AWS + Lambda Integration (Image Processor)

Este proyecto implementa una arquitectura Serverless orientada a eventos en AWS para el procesamiento de imágenes, gestionada mediante Terraform. Cumple con los requerimientos de la tarea, desplegándose en 3 entornos (DEV, QA, PROD) de manera independiente.

##  Descripción de la Arquitectura

1. **API Gateway (HTTP API v2)**: Expone un endpoint `POST /upload`.
2. **Upload Lambda**: Recibe la imagen y la guarda en un bucket privado de **S3** (en el prefijo `uploads/`).
3. **S3 Event Notification**: Al guardar el archivo original, S3 envía una notificación a una cola **SQS** principal.
4. **Crop Lambda**: Es disparada por la cola SQS mediante un *Event Source Mapping*. Lee la imagen original, ejecuta la lógica de "crop" y guarda el resultado en el prefijo `processed/`.
5. **Red**: Todo el procesamiento se realiza en subredes privadas dentro de una **VPC** usando **VPC Endpoints** (Gateway para S3 e Interface para SQS) para no salir a internet. Se implementó el principio de Menor Privilegio (Least Privilege) en IAM.

*Nota sobre Crop Lambda*: Para facilitar el empaquetado de Terraform y cumplir con la consigna, la función `crop-lambda` tiene implementada una base funcional donde la librería `sharp` puede ser incluida.

##  Requisitos Previos

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) instalado (v1.5+).
- [AWS CLI](https://aws.amazon.com/cli/) instalado y configurado con AWS SSO.
- Node.js 20.x y npm (opcional, para testear código Lambda localmente).

## Configuración del Perfil AWS SSO

El proyecto está configurado para utilizar el perfil de AWS SSO llamado `agupao`. Asegúrate de tener iniciada tu sesión antes de ejecutar Terraform:

```bash
aws sso login --profile agupao
```

*(Si necesitas cambiar el perfil, actualiza el bloque `provider "aws"` en los archivos `main.tf` de cada entorno).*

##  Flujo de Trabajo y Evidencias por Entorno

Para cumplir con los requerimientos de control de versiones y evidencias, este proyecto sigue una estructura específica. Las ejecuciones de Terraform deben registrarse en la carpeta `evidencias/` separada por entornos (`dev/`, `qa/`, `prod/`).

### Flujo de commits sugerido

Se recomienda seguir este orden exacto al ejecutar y subir los cambios a GitHub:

- `feat: estructura base`
- `deploy: ejecución entorno dev`
- `destroy: limpieza entorno dev`
- `deploy: ejecución entorno qa`
- `destroy: limpieza entorno qa`
- `deploy: ejecución entorno prod`
- `destroy: limpieza entorno prod`
- `docs: evidencias finales`

---

### Instrucciones para DEV

1. Inicializar y aplicar (guardando evidencia):
   ```powershell
   cd iac\envs\dev
   terraform init
   terraform apply -auto-approve | Tee-Object -FilePath "..\..\..\evidencias\dev\apply-dev.txt"
   ```
2. **Tomar capturas de pantalla** de: Lambda, S3, SQS y API Gateway creados en AWS.
3. Destruir recursos (guardando evidencia):
   ```powershell
   terraform destroy -auto-approve | Tee-Object -FilePath "..\..\..\evidencias\dev\destroy-dev.txt"
   ```

### Instrucciones para QA

1. Inicializar y aplicar (guardando evidencia):
   ```powershell
   cd iac\envs\qa
   terraform init
   terraform apply -auto-approve | Tee-Object -FilePath "..\..\..\evidencias\qa\apply-qa.txt"
   ```
2. **Tomar capturas de pantalla** de: Lambda, S3, SQS y API Gateway creados en AWS.
3. Destruir recursos (guardando evidencia):
   ```powershell
   terraform destroy -auto-approve | Tee-Object -FilePath "..\..\..\evidencias\qa\destroy-qa.txt"
   ```

### Instrucciones para PROD

1. Inicializar y aplicar (guardando evidencia):
   ```powershell
   cd iac\envs\prod
   terraform init
   terraform apply -auto-approve | Tee-Object -FilePath "..\..\..\evidencias\prod\apply-prod.txt"
   ```
2. **Tomar capturas de pantalla** de: Lambda, S3, SQS y API Gateway creados en AWS.
3. Destruir recursos (guardando evidencia):
   ```powershell
   terraform destroy -auto-approve | Tee-Object -FilePath "..\..\..\evidencias\prod\destroy-prod.txt"
   ```

##  Cómo probar POST /upload

Una vez desplegado un entorno, usa la URL generada (`api_gateway_url`) para subir una imagen en base64:

```bash
# Ejemplo usando cURL con JSON (asegúrate de reemplazar LA_URL_AQUI)
curl -X POST LA_URL_AQUI/upload \
  -H "Content-Type: application/json" \
  -d '{"type":"image/png","image":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="}'
```

La respuesta será un HTTP 200 confirmando la subida exitosa y la clave S3 generada.
