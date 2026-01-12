/**
 * Stora Landing Page - Contact Form Handler
 * Form validation and submission to AWS SES via API Gateway
 */

(function() {
    'use strict';

    // Configuration - UPDATE THIS AFTER AWS API GATEWAY IS SET UP
    const API_ENDPOINT = 'https://xmr2xk8ksc.execute-api.us-east-1.amazonaws.com/prod/contact';
    
    const form = document.getElementById('contact-form');
    const formMessage = document.getElementById('form-message');

    if (!form) {
        console.error('Contact form not found');
        return;
    }

    /**
     * Validate email format
     */
    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    /**
     * Sanitize user input to prevent XSS
     */
    function sanitizeInput(input) {
        const div = document.createElement('div');
        div.textContent = input;
        return div.innerHTML;
    }

    /**
     * Show message to user
     */
    function showMessage(message, type) {
        formMessage.textContent = message;
        formMessage.className = `form-message ${type}`;
        formMessage.style.display = 'block';
        
        // Auto-hide success message after 5 seconds
        if (type === 'success') {
            setTimeout(() => {
                formMessage.style.display = 'none';
            }, 5000);
        }
    }

    /**
     * Disable/enable form during submission
     */
    function setFormLoading(isLoading) {
        const submitButton = form.querySelector('button[type="submit"]');
        const inputs = form.querySelectorAll('input, textarea, button');
        
        inputs.forEach(input => {
            input.disabled = isLoading;
        });
        
        if (isLoading) {
            submitButton.textContent = 'Enviando...';
        } else {
            submitButton.textContent = 'Solicitar demo';
        }
    }

    /**
     * Handle form submission
     */
    async function handleSubmit(e) {
        e.preventDefault();
        
        // Hide any previous messages
        formMessage.style.display = 'none';
        
        // Get form data
        const formData = {
            nombre: sanitizeInput(form.querySelector('#nombre').value.trim()),
            apellido: sanitizeInput(form.querySelector('#apellido').value.trim()),
            email: sanitizeInput(form.querySelector('#email').value.trim()),
            empresa: sanitizeInput(form.querySelector('#empresa').value.trim()),
            rubro: sanitizeInput(form.querySelector('#rubro').value.trim()),
            mensaje: sanitizeInput(form.querySelector('#mensaje').value.trim())
        };
        
        // Validate required fields
        if (!formData.nombre || !formData.apellido || !formData.email || 
            !formData.empresa || !formData.rubro || !formData.mensaje) {
            showMessage('Por favor, complete todos los campos.', 'error');
            return;
        }
        
        // Validate email format
        if (!isValidEmail(formData.email)) {
            showMessage('Por favor, ingrese un email válido.', 'error');
            return;
        }
        
        // Check if API endpoint is configured
        if (API_ENDPOINT === 'YOUR_API_GATEWAY_ENDPOINT_HERE') {
            console.warn('API Gateway endpoint not configured');
            showMessage(
                'Formulario de prueba: Los datos serían:\n' + 
                JSON.stringify(formData, null, 2), 
                'success'
            );
            console.log('Form data that would be sent:', formData);
            form.reset();
            return;
        }
        
        // Set loading state
        setFormLoading(true);
        
        try {
            // Send data to API Gateway endpoint
            const response = await fetch(API_ENDPOINT, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (response.ok) {
                showMessage(
                    '¡Gracias por contactarnos! Nos pondremos en contacto pronto.', 
                    'success'
                );
                form.reset();
                
                // Track conversion (if Google Analytics is set up)
                if (typeof gtag !== 'undefined') {
                    gtag('event', 'form_submission', {
                        'event_category': 'Contact',
                        'event_label': 'Demo Request'
                    });
                }
            } else {
                throw new Error(result.message || 'Error al enviar el formulario');
            }
        } catch (error) {
            console.error('Form submission error:', error);
            showMessage(
                'Hubo un error al enviar el formulario. Por favor, intente de nuevo o contáctenos directamente a info@storaapp.com', 
                'error'
            );
        } finally {
            setFormLoading(false);
        }
    }

    /**
     * Add real-time validation feedback
     */
    function addInputValidation() {
        const emailInput = form.querySelector('#email');
        
        emailInput.addEventListener('blur', function() {
            const email = this.value.trim();
            if (email && !isValidEmail(email)) {
                this.style.borderColor = '#F44336';
            } else {
                this.style.borderColor = '';
            }
        });
        
        emailInput.addEventListener('input', function() {
            if (this.style.borderColor === 'rgb(244, 67, 54)') {
                this.style.borderColor = '';
            }
        });
    }

    // Initialize
    form.addEventListener('submit', handleSubmit);
    addInputValidation();
    
    console.log('Contact form handler initialized');
})();
