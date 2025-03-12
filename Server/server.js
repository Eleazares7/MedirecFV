import 'dotenv/config'; // Carga variables de entorno desde .env
import express from 'express';
import nodemailer from 'nodemailer';
import cors from 'cors'; // Importar cors

const app = express();

// Habilitar CORS para permitir solicitudes desde el frontend
app.use(cors()); // Por defecto, permite todos los orígenes
app.use(express.json());

// Configurar transporte SMTP con Gmail
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_PASS,
  },
});

// Almacenar códigos OTP temporalmente (en producción usa una base de datos o Redis)
const otpStore = {};

// Generar un código OTP de 6 dígitos
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Ruta 1: Enviar OTP por correo
app.post('/2fa/send', async (req, res) => {
  const { email } = req.body; // Ejemplo: { "email": "destinatario@example.com" }

  if (!email) {
    return res.status(400).json({ success: false, message: 'Email requerido' });
  }

  const otp = generateOTP();
  otpStore[email] = otp; // Almacenar el OTP (temporal)

  const mailOptions = {
    from: process.env.GMAIL_USER,
    to: email,
    subject: 'Tu código de verificación',
    text: `Tu código OTP es: ${otp}. Válido por 5 minutos.`,
  };

  try {
    await transporter.sendMail(mailOptions);
    res.json({ success: true, message: 'Código enviado al correo' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Ruta 2: Verificar el OTP
app.post('/2fa/verify', (req, res) => {
  const { email, code } = req.body; // Ejemplo: { "email": "destinatario@example.com", "code": "123456" }

  if (!email || !code) {
    return res.status(400).json({ success: false, message: 'Email y código requeridos' });
  }

  const storedOtp = otpStore[email];
  if (!storedOtp) {
    return res.status(400).json({ success: false, message: 'No hay código generado para este email' });
  }

  if (storedOtp === code) {
    delete otpStore[email]; // Eliminar OTP tras verificar (uso único)
    res.json({ success: true, message: 'Verificación exitosa' });
  } else {
    res.json({ success: false, message: 'Código inválido' });
  }
});

// Iniciar el servidor
app.listen(3000, () => {
  console.log('Servidor corriendo en puerto 3000');
});