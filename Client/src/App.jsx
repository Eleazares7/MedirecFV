import React, { useState } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [step, setStep] = useState('email'); // 'email' o 'verify'
  const [message, setMessage] = useState('');

  // Enviar el email para recibir el OTP
  const handleSendOTP = async (e) => {
    e.preventDefault();
    setMessage('');
    try {
      const response = await axios.post('http://localhost:3000/2fa/send', { email });
      if (response.data.success) {
        setStep('verify');
        setMessage('Código enviado a tu correo. Revisa tu bandeja de entrada o spam.');
      }
    } catch (error) {
      setMessage('Error al enviar el código: ' + error.response?.data?.error || error.message);
    }
  };

  // Verificar el código OTP
  const handleVerifyOTP = async (e) => {
    e.preventDefault();
    setMessage('');
    try {
      const response = await axios.post('http://localhost:3000/2fa/verify', { email, code });
      if (response.data.success) {
        setMessage('¡Verificación exitosa! Bienvenido.');
        // Aquí podrías redirigir al usuario o realizar otra acción
      } else {
        setMessage('Código inválido. Intenta de nuevo.');
      }
    } catch (error) {
      setMessage('Error al verificar: ' + error.response?.data?.error || error.message);
    }
  };

  return (
    <div className="App">
      <h1>Verificación en Dos Pasos</h1>

      {step === 'email' ? (
        <form onSubmit={handleSendOTP}>
          <label>
            Correo Electrónico:
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="tu_correo@example.com"
              required
            />
          </label>
          <button type="submit">Enviar Código</button>
        </form>
      ) : (
        <form onSubmit={handleVerifyOTP}>
          <label>
            Código OTP:
            <input
              type="text"
              value={code}
              onChange={(e) => setCode(e.target.value)}
              placeholder="Ingresa el código"
              required
            />
          </label>
          <button type="submit">Verificar</button>
        </form>
      )}

      {message && <p>{message}</p>}
    </div>
  );
}

export default App;