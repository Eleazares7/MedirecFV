// server/routes/userRoutes.js
import express from 'express';
import db from '../config/db.js';

const router = express.Router();

router.get('/usuarios', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM usuarios');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener usuarios' });
  }
});

export default router;