-- Crear la base de datos
CREATE DATABASE medirec_db;
USE medirec_db;

-- Tabla de Usuarios (base para todos los roles)
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL, -- Almacenar hash, no texto plano
    rol ENUM('admin', 'medico', 'paciente') NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    foto_url VARCHAR(255),
    telefono VARCHAR(20),
    dosfa_habilitado TINYINT(1) DEFAULT 0,
    dosfa_secreto VARCHAR(100), -- Para códigos TOTP de 2FA
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla de Pacientes (datos específicos)
CREATE TABLE pacientes (
    id INT PRIMARY KEY,
    edad INT CHECK (edad >= 0),
    direccion TEXT,
    alergias TEXT, -- Podrías usar JSON si tu versión de MySQL lo soporta (5.7+)
    antecedentes_medicos TEXT,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabla de Médicos (datos específicos)
CREATE TABLE medicos (
    id INT PRIMARY KEY,
    especialidad VARCHAR(100),
    numero_licencia VARCHAR(50) UNIQUE NOT NULL,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabla de Citas
CREATE TABLE citas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT,
    medico_id INT,
    fecha_hora DATETIME NOT NULL,
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_cita_medico_fecha (medico_id, fecha_hora), -- Evitar citas duplicadas para un médico
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE SET NULL,
    FOREIGN KEY (medico_id) REFERENCES medicos(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tabla de Recetas
CREATE TABLE recetas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT,
    medico_id INT,
    medicamentos TEXT NOT NULL, -- Podrías usar JSON si lo prefieres
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE SET NULL,
    FOREIGN KEY (medico_id) REFERENCES medicos(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tabla de Productos de Farmacia
CREATE TABLE productos_farmacia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
    stock INT NOT NULL CHECK (stock >= 0),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla de Ventas
CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT,
    producto_id INT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    metodo_entrega ENUM('recoger', 'envio') NOT NULL,
    estado ENUM('pendiente', 'enviado', 'entregado') DEFAULT 'pendiente',
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2) AS (cantidad * (SELECT precio FROM productos_farmacia WHERE productos_farmacia.id = ventas.producto_id)) STORED,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE SET NULL,
    FOREIGN KEY (producto_id) REFERENCES productos_farmacia(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Índices para mejorar rendimiento
CREATE INDEX idx_citas_fecha_hora ON citas(fecha_hora);
CREATE INDEX idx_ventas_paciente_id ON ventas(paciente_id);
CREATE INDEX idx_recetas_paciente_id ON recetas(paciente_id);

-- Datos de prueba (opcional)
INSERT INTO usuarios (email, contrasena, rol, nombre, telefono) 
VALUES 
    ('admin@medirec.com', 'hashed_password', 'admin', 'Admin Principal', '1234567890'),
    ('medico1@medirec.com', 'hashed_password', 'medico', 'Dr. Juan Pérez', '0987654321'),
    ('paciente1@medirec.com', 'hashed_password', 'paciente', 'Ana Gómez', '5555555555');

INSERT INTO medicos (id, especialidad, numero_licencia) 
VALUES 
    (2, 'Cardiología', 'LIC12345');

INSERT INTO pacientes (id, edad, direccion, alergias, antecedentes_medicos) 
VALUES 
    (3, 30, 'Calle Falsa 123', 'Penicilina', 'Hipertensión');

INSERT INTO productos_farmacia (nombre, precio, stock) 
VALUES 
    ('Paracetamol', 5.00, 100),
    ('Ibuprofeno', 8.50, 50);