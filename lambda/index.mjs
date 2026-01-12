/**
 * Stora Contact Form Lambda Handler
 * Processes form submissions and sends emails via AWS SES
 * Uses AWS SDK v3 (compatible with Node.js 18+)
 */

import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";

const sesClient = new SESClient({ region: "us-east-1" });

// Configuration
const RECIPIENT_EMAIL = "info@storaapp.com";
const FROM_EMAIL = "info@storaapp.com";

/**
 * Validate email format
 */
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Sanitize input to prevent injection
 */
function sanitizeInput(input) {
    if (typeof input !== 'string') return '';
    return input
        .replace(/[<>]/g, '')
        .trim()
        .substring(0, 1000); // Limit length
}

/**
 * Create HTML email body
 */
function createEmailBody(formData) {
    return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #022859; color: white; padding: 20px; text-align: center; }
        .content { background-color: #f9f9f9; padding: 20px; border: 1px solid #ddd; }
        .field { margin-bottom: 15px; }
        .label { font-weight: bold; color: #022859; }
        .value { margin-top: 5px; }
        .footer { margin-top: 20px; padding: 10px; text-align: center; font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>🔔 Nueva Solicitud de Demo - Stora</h2>
        </div>
        <div class="content">
            <div class="field">
                <div class="label">👤 Nombre:</div>
                <div class="value">${formData.nombre} ${formData.apellido}</div>
            </div>
            <div class="field">
                <div class="label">📧 Email:</div>
                <div class="value">${formData.email}</div>
            </div>
            <div class="field">
                <div class="label">🏢 Empresa:</div>
                <div class="value">${formData.empresa}</div>
            </div>
            <div class="field">
                <div class="label">🏷️ Rubro:</div>
                <div class="value">${formData.rubro}</div>
            </div>
            <div class="field">
                <div class="label">💬 Mensaje:</div>
                <div class="value">${formData.mensaje}</div>
            </div>
        </div>
        <div class="footer">
            <p>Este email fue enviado desde el formulario de contacto en storaapp.com</p>
            <p>Fecha: ${new Date().toLocaleString('es-CO', { timeZone: 'America/Bogota' })}</p>
        </div>
    </div>
</body>
</html>
    `.trim();
}

/**
 * Create plain text email body
 */
function createTextBody(formData) {
    return `
Nueva Solicitud de Demo - Stora
================================

Nombre: ${formData.nombre} ${formData.apellido}
Email: ${formData.email}
Empresa: ${formData.empresa}
Rubro: ${formData.rubro}

Mensaje:
${formData.mensaje}

---
Enviado desde: storaapp.com
Fecha: ${new Date().toLocaleString('es-CO', { timeZone: 'America/Bogota' })}
    `.trim();
}

/**
 * Lambda handler
 */
export const handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    // CORS headers
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'OPTIONS,POST',
        'Content-Type': 'application/json'
    };
    
    // Handle preflight request
    if (event.httpMethod === 'OPTIONS') {
        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({ message: 'OK' })
        };
    }
    
    try {
        // Parse request body
        let body;
        try {
            body = JSON.parse(event.body);
        } catch (parseError) {
            console.error('JSON parse error:', parseError);
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({
                    success: false,
                    message: 'Invalid request format'
                })
            };
        }
        
        // Sanitize and validate input
        const formData = {
            nombre: sanitizeInput(body.nombre),
            apellido: sanitizeInput(body.apellido),
            email: sanitizeInput(body.email),
            empresa: sanitizeInput(body.empresa),
            rubro: sanitizeInput(body.rubro),
            mensaje: sanitizeInput(body.mensaje)
        };
        
        // Validate required fields
        const requiredFields = ['nombre', 'apellido', 'email', 'empresa', 'rubro', 'mensaje'];
        for (const field of requiredFields) {
            if (!formData[field]) {
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({
                        success: false,
                        message: `El campo ${field} es requerido`
                    })
                };
            }
        }
        
        // Validate email format
        if (!isValidEmail(formData.email)) {
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({
                    success: false,
                    message: 'Email inválido'
                })
            };
        }
        
        // Prepare SES email parameters
        const emailParams = {
            Source: FROM_EMAIL,
            Destination: {
                ToAddresses: [RECIPIENT_EMAIL]
            },
            Message: {
                Subject: {
                    Data: `📋 Nueva solicitud de demo - ${formData.empresa}`,
                    Charset: 'UTF-8'
                },
                Body: {
                    Html: {
                        Data: createEmailBody(formData),
                        Charset: 'UTF-8'
                    },
                    Text: {
                        Data: createTextBody(formData),
                        Charset: 'UTF-8'
                    }
                }
            },
            ReplyToAddresses: [formData.email]
        };
        
        // Send email via SES
        console.log('Sending email via SES...');
        const command = new SendEmailCommand(emailParams);
        const result = await sesClient.send(command);
        
        console.log('Email sent successfully:', result.MessageId);
        
        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                message: 'Email enviado correctamente',
                messageId: result.MessageId
            })
        };
        
    } catch (error) {
        console.error('Error processing request:', error);
        
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
                success: false,
                message: 'Error al procesar la solicitud',
                error: error.message
            })
        };
    }
};
